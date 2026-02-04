---
name: flutter-visual-mastery
description: Creating high-end visual experiences using Shaders (GLSL), Impeller capabilities, and advanced animations.
---

# 🎨 Flutter Visual Mastery

## 🌈 Fragment Shaders (GLSL)
With Impeller, Shaders are first-class citizens.
- **Use Case:** Complex gradients, blur effects, noise, distortion, "frosted glass".
- **Tool:** `.frag` files.
- **Usage:**
    1.  Write GLSL code.
    2.  Compiles to SPIR-V automatically in Flutter 3.x.
    3.  Load with `FragmentProgram.fromAsset`.
    4.  Paint on a `CustomPainter`.

## 🏎️ Impeller Best Practices
- **Pre-warming:** While Impeller reduces compilation jank, "warming" complex shaders on startup is still a good safety net for older devices.
- **Profiling:** Use DevTools "Impeller" tab to find unnecessary save layers.

## 🎬 Advanced Animation
- **Rive:** For interactive vector animations (state machines).
- **Lottie:** For complex After Effects exports.
- **Flutter Animate:** For code-based sequence animations (`.fadeIn().scale()`).
