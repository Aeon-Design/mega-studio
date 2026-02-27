---
name: advanced-motion-rive
description: Implementing interactive, state-machine driven animations using Rive 2 and Flutter.
---

# 🎬 Advanced Motion with Rive 2

## 🧠 State Machines
Animations are no longer linear; they are interactive.
- **Logic in Rive:** Designers define transition logic (e.g., `is_playing`, `health_level`).
- **Bridge in Flutter:** Use `StateMachineController` to set values at runtime.

## ⚡ Performance Best Practices
- **Lazy Loading:** Do not load large `.riv` files on app startup. Load on demand.
- **Texture Compression:** Ensure Rive assets are packaged efficiently for iOS/Android.
- **Minimize Paths:** Audit artboards to reduce node count for 60/120 FPS performance.

## 🎼 Blend Trees
- Use for character movements or complex state transitions where multiple animations blend based on a variable (e.g., `speed`).

## 🛠️ Implementation Snippet
```dart
void _onRiveInit(Artboard artboard) {
  final controller = StateMachineController.fromArtboard(artboard, 'MainState');
  artboard.addController(controller!);
  _trigger = controller.findInput<bool>('isPressed') as SMITrigger;
}
```
