---
description: Essential Flutter patterns, widget lifecycle, and performance tips.
---

# Flutter Foundations Skill 💙

> **"Everything is a Widget. But not every Widget is good."**

## 🎯 Purpose
This skill provides the baseline knowledge for `mobile-developer.md`.

---

## 🏗️ Widget Lifecycle
Understanding `createState`, `mounted`, and `dispose` is critical.

### 1. The "mounted" Check
Always check `if (mounted)` before calling `setState` after an async operation.
```dart
await Future.delayed(Duration(seconds: 1));
if (mounted) {
  setState(() { ... });
}
```

### 2. Dispose Resources
Controllers (TextEditingController, AnimationController) must be disposed.
Use `flutter_hooks` to automate this if permitted by CTO.

---

## 🎨 Responsive Design
The app must work on iPhone SE (320px) and iPad Pro (1024px).

### 1. Use `LayoutBuilder`
For major layout changes (List vs Grid).

### 2. Use `Flexible` and `Expanded`
Never hardcode heights (`height: 500`). Let the UI breath.

---

## 🚀 Performance Tips

### 1. `const` Constructors
Use `const` everywhere. It tells Flutter "this widget never changes", allowing it to skip rebuilds.

### 2. `ListView.builder`
Never use `ListView(children: ...)` for dynamic lists. It builds everything at once.
Use `.builder` to build lazily.

### 3. Image Caching
Use `cached_network_image`. Never load raw URLs repeatedly.
