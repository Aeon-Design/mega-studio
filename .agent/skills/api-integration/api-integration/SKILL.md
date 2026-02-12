# 🌐 API Integration Skill

> Dio setup, Retrofit, error handling, caching ve network katmanı

---

## Network Katmanı Mimarisi

```
Presentation → UseCase → Repository → DataSource → Dio Client → API
                                           ↓
                                     Local Cache (Hive)
```

---

## Retrofit ile Type-Safe API

### API Service Tanımı
```dart
// lib/features/task/data/datasources/task_api_service.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'task_api_service.g.dart';

@RestApi()
@injectable
abstract class TaskApiService {
  @factoryMethod
  factory TaskApiService(Dio dio) = _TaskApiService;

  @GET('/tasks')
  Future<List<TaskModel>> getTasks({
    @Query('page') required int page,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
  });

  @GET('/tasks/{id}')
  Future<TaskModel> getTask(@Path('id') String id);

  @POST('/tasks')
  Future<TaskModel> createTask(@Body() CreateTaskRequest request);

  @PUT('/tasks/{id}')
  Future<TaskModel> updateTask(
    @Path('id') String id,
    @Body() UpdateTaskRequest request,
  );

  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  @POST('/tasks/{id}/toggle')
  Future<TaskModel> toggleTask(@Path('id') String id);

  @Multipart()
  @POST('/tasks/{id}/attachment')
  Future<AttachmentModel> uploadAttachment(
    @Path('id') String id,
    @Part(name: 'file') File file,
  );
}
```

### Model Tanımı (Freezed + JsonSerializable)
```dart
// lib/features/task/data/models/task_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @Default(TaskPriority.medium) TaskPriority priority,
    List<String>? tags,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

// Entity'ye dönüştürme extension'ı
extension TaskModelX on TaskModel {
  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
    dueDate: dueDate,
    priority: priority,
    tags: tags ?? [],
  );
}

extension TaskListModelX on List<TaskModel> {
  List<Task> toEntities() => map((m) => m.toEntity()).toList();
}
```

---

## Dio Interceptor'lar

### Cache Interceptor
```dart
class CacheInterceptor extends Interceptor {
  final Box<String> _cacheBox;
  final Duration _maxAge;

  CacheInterceptor({
    required Box<String> cacheBox,
    Duration maxAge = const Duration(minutes: 5),
  })  : _cacheBox = cacheBox,
        _maxAge = maxAge;

  String _cacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Sadece GET isteklerini cache'le
    if (options.method != 'GET') {
      handler.next(options);
      return;
    }

    final key = _cacheKey(options);
    final cached = _cacheBox.get(key);

    if (cached != null) {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(cacheData['cached_at'] as String);

      if (DateTime.now().difference(cachedAt) < _maxAge) {
        handler.resolve(Response(
          requestOptions: options,
          data: cacheData['data'],
          statusCode: 200,
        ));
        return;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200) {
      final key = _cacheKey(response.requestOptions);
      _cacheBox.put(key, jsonEncode({
        'data': response.data,
        'cached_at': DateTime.now().toIso8601String(),
      }));
    }
    handler.next(response);
  }
}
```

### Retry Interceptor
```dart
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;

  RetryInterceptor({required Dio dio, int maxRetries = 3})
      : _dio = dio,
        _maxRetries = maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < _maxRetries) {
      await Future.delayed(Duration(seconds: math.pow(2, retryCount).toInt()));

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Retry de başarısız olursa devam et
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
```

---

## Repository Pattern (Offline-First)

```dart
// lib/features/task/data/repositories/task_repository_impl.dart
@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskApiService _apiService;
  final TaskLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const TaskRepositoryImpl({
    required TaskApiService apiService,
    required TaskLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _apiService = apiService,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    required int page,
    TaskFilter? filter,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _apiService.getTasks(
          page: page,
          status: filter?.toApiString(),
        );
        // Cache'e kaydet
        if (page == 1) {
          await _localDataSource.cacheTasks(models);
        }
        return Right(models.toEntities());
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: _mapDioError(e),
          code: e.response?.statusCode,
        ));
      }
    } else {
      // Offline — cache'ten oku
      try {
        final cached = await _localDataSource.getCachedTasks();
        return Right(cached.toEntities());
      } catch (_) {
        return const Left(CacheFailure(
          message: 'Çevrimdışı ve önbellek boş',
        ));
      }
    }
  }

  String _mapDioError(DioException e) {
    if (e is NoInternetConnectionException) return 'İnternet bağlantısı yok';
    if (e is DeadlineExceededException) return 'İstek zaman aşımına uğradı';
    if (e is UnauthorizedException) return 'Oturum süresi doldu';
    if (e is NotFoundException) return 'İçerik bulunamadı';
    return e.response?.data?['message']?.toString() ?? 'Sunucu hatası';
  }
}
```

---

## Connectivity Handling

```dart
// lib/core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}

// UI'da connectivity gösterimi
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: getIt<NetworkInfo>().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return MaterialBanner(
            content: const Text('Çevrimdışı — Veriler eski olabilir'),
            leading: const Icon(Icons.wifi_off),
            backgroundColor: context.colorScheme.errorContainer,
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Kapat'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```
