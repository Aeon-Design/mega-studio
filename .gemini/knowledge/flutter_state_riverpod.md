# 🔄 Flutter State Management (Riverpod) Grimoire

> **Owner:** Mobile Developer / Tech Lead
> **Purpose:** Mastering Riverpod 2.0 patterns for scalable, testable apps.

---

## 🧠 Core Concepts

| Concept | Description |
|---------|-------------|
| **Provider** | Declares state/logic accessible anywhere |
| **Ref** | Reads providers, watches for changes |
| **ConsumerWidget** | Widget that can `ref.watch` |
| **Notifier** | Class that holds mutable state |

---

## 📦 Provider Types

| Provider | Use Case |
|----------|----------|
| `Provider` | Computed/constant values |
| `StateProvider` | Simple mutable values (int, bool) |
| `FutureProvider` | Async one-shot data (fetch user) |
| `StreamProvider` | Real-time data (Firebase snapshots) |
| `NotifierProvider` | Complex mutable state with logic |
| `AsyncNotifierProvider` | Complex async state + logic |

---

## 🔧 Basic Usage

### Declaring a Provider
```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

### Reading in Widget
```dart
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### Modifying State
```dart
ref.read(counterProvider.notifier).state++;
```

---

## 🏗️ NotifierProvider (Recommended)

### Declaring Notifier
```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0; // Initial state

  void increment() => state++;
  void decrement() => state--;
}
```

### Usage
```dart
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).increment();
```

---

## 🌐 AsyncNotifierProvider (For API Calls)

### Declaring
```dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<User> build() async {
    return await ref.read(userRepositoryProvider).fetchUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(userRepositoryProvider).fetchUser());
  }
}
```

### UI Handling
```dart
ref.watch(userControllerProvider).when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

---

## 🔗 Provider Dependencies

```dart
final userIdProvider = StateProvider<String>((ref) => '123');

final userProvider = FutureProvider<User>((ref) async {
  final userId = ref.watch(userIdProvider); // Auto-refreshes when userId changes
  return await fetchUser(userId);
});
```

---

## 🧪 Testing Riverpod

```dart
void main() {
  test('counter increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });
}
```

---

## ⚠️ Best Practices

| ✅ Do | ❌ Don't |
|-------|---------|
| Use `ref.watch` for UI rebuilds | Use `ref.read` in `build()` (won't update) |
| Dispose resources in `Notifier` | Keep `ProviderScope` too narrow |
| Use `autoDispose` for temp data | Hold onto large state forever |
| Keep providers small and focused | Giant God-providers |
