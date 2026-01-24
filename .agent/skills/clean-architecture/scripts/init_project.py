#!/usr/bin/env python3
"""
Flutter Clean Architecture - Project Initializer
Kullanım: python init_project.py --name my_app --state-management bloc

Bu script yeni bir Flutter projesini Clean Architecture yapısıyla başlatır.
"""

import argparse
import os
from pathlib import Path

def create_core_structure(lib_path: Path):
    """Core klasör yapısını oluştur"""
    print('\n📁 Core yapısı oluşturuluyor...')
    
    # Directories
    dirs = [
        'core/error',
        'core/network',
        'core/usecases',
        'core/utils',
        'core/constants',
        'core/theme',
        'app',
        'shared/widgets',
        'shared/extensions',
        'features',
    ]
    
    for d in dirs:
        (lib_path / d).mkdir(parents=True, exist_ok=True)
        print(f'  ✓ {d}/')
    
    # Core files
    files = {
        'core/error/failures.dart': '''import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
''',
        'core/error/exceptions.dart': '''class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException([this.message = 'Cache error']);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException([this.message = 'Network error']);
  
  @override
  String toString() => 'NetworkException: $message';
}
''',
        'core/usecases/usecase.dart': '''import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
''',
        'core/network/network_info.dart': '''import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
''',
        'core/constants/api_constants.dart': '''abstract class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);
  
  // Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
}
''',
        'core/constants/app_constants.dart': '''abstract class AppConstants {
  static const String appName = 'My App';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache
  static const Duration cacheValidity = Duration(hours: 1);
}
''',
        'app/injection.dart': '''import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  
  // Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
    ));
    return dio;
  });
  
  // TODO: Register features
}
''',
    }
    
    for filepath, content in files.items():
        file_path = lib_path / filepath
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding='utf-8')
        print(f'  ✓ {filepath}')

def create_analysis_options(project_path: Path):
    """analysis_options.yaml oluştur"""
    content = '''include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"

linter:
  rules:
    # Error Rules
    avoid_dynamic_calls: true
    avoid_returning_null_for_future: true
    avoid_slow_async_io: true
    cancel_subscriptions: true
    close_sinks: true
    
    # Style Rules
    always_declare_return_types: true
    always_put_required_named_parameters_first: true
    avoid_bool_literals_in_conditional_expressions: true
    avoid_catches_without_on_clauses: true
    avoid_catching_errors: true
    avoid_equals_and_hash_code_on_mutable_classes: true
    avoid_field_initializers_in_const_classes: true
    avoid_positional_boolean_parameters: true
    avoid_returning_this: true
    avoid_setters_without_getters: true
    avoid_unused_constructor_parameters: true
    cascade_invocations: true
    cast_nullable_to_non_nullable: true
    deprecated_consistency: true
    directives_ordering: true
    join_return_with_assignment: true
    missing_whitespace_between_adjacent_strings: true
    no_adjacent_strings_in_list: true
    no_runtimeType_toString: true
    noop_primitive_operations: true
    omit_local_variable_types: true
    one_member_abstracts: true
    only_throw_errors: true
    parameter_assignments: true
    prefer_asserts_in_initializer_lists: true
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_constructors_over_static_methods: true
    prefer_final_in_for_each: true
    prefer_final_locals: true
    prefer_if_elements_to_conditional_expressions: true
    prefer_int_literals: true
    prefer_mixin: true
    prefer_null_aware_method_calls: true
    prefer_single_quotes: true
    require_trailing_commas: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    tighten_type_of_initializing_formals: true
    type_annotate_public_apis: true
    unawaited_futures: true
    unnecessary_await_in_return: true
    unnecessary_lambdas: true
    unnecessary_null_aware_assignments: true
    unnecessary_null_checks: true
    unnecessary_parenthesis: true
    unnecessary_raw_strings: true
    unnecessary_statements: true
    use_if_null_to_convert_nulls_to_bools: true
    use_is_even_rather_than_modulo: true
    use_late_for_private_fields_and_variables: true
    use_named_constants: true
    use_raw_strings: true
    use_setters_to_change_properties: true
    use_string_buffers: true
    use_super_parameters: true
    use_to_and_as_if_applicable: true
'''
    filepath = project_path / 'analysis_options.yaml'
    filepath.write_text(content, encoding='utf-8')
    print(f'  ✓ analysis_options.yaml')

def create_pubspec_additions():
    """pubspec.yaml'a eklenecek dependencies"""
    return '''
# === CLEAN ARCHITECTURE DEPENDENCIES ===

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  # flutter_riverpod: ^2.4.9  # Alternative
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Functional Programming
  fpdart: ^1.1.0
  
  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3
  connectivity_plus: ^5.0.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  # hive: ^2.2.3  # Optional
  
  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # Utils
  equatable: ^2.0.5
  intl: ^0.18.1
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  injectable_generator: ^2.4.1
  
  # Testing
  mocktail: ^1.0.1
  bloc_test: ^9.1.5

# ===========================================
'''

def init_project(name: str, state_management: str = 'bloc', output_dir: str = '.'):
    """Projeyi başlat"""
    print(f'\n🚀 Initializing project: {name}')
    print(f'   State Management: {state_management}')
    print('=' * 50)
    
    project_path = Path(output_dir)
    lib_path = project_path / 'lib'
    
    # Create core structure
    create_core_structure(lib_path)
    
    # Create analysis_options.yaml
    print('\n📝 Config dosyaları:')
    create_analysis_options(project_path)
    
    # Print pubspec additions
    print('\n📦 pubspec.yaml\'a eklenecekler:')
    print('-' * 50)
    print(create_pubspec_additions())
    print('-' * 50)
    
    print('\n' + '=' * 50)
    print('✅ Project structure created!')
    print('\n⚡ Next steps:')
    print('  1. Add dependencies to pubspec.yaml (shown above)')
    print('  2. Run: flutter pub get')
    print('  3. Run: flutter pub run build_runner build')
    print('  4. Create your first feature with: python create_feature.py --name <feature>')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Initialize Clean Architecture project')
    parser.add_argument('--name', required=True, help='Project name')
    parser.add_argument('--state-management', choices=['bloc', 'riverpod'], default='bloc')
    parser.add_argument('--output', default='.', help='Output directory')
    
    args = parser.parse_args()
    init_project(args.name, args.state_management, args.output)
