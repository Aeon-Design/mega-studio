---
name: modern-flutter-stack
description: Mastery of the 2024-2025 Flutter tech stack including Riverpod 2.0+, GoRouter, Isar DB, and Impeller optimizations.
---

# 🛠️ Modern Flutter Stack (2025)

This skill defines the standard technology stack for all new Flutter development.

## 1. State Management: Riverpod 2.0+
**Why:** Provider is legacy. BLoC is for enterprise strictness. Riverpod is the default for type-safety and testability.
**Usage:**
- ALWAYS use `@riverpod` code generation.
- preferring `AsyncNotifier` for async state.
- Avoid `StateProvider`; use `Notifier` or `AsyncNotifier`.

```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build() async {
    return _fetchUser();
  }
}
```

## 2. Navigation: GoRouter
**Why:** Declarative routing is mandatory for Deep Linking and Auth redirects.
**Usage:**
- Define routes in a top-level provider.
- Use `context.go()` for logic branches, `context.push()` for drill-downs.

## 3. Local Database: Isar
**Why:** Faster than Hive, synchronous & asynchronous support, type-safe queries.
**Usage:**
- Use for caching, offline-first data.
- Run `dart run build_runner build` to generate schemas.

## 4. Rendering: Impeller
**Why:** Default engine in 2025. Eliminates shader jank.
**Optimization:**
- Avoid `SaveLayer` calls where possible.
- Use `RepaintBoundary` effectively.
- Prefer pre-compiled shaders (Frag) over complex CustomPainters if strictly visual.
