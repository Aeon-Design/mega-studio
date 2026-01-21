# 🏛️ Flutter Architecture Grimoire

> **Owner:** Tech Lead / CTO
> **Purpose:** Scalable, maintainable project structures for large Flutter apps.

---

## 🗂️ The Feature-First Structure

```
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── theme/
│   ├── utils/
│   └── widgets/           # Shared UI components
├── features/
│   ├── auth/
│   │   ├── data/          # Repository, Data Sources
│   │   ├── domain/        # Entities, Use Cases (optional)
│   │   └── presentation/  # Screens, Widgets, Controllers
│   ├── home/
│   └── settings/
├── routing/
│   └── app_router.dart
└── main.dart
```

**Rule:** Every feature is self-contained. Cross-feature access goes through `core/` or exports.

---

## 🧅 The Layers (Clean Architecture Lite)

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Widgets, Controllers | Domain |
| **Domain** | Entities, Use Cases | Nothing (Pure Dart) |
| **Data** | Repositories, API Clients, Models | Domain (implements interfaces) |

---

## 📄 Implementing a Feature

### 1. Domain (The Contract)
```dart
// domain/entities/user.dart
class User {
  final String id;
  final String name;
  const User({required this.id, required this.name});
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<User> getUser(String id);
}
```

### 2. Data (The Implementation)
```dart
// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final ApiClient _api;
  UserRepositoryImpl(this._api);

  @override
  Future<User> getUser(String id) async {
    final dto = await _api.fetchUser(id);
    return User(id: dto.id, name: dto.name);
  }
}
```

### 3. Presentation (The UI)
```dart
// presentation/controllers/user_controller.dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<User> build(String userId) {
    return ref.read(userRepositoryProvider).getUser(userId);
  }
}
```

---

## 🔗 Dependency Injection

### Provider-Based (Riverpod)
```dart
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(apiClientProvider));
});
```

### Benefits
*   Testable: Swap real repo for mock in tests.
*   Decoupled: UI doesn't know about `ApiClient`.

---

## 🚦 Navigation (GoRouter)

```dart
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/user/:id', builder: (_, state) => UserPage(id: state.pathParameters['id']!)),
  ],
);
```

### Usage
```dart
context.go('/user/123');
```

---

## 🧪 Testability

| What | How |
|------|-----|
| **Controllers** | `ProviderContainer` with mocked deps |
| **Repositories** | Mock `ApiClient` |
| **Widgets** | `pumpWidget` with `ProviderScope` overrides |

---

## ⚠️ Anti-Patterns

| ❌ Bad | ✅ Good |
|--------|---------|
| Business logic in widgets | Logic in Notifiers/Use Cases |
| Direct API calls from UI | Call Repository from Controller |
| Global mutable state | Scoped providers |
| Circular dependencies | Layered architecture |
