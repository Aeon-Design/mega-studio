---
name: "Clean Architecture"
version: "1.0.0"
description: |
  Flutter projelerinde Clean Architecture implementasyonu.
  Yeni proje başlatma, feature ekleme veya mimari kararlar gerektiğinde kullanılır.
  Tetikleyiciler: "proje yapısı", "mimari", "clean architecture", "feature ekle",
  "katman", "repository pattern", "use case", "entity", "domain layer"
primary_users:
  - flutter-architect
  - mobile-developer
  - tech-lead
dependencies:
  - flutter-foundations
tags:
  - architecture
  - core
  - patterns
scripts:
  - scripts/init_project.py
  - scripts/create_feature.py
---

# 🏗️ Clean Architecture

## Quick Start

Clean Architecture, kodun test edilebilir, sürdürülebilir ve değişime açık olmasını sağlar.
Temel prensip: **Dependency Rule** - dış katmanlar iç katmanlara bağımlı, tersi asla!

---

## 📚 Core Concepts

### 1. Layer Structure

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION                             │
│  (Widgets, Pages, BLoC/Provider, ViewModels)                  │
│  • Framework-dependent                                        │
│  • UI logic only                                              │
├──────────────────────────────────────────────────────────────┤
│                        DOMAIN                                 │
│  (Entities, Use Cases, Repository Interfaces)                │
│  • Pure Dart - NO Flutter imports!                           │
│  • Business logic                                             │
├──────────────────────────────────────────────────────────────┤
│                         DATA                                  │
│  (Repository Impl, Data Sources, Models, DTOs)               │
│  • External dependencies                                      │
│  • API calls, database, cache                                │
└──────────────────────────────────────────────────────────────┘

Dependency Flow:  Presentation → Domain ← Data
```

### 2. Folder Structure

```
lib/
├── app/
│   ├── app.dart                 # MaterialApp widget
│   ├── routes.dart              # GoRouter config
│   └── injection.dart           # GetIt setup
│
├── core/
│   ├── error/
│   │   ├── exceptions.dart      # throw edilenler
│   │   └── failures.dart        # Either ile dönenler
│   ├── network/
│   │   ├── api_client.dart
│   │   └── interceptors.dart
│   ├── utils/
│   │   ├── extensions.dart
│   │   └── validators.dart
│   └── constants/
│       ├── api_constants.dart
│       └── app_constants.dart
│
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── remote/
│       │   │   │   └── [feature]_remote_datasource.dart
│       │   │   └── local/
│       │   │       └── [feature]_local_datasource.dart
│       │   ├── models/
│       │   │   └── [feature]_model.dart   # toJson/fromJson
│       │   └── repositories/
│       │       └── [feature]_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── [feature].dart         # Pure Dart class
│       │   ├── repositories/
│       │   │   └── [feature]_repository.dart  # Abstract
│       │   └── usecases/
│       │       ├── get_[feature].dart
│       │       └── create_[feature].dart
│       └── presentation/
│           ├── bloc/ (or providers/)
│           │   ├── [feature]_bloc.dart
│           │   ├── [feature]_event.dart
│           │   └── [feature]_state.dart
│           ├── pages/
│           │   └── [feature]_page.dart
│           └── widgets/
│               └── [feature]_card.dart
│
└── shared/
    ├── widgets/
    │   ├── app_button.dart
    │   └── loading_indicator.dart
    └── extensions/
        └── context_extensions.dart
```

### 3. Entity vs Model

```dart
// 🟢 DOMAIN LAYER - Entity (Pure Dart)
// lib/features/user/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
}

// 🔵 DATA LAYER - Model (with serialization)
// lib/features/user/data/models/user_model.dart
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
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    createdAt: createdAt,
  );
}
```

### 4. Use Case Pattern

```dart
// Base class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// Concrete implementation
class GetUserProfile extends UseCase<User, GetUserProfileParams> {
  final UserRepository repository;
  
  GetUserProfile(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserProfileParams params) {
    return repository.getUserById(params.userId);
  }
}

class GetUserProfileParams {
  final String userId;
  const GetUserProfileParams({required this.userId});
}

// Usage in BLoC/Provider
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile getUserProfile;
  
  UserProfileBloc(this.getUserProfile) : super(UserProfileInitial()) {
    on<LoadUserProfile>((event, emit) async {
      emit(UserProfileLoading());
      
      final result = await getUserProfile(
        GetUserProfileParams(userId: event.userId),
      );
      
      result.fold(
        (failure) => emit(UserProfileError(failure.message)),
        (user) => emit(UserProfileLoaded(user)),
      );
    });
  }
}
```

### 5. Repository Pattern

```dart
// 🟢 DOMAIN - Abstract Repository
abstract class UserRepository {
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, Unit>> createUser(User user);
  Future<Either<Failure, Unit>> deleteUser(String id);
}

// 🔵 DATA - Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUserById(id);
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUser(id);
        return Right(localUser.toEntity());
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

### 6. Dependency Injection (get_it + injectable)

```dart
// lib/app/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Feature module
@module
abstract class UserModule {
  @lazySingleton
  UserRemoteDataSource get remoteDataSource => 
      UserRemoteDataSourceImpl(getIt<Dio>());
  
  @lazySingleton
  UserLocalDataSource get localDataSource => 
      UserLocalDataSourceImpl(getIt<SharedPreferences>());
}

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  // injectable tarafından otomatik inject edilir
  UserRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );
  // ...
}
```

---

## ✅ Architecture Checklist

### Domain Layer
- [ ] Entity'ler pure Dart mı? (no Flutter imports)
- [ ] Repository interface'leri Domain'de mi?
- [ ] Use case'ler tek bir iş mi yapıyor?

### Data Layer
- [ ] Model'lerde toEntity() var mı?
- [ ] DataSource'lar testable mi?
- [ ] Exception handling yapılmış mı?

### Presentation Layer
- [ ] BLoC/Provider sadece use case çağırıyor mu?
- [ ] Widget'lar Domain entity'lerini kullanıyor mu?
- [ ] Navigation logic ayrı mı?

---

## ⚠️ Common Mistakes

### 1. Domain'de Flutter Import
```dart
// ❌ YANLIŞ
import 'package:flutter/material.dart';

class User {
  final Color favoriteColor; // Flutter type!
}

// ✅ DOĞRU
class User {
  final int favoriteColorValue; // Primitive type
}
```

### 2. Repository'de UI Logic
```dart
// ❌ YANLIŞ
Future<Either<Failure, User>> getUser() async {
  showLoadingDialog(); // UI logic burada olmamalı!
  final user = await api.getUser();
  hideLoadingDialog();
  return Right(user);
}
```

---

## 🔗 Related Resources

- [templates/feature_template/](templates/feature_template/)
- Grimoire: `clean_architecture_mastery.md`
- Grimoire: `flutter_architecture.md`
