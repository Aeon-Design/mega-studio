---
name: "API Integration"
version: "1.0.0"
description: "Dio, Retrofit patterns, error handling, and network layer architecture"
primary_users:
  - backend-specialist
  - mobile-developer
dependencies:
  - clean-architecture
tags:
  - network
  - api
---

# 🌐 API Integration

## Quick Start

Dio + Retrofit ile type-safe API entegrasyonu. Error handling, interceptors,
ve offline-first stratejileri.

---

## 📚 Core Setup

### 1. Dependencies

```yaml
dependencies:
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  connectivity_plus: ^5.0.2
  
dev_dependencies:
  retrofit_generator: ^8.0.6
  json_serializable: ^6.7.1
  build_runner: ^2.4.8
```

### 2. Dio Client Setup

```dart
import 'package:dio/dio.dart';

class DioClient {
  static Dio create({
    required String baseUrl,
    required SecureStorageService storage,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptors
    dio.interceptors.addAll([
      AuthInterceptor(storage),
      LoggingInterceptor(),
      RetryInterceptor(dio),
      ErrorInterceptor(),
    ]);
    
    return dio;
  }
}
```

### 3. Auth Interceptor

```dart
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  
  AuthInterceptor(this._storage);
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }
    
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired - try refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
  
  bool _isPublicEndpoint(String path) {
    const publicPaths = ['/auth/login', '/auth/register', '/health'];
    return publicPaths.any((p) => path.contains(p));
  }
}
```

### 4. Retry Interceptor

```dart
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  
  RetryInterceptor(this._dio, {this.maxRetries = 3});
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        // Exponential backoff
        await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
        
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
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

## 🔧 Retrofit Integration

### 1. API Client Definition

```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
  
  // GET
  @GET('/users')
  Future<List<UserModel>> getUsers();
  
  @GET('/users/{id}')
  Future<UserModel> getUserById(@Path('id') String id);
  
  // POST
  @POST('/users')
  Future<UserModel> createUser(@Body() CreateUserRequest request);
  
  // PUT
  @PUT('/users/{id}')
  Future<UserModel> updateUser(
    @Path('id') String id,
    @Body() UpdateUserRequest request,
  );
  
  // DELETE
  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);
  
  // Query parameters
  @GET('/tasks')
  Future<PaginatedResponse<TaskModel>> getTasks(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('status') String? status,
  );
  
  // Multipart (file upload)
  @POST('/upload')
  @MultiPart()
  Future<UploadResponse> uploadFile(
    @Part() File file,
    @Part(name: 'description') String? description,
  );
  
  // Headers
  @GET('/protected')
  @Headers({'X-Custom-Header': 'value'})
  Future<ProtectedData> getProtectedData();
}
```

### 2. Request/Response Models

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
}

@freezed
class CreateUserRequest with _$CreateUserRequest {
  const factory CreateUserRequest({
    required String name,
    required String email,
    required String password,
  }) = _CreateUserRequest;
  
  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateUserRequestFromJson(json);
}

@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> data,
    required int page,
    @JsonKey(name: 'total_pages') required int totalPages,
    @JsonKey(name: 'total_items') required int totalItems,
  }) = _PaginatedResponse<T>;
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}
```

---

## ⚠️ Error Handling

### 1. Exception Types

```dart
sealed class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
}

class ServerException extends AppException {
  final int statusCode;
  
  const ServerException(super.message, {required this.statusCode, super.code});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Bağlantı hatası']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Önbellek hatası']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Yetkilendirme hatası']);
}
```

### 2. Error Interceptor

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      type: err.type,
      response: err.response,
    ));
  }
  
  AppException _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException('Bağlantı zaman aşımına uğradı');
        
      case DioExceptionType.connectionError:
        return const NetworkException('İnternet bağlantısı yok');
        
      case DioExceptionType.badResponse:
        return _handleBadResponse(err.response);
        
      default:
        return const AppException('Beklenmeyen hata');
    }
  }
  
  AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;
    
    final message = data is Map 
        ? (data['message'] ?? data['error'] ?? 'Sunucu hatası')
        : 'Sunucu hatası';
    
    switch (statusCode) {
      case 400:
        return ServerException(message, statusCode: 400, code: 'BAD_REQUEST');
      case 401:
        return const UnauthorizedException();
      case 403:
        return ServerException('Erişim reddedildi', statusCode: 403);
      case 404:
        return ServerException('Kaynak bulunamadı', statusCode: 404);
      case 422:
        return ServerException(message, statusCode: 422, code: 'VALIDATION');
      case 429:
        return ServerException('Çok fazla istek', statusCode: 429);
      default:
        return ServerException(message, statusCode: statusCode);
    }
  }
}
```

---

## 📡 Connectivity Handling

```dart
class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo(this._connectivity);
  
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}

// Repository'de kullanım
class TaskRepositoryImpl implements TaskRepository {
  final ApiClient _api;
  final TaskLocalDataSource _local;
  final NetworkInfo _networkInfo;
  
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _api.getTasks(page: 1, limit: 100);
        await _local.cacheTasks(response.data);
        return Right(response.data.map((m) => m.toEntity()).toList());
      } on AppException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await _local.getCachedTasks();
        return Right(cached.map((m) => m.toEntity()).toList());
      } on CacheException {
        return Left(const CacheFailure('Önbellek boş'));
      }
    }
  }
}
```

---

## ✅ API Checklist

- [ ] Auth interceptor token refresh var mı?
- [ ] Retry logic implemented mı?
- [ ] Error handling comprehensive mı?
- [ ] Offline fallback var mı?
- [ ] Request/response logging (debug only)?
- [ ] Timeout'lar ayarlı mı?

---

## 🔗 Related Resources

- [templates/dio_client.dart](templates/dio_client.dart)
- [templates/retrofit_service.dart](templates/retrofit_service.dart)
- Grimoire: `backend_scaling.md`
