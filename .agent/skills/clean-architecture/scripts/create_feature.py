#!/usr/bin/env python3
"""
Flutter Clean Architecture - Feature Generator
Kullanım: python create_feature.py --name authentication --with-tests

Bu script yeni bir feature klasörü oluşturur:
- data/datasources/
- data/models/
- data/repositories/
- domain/entities/
- domain/repositories/
- domain/usecases/
- presentation/bloc/
- presentation/pages/
- presentation/widgets/
"""

import argparse
import os
import re
from pathlib import Path
from datetime import datetime

def to_snake_case(name: str) -> str:
    """PascalCase veya camelCase'i snake_case'e çevir"""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def to_pascal_case(name: str) -> str:
    """snake_case'i PascalCase'e çevir"""
    return ''.join(word.capitalize() for word in name.replace('-', '_').split('_'))

def create_entity(feature_path: Path, name_pascal: str, name_snake: str):
    """Domain entity oluştur"""
    content = f'''/// {name_pascal} entity - Pure Dart, no Flutter imports
class {name_pascal} {{
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const {name_pascal}({{
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  }});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {name_pascal} &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '{name_pascal}(id: $id, name: $name)';
}}
'''
    filepath = feature_path / 'domain' / 'entities' / f'{name_snake}.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_repository_interface(feature_path: Path, name_pascal: str, name_snake: str):
    """Domain repository interface oluştur"""
    content = f'''import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/{name_snake}.dart';

/// {name_pascal} repository interface (domain layer)
/// Implementation is in the data layer
abstract class {name_pascal}Repository {{
  /// Get all {name_snake}s
  Future<Either<Failure, List<{name_pascal}>>> getAll();

  /// Get {name_snake} by ID
  Future<Either<Failure, {name_pascal}>> getById(String id);

  /// Create a new {name_snake}
  Future<Either<Failure, {name_pascal}>> create({name_pascal} entity);

  /// Update an existing {name_snake}
  Future<Either<Failure, {name_pascal}>> update({name_pascal} entity);

  /// Delete a {name_snake}
  Future<Either<Failure, Unit>> delete(String id);
}}
'''
    filepath = feature_path / 'domain' / 'repositories' / f'{name_snake}_repository.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_usecase(feature_path: Path, name_pascal: str, name_snake: str):
    """Domain use case oluştur"""
    content = f'''import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{name_snake}.dart';
import '../repositories/{name_snake}_repository.dart';

/// Get all {name_snake}s use case
class GetAll{name_pascal}s implements UseCase<List<{name_pascal}>, NoParams> {{
  final {name_pascal}Repository repository;

  GetAll{name_pascal}s(this.repository);

  @override
  Future<Either<Failure, List<{name_pascal}>>> call(NoParams params) {{
    return repository.getAll();
  }}
}}

/// Get {name_snake} by ID params
class Get{name_pascal}Params {{
  final String id;
  const Get{name_pascal}Params({{required this.id}});
}}

/// Get {name_snake} by ID use case
class Get{name_pascal}ById implements UseCase<{name_pascal}, Get{name_pascal}Params> {{
  final {name_pascal}Repository repository;

  Get{name_pascal}ById(this.repository);

  @override
  Future<Either<Failure, {name_pascal}>> call(Get{name_pascal}Params params) {{
    return repository.getById(params.id);
  }}
}}

/// Create {name_snake} use case
class Create{name_pascal} implements UseCase<{name_pascal}, {name_pascal}> {{
  final {name_pascal}Repository repository;

  Create{name_pascal}(this.repository);

  @override
  Future<Either<Failure, {name_pascal}>> call({name_pascal} params) {{
    return repository.create(params);
  }}
}}

/// Delete {name_snake} use case
class Delete{name_pascal} implements UseCase<Unit, String> {{
  final {name_pascal}Repository repository;

  Delete{name_pascal}(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {{
    return repository.delete(id);
  }}
}}
'''
    filepath = feature_path / 'domain' / 'usecases' / f'{name_snake}_usecases.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_model(feature_path: Path, name_pascal: str, name_snake: str):
    """Data model oluştur (freezed)"""
    content = f'''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{name_snake}.dart';

part '{name_snake}_model.freezed.dart';
part '{name_snake}_model.g.dart';

/// {name_pascal} data model with JSON serialization
@freezed
class {name_pascal}Model with _${name_pascal}Model {{
  const {name_pascal}Model._();

  const factory {name_pascal}Model({{
    required String id,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }}) = _{name_pascal}Model;

  factory {name_pascal}Model.fromJson(Map<String, dynamic> json) =>
      _${name_pascal}ModelFromJson(json);

  /// Convert to domain entity
  {name_pascal} toEntity() => {name_pascal}(
        id: id,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Create from domain entity
  factory {name_pascal}Model.fromEntity({name_pascal} entity) => {name_pascal}Model(
        id: entity.id,
        name: entity.name,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}}
'''
    models_path = feature_path / 'data' / 'models'
    models_path.mkdir(parents=True, exist_ok=True)
    filepath = models_path / f'{name_snake}_model.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_datasource(feature_path: Path, name_pascal: str, name_snake: str):
    """Data source oluştur"""
    content = f'''import '../models/{name_snake}_model.dart';

/// Remote data source interface
abstract class {name_pascal}RemoteDataSource {{
  Future<List<{name_pascal}Model>> getAll();
  Future<{name_pascal}Model> getById(String id);
  Future<{name_pascal}Model> create({name_pascal}Model model);
  Future<{name_pascal}Model> update({name_pascal}Model model);
  Future<void> delete(String id);
}}

/// Remote data source implementation
class {name_pascal}RemoteDataSourceImpl implements {name_pascal}RemoteDataSource {{
  // final ApiClient _apiClient;

  // {name_pascal}RemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<{name_pascal}Model>> getAll() async {{
    // TODO: Implement API call
    // final response = await _apiClient.get('/{name_snake}s');
    // return (response.data as List).map((e) => {name_pascal}Model.fromJson(e)).toList();
    throw UnimplementedError();
  }}

  @override
  Future<{name_pascal}Model> getById(String id) async {{
    // TODO: Implement API call
    throw UnimplementedError();
  }}

  @override
  Future<{name_pascal}Model> create({name_pascal}Model model) async {{
    // TODO: Implement API call
    throw UnimplementedError();
  }}

  @override
  Future<{name_pascal}Model> update({name_pascal}Model model) async {{
    // TODO: Implement API call
    throw UnimplementedError();
  }}

  @override
  Future<void> delete(String id) async {{
    // TODO: Implement API call
    throw UnimplementedError();
  }}
}}
'''
    datasources_path = feature_path / 'data' / 'datasources'
    datasources_path.mkdir(parents=True, exist_ok=True)
    filepath = datasources_path / f'{name_snake}_remote_datasource.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_repository_impl(feature_path: Path, name_pascal: str, name_snake: str):
    """Repository implementation oluştur"""
    content = f'''import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/{name_snake}.dart';
import '../../domain/repositories/{name_snake}_repository.dart';
import '../datasources/{name_snake}_remote_datasource.dart';
import '../models/{name_snake}_model.dart';

/// {name_pascal} repository implementation
class {name_pascal}RepositoryImpl implements {name_pascal}Repository {{
  final {name_pascal}RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  {name_pascal}RepositoryImpl({{
    required this.remoteDataSource,
    required this.networkInfo,
  }});

  @override
  Future<Either<Failure, List<{name_pascal}>>> getAll() async {{
    if (await networkInfo.isConnected) {{
      try {{
        final models = await remoteDataSource.getAll();
        return Right(models.map((m) => m.toEntity()).toList());
      }} on ServerException catch (e) {{
        return Left(ServerFailure(e.message));
      }}
    }} else {{
      return const Left(NetworkFailure('No internet connection'));
    }}
  }}

  @override
  Future<Either<Failure, {name_pascal}>> getById(String id) async {{
    if (await networkInfo.isConnected) {{
      try {{
        final model = await remoteDataSource.getById(id);
        return Right(model.toEntity());
      }} on ServerException catch (e) {{
        return Left(ServerFailure(e.message));
      }}
    }} else {{
      return const Left(NetworkFailure('No internet connection'));
    }}
  }}

  @override
  Future<Either<Failure, {name_pascal}>> create({name_pascal} entity) async {{
    if (await networkInfo.isConnected) {{
      try {{
        final model = {name_pascal}Model.fromEntity(entity);
        final result = await remoteDataSource.create(model);
        return Right(result.toEntity());
      }} on ServerException catch (e) {{
        return Left(ServerFailure(e.message));
      }}
    }} else {{
      return const Left(NetworkFailure('No internet connection'));
    }}
  }}

  @override
  Future<Either<Failure, {name_pascal}>> update({name_pascal} entity) async {{
    if (await networkInfo.isConnected) {{
      try {{
        final model = {name_pascal}Model.fromEntity(entity);
        final result = await remoteDataSource.update(model);
        return Right(result.toEntity());
      }} on ServerException catch (e) {{
        return Left(ServerFailure(e.message));
      }}
    }} else {{
      return const Left(NetworkFailure('No internet connection'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> delete(String id) async {{
    if (await networkInfo.isConnected) {{
      try {{
        await remoteDataSource.delete(id);
        return const Right(unit);
      }} on ServerException catch (e) {{
        return Left(ServerFailure(e.message));
      }}
    }} else {{
      return const Left(NetworkFailure('No internet connection'));
    }}
  }}
}}
'''
    repos_path = feature_path / 'data' / 'repositories'
    repos_path.mkdir(parents=True, exist_ok=True)
    filepath = repos_path / f'{name_snake}_repository_impl.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_bloc(feature_path: Path, name_pascal: str, name_snake: str):
    """Bloc, event, state dosyaları oluştur"""
    # Bloc
    bloc_content = f'''import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{name_snake}.dart';
import '../../domain/usecases/{name_snake}_usecases.dart';

part '{name_snake}_bloc.freezed.dart';
part '{name_snake}_event.dart';
part '{name_snake}_state.dart';

class {name_pascal}Bloc extends Bloc<{name_pascal}Event, {name_pascal}State> {{
  final GetAll{name_pascal}s getAll{name_pascal}s;
  final Create{name_pascal} create{name_pascal};
  final Delete{name_pascal} delete{name_pascal};

  {name_pascal}Bloc({{
    required this.getAll{name_pascal}s,
    required this.create{name_pascal},
    required this.delete{name_pascal},
  }}) : super(const {name_pascal}State.initial()) {{
    on<_Load>(_onLoad);
    on<_Refresh>(_onRefresh);
    on<_Create>(_onCreate);
    on<_Delete>(_onDelete);
  }}

  Future<void> _onLoad(_Load event, Emitter<{name_pascal}State> emit) async {{
    emit(const {name_pascal}State.loading());
    
    final result = await getAll{name_pascal}s(const NoParams());
    
    result.fold(
      (failure) => emit({name_pascal}State.error(failure.message)),
      (items) => emit({name_pascal}State.loaded(items: items)),
    );
  }}

  Future<void> _onRefresh(_Refresh event, Emitter<{name_pascal}State> emit) async {{
    final currentState = state;
    if (currentState is _Loaded) {{
      emit(currentState.copyWith(isRefreshing: true));
    }}
    
    final result = await getAll{name_pascal}s(const NoParams());
    
    result.fold(
      (failure) => emit({name_pascal}State.error(failure.message)),
      (items) => emit({name_pascal}State.loaded(items: items)),
    );
  }}

  Future<void> _onCreate(_Create event, Emitter<{name_pascal}State> emit) async {{
    // Optimistic update
    final currentState = state;
    if (currentState is _Loaded) {{
      final optimisticList = [...currentState.items, event.item];
      emit(currentState.copyWith(items: optimisticList));
      
      final result = await create{name_pascal}(event.item);
      
      result.fold(
        (failure) {{
          emit(currentState); // Rollback
          emit({name_pascal}State.error(failure.message));
        }},
        (created) {{
          // Success - refresh list
          add(const {name_pascal}Event.refresh());
        }},
      );
    }}
  }}

  Future<void> _onDelete(_Delete event, Emitter<{name_pascal}State> emit) async {{
    final currentState = state;
    if (currentState is _Loaded) {{
      final previousList = currentState.items;
      final updatedList = previousList.where((i) => i.id != event.id).toList();
      emit(currentState.copyWith(items: updatedList));
      
      final result = await delete{name_pascal}(event.id);
      
      result.fold(
        (failure) {{
          emit(currentState.copyWith(items: previousList)); // Rollback
          emit({name_pascal}State.error(failure.message));
        }},
        (_) {{ /* Success */ }},
      );
    }}
  }}
}}
'''
    
    # Event
    event_content = f'''part of '{name_snake}_bloc.dart';

@freezed
class {name_pascal}Event with _${name_pascal}Event {{
  const factory {name_pascal}Event.load() = _Load;
  const factory {name_pascal}Event.refresh() = _Refresh;
  const factory {name_pascal}Event.create({name_pascal} item) = _Create;
  const factory {name_pascal}Event.delete(String id) = _Delete;
}}
'''
    
    # State
    state_content = f'''part of '{name_snake}_bloc.dart';

@freezed
class {name_pascal}State with _${name_pascal}State {{
  const factory {name_pascal}State.initial() = _Initial;
  const factory {name_pascal}State.loading() = _Loading;
  const factory {name_pascal}State.loaded({{
    required List<{name_pascal}> items,
    @Default(false) bool isRefreshing,
  }}) = _Loaded;
  const factory {name_pascal}State.error(String message) = _Error;
}}
'''
    
    bloc_path = feature_path / 'presentation' / 'bloc'
    bloc_path.mkdir(parents=True, exist_ok=True)
    
    (bloc_path / f'{name_snake}_bloc.dart').write_text(bloc_content, encoding='utf-8')
    (bloc_path / f'{name_snake}_event.dart').write_text(event_content, encoding='utf-8')
    (bloc_path / f'{name_snake}_state.dart').write_text(state_content, encoding='utf-8')
    
    print(f'  ✓ Created: {bloc_path / f"{name_snake}_bloc.dart"}')
    print(f'  ✓ Created: {bloc_path / f"{name_snake}_event.dart"}')
    print(f'  ✓ Created: {bloc_path / f"{name_snake}_state.dart"}')

def create_page(feature_path: Path, name_pascal: str, name_snake: str):
    """Page widget oluştur"""
    content = f'''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/{name_snake}_bloc.dart';
import '../widgets/{name_snake}_list_item.dart';

class {name_pascal}Page extends StatelessWidget {{
  const {name_pascal}Page({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return BlocProvider(
      create: (context) => context.read<{name_pascal}Bloc>()
        ..add(const {name_pascal}Event.load()),
      child: const {name_pascal}View(),
    );
  }}
}}

class {name_pascal}View extends StatelessWidget {{
  const {name_pascal}View({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{name_pascal}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {{
              context.read<{name_pascal}Bloc>().add(const {name_pascal}Event.refresh());
            }},
          ),
        ],
      ),
      body: BlocBuilder<{name_pascal}Bloc, {name_pascal}State>(
        builder: (context, state) {{
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (items, isRefreshing) => RefreshIndicator(
              onRefresh: () async {{
                context.read<{name_pascal}Bloc>().add(const {name_pascal}Event.refresh());
              }},
              child: items.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => {name_pascal}ListItem(
                        item: items[index],
                        onDelete: () {{
                          context.read<{name_pascal}Bloc>().add(
                            {name_pascal}Event.delete(items[index].id),
                          );
                        }},
                      ),
                    ),
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {{
                      context.read<{name_pascal}Bloc>().add(const {name_pascal}Event.load());
                    }},
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        }},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {{
          // TODO: Navigate to create page
        }},
        child: const Icon(Icons.add),
      ),
    );
  }}
}}

class _EmptyState extends StatelessWidget {{
  const _EmptyState();

  @override
  Widget build(BuildContext context) {{
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Henüz öğe yok'),
          SizedBox(height: 8),
          Text('+ butonuna tıklayarak ekleyin'),
        ],
      ),
    );
  }}
}}
'''
    pages_path = feature_path / 'presentation' / 'pages'
    pages_path.mkdir(parents=True, exist_ok=True)
    filepath = pages_path / f'{name_snake}_page.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_widget(feature_path: Path, name_pascal: str, name_snake: str):
    """List item widget oluştur"""
    content = f'''import 'package:flutter/material.dart';
import '../../domain/entities/{name_snake}.dart';

class {name_pascal}ListItem extends StatelessWidget {{
  const {name_pascal}ListItem({{
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  }});

  final {name_pascal} item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {{
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('ID: ${{item.id}}'),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {{
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sil?'),
                      content: const Text('Bu öğeyi silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () {{
                            Navigator.pop(context);
                            onDelete?.call();
                          }},
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );
                }},
              )
            : null,
        onTap: onTap,
      ),
    );
  }}
}}
'''
    widgets_path = feature_path / 'presentation' / 'widgets'
    widgets_path.mkdir(parents=True, exist_ok=True)
    filepath = widgets_path / f'{name_snake}_list_item.dart'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_tests(test_path: Path, name_pascal: str, name_snake: str):
    """Test dosyaları oluştur"""
    # Bloc test
    bloc_test = f'''import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Import your bloc and use cases here
// import 'package:your_app/features/{name_snake}/presentation/bloc/{name_snake}_bloc.dart';

class MockGetAll{name_pascal}s extends Mock implements GetAll{name_pascal}s {{}}
class MockCreate{name_pascal} extends Mock implements Create{name_pascal} {{}}
class MockDelete{name_pascal} extends Mock implements Delete{name_pascal} {{}}

void main() {{
  late {name_pascal}Bloc bloc;
  late MockGetAll{name_pascal}s mockGetAll;
  late MockCreate{name_pascal} mockCreate;
  late MockDelete{name_pascal} mockDelete;

  setUp(() {{
    mockGetAll = MockGetAll{name_pascal}s();
    mockCreate = MockCreate{name_pascal}();
    mockDelete = MockDelete{name_pascal}();
    bloc = {name_pascal}Bloc(
      getAll{name_pascal}s: mockGetAll,
      create{name_pascal}: mockCreate,
      delete{name_pascal}: mockDelete,
    );
  }});

  tearDown(() {{
    bloc.close();
  }});

  test('initial state is correct', () {{
    expect(bloc.state, const {name_pascal}State.initial());
  }});

  group('load', () {{
    blocTest<{name_pascal}Bloc, {name_pascal}State>(
      'emits [loading, loaded] when load succeeds',
      build: () {{
        when(() => mockGetAll(any())).thenAnswer((_) async => const Right([]));
        return bloc;
      }},
      act: (bloc) => bloc.add(const {name_pascal}Event.load()),
      expect: () => [
        const {name_pascal}State.loading(),
        const {name_pascal}State.loaded(items: []),
      ],
      verify: (_) {{
        verify(() => mockGetAll(any())).called(1);
      }},
    );

    blocTest<{name_pascal}Bloc, {name_pascal}State>(
      'emits [loading, error] when load fails',
      build: () {{
        when(() => mockGetAll(any()))
            .thenAnswer((_) async => const Left(ServerFailure('error')));
        return bloc;
      }},
      act: (bloc) => bloc.add(const {name_pascal}Event.load()),
      expect: () => [
        const {name_pascal}State.loading(),
        const {name_pascal}State.error('error'),
      ],
    );
  }});
}}
'''
    
    bloc_test_path = test_path / 'presentation' / 'bloc'
    bloc_test_path.mkdir(parents=True, exist_ok=True)
    filepath = bloc_test_path / f'{name_snake}_bloc_test.dart'
    filepath.write_text(bloc_test, encoding='utf-8')
    print(f'  ✓ Created: {filepath}')

def create_feature(name: str, output_dir: str = '.', with_tests: bool = True):
    """Ana feature oluşturma fonksiyonu"""
    name_snake = to_snake_case(name)
    name_pascal = to_pascal_case(name)
    
    print(f'\n🏗️  Creating feature: {name_pascal}')
    print('=' * 50)
    
    # Paths
    lib_path = Path(output_dir) / 'lib' / 'features' / name_snake
    test_path = Path(output_dir) / 'test' / 'features' / name_snake
    
    # Create directories
    for subdir in ['data/datasources', 'data/models', 'data/repositories',
                   'domain/entities', 'domain/repositories', 'domain/usecases',
                   'presentation/bloc', 'presentation/pages', 'presentation/widgets']:
        (lib_path / subdir).mkdir(parents=True, exist_ok=True)
    
    print('\n📁 Domain Layer:')
    create_entity(lib_path, name_pascal, name_snake)
    create_repository_interface(lib_path, name_pascal, name_snake)
    create_usecase(lib_path, name_pascal, name_snake)
    
    print('\n📁 Data Layer:')
    create_model(lib_path, name_pascal, name_snake)
    create_datasource(lib_path, name_pascal, name_snake)
    create_repository_impl(lib_path, name_pascal, name_snake)
    
    print('\n📁 Presentation Layer:')
    create_bloc(lib_path, name_pascal, name_snake)
    create_page(lib_path, name_pascal, name_snake)
    create_widget(lib_path, name_pascal, name_snake)
    
    if with_tests:
        print('\n📁 Tests:')
        create_tests(test_path, name_pascal, name_snake)
    
    print('\n' + '=' * 50)
    print(f'✅ Feature "{name_pascal}" created successfully!')
    print(f'\n📍 Location: {lib_path}')
    print('\n⚡ Next steps:')
    print('  1. Run: flutter pub run build_runner build --delete-conflicting-outputs')
    print('  2. Register dependencies in injection.dart')
    print('  3. Add route to app router')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Create a new Clean Architecture feature',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python create_feature.py --name authentication
  python create_feature.py --name task-list --with-tests
  python create_feature.py --name UserProfile --output ./my_app
        '''
    )
    parser.add_argument('--name', required=True, help='Feature name (e.g., authentication, TaskList)')
    parser.add_argument('--output', default='.', help='Output directory (default: current)')
    parser.add_argument('--with-tests', action='store_true', default=True, help='Generate test files')
    parser.add_argument('--no-tests', action='store_true', help='Skip test file generation')
    
    args = parser.parse_args()
    create_feature(args.name, args.output, with_tests=not args.no_tests)
