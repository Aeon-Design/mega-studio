---
description: Managing application state. Riverpod focus (default), but applicable to Bloc/Provider.
---

# State Management Skill 🧠

> **"State is the root of all evil. Manage it wisely."**

## 🎯 Purpose
To prevent "Jank" and "Spaghetti Code" caused by passing data through 10 layers of widgets.

---

## 🌊 Riverpod Guidelines (The Studio Standard)

### 1. No "Global Providers" for Local State
If it's only used in one screen, keep it in a `ConsumerStatefulWidget` or a local provider.

### 2. `ref.watch` vs `ref.read`
-   **Inside `build()`:** ALWAYS use `ref.watch`. This ensures the UI updates when data changes.
-   **Inside functions (onTap):** ALWAYS use `ref.read`. We just want the value once.

### 3. AsyncValue Handling
Always handle all 3 states:
```dart
final data = ref.watch(myProvider);
return data.when(
  data: (value) => Text(value),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

## 🔄 General Principles

### 1. Immutable State
State objects should be immutable (`@freezed`).
Never do `state.count++`. Do `state = state.copyWith(count: state.count + 1)`.

### 2. Separation of Concerns
-   **UI:** Shows the state.
-   **Notifier:** Changes the state.
-   **Repository:** Fetches the state.
