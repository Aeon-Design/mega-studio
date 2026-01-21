�# 📱 Mobile Engine Grimoire (Flutter & Native)

> **Owner:** Mobile Developer / Senior Flutter Dev
> **Purpose:** Deep technical specifications, performance tricks, and platform secrets.

## 🚀 Performance Optimization (Frame Perfect)

### 1. The "16ms" Rule
*   **Concept:** To achieve 60 FPS, every frame must render in < 16ms.
*   **Anti-Pattern:** Doing heavy computation (JSON parsing, image processing) in `build()`.
*   **Solution:** Use `compute()` or `Isolate.spawn()` for *anything* > 2ms.

### 2. RenderObject Excellence
*   **When to avoid Widgets:** When you need precise paint control or layout behavior not supported by Flex/Stack.
*   **Optimization:** Implement `RepaintBoundary` around complex sub-trees (Maps, Lists with images) to prevent parent rebuilding from repainting children.

### 3. Shader Warm-up (Skia/Impeller)
*   **Issue:** "Jank" on first run of an animation.
*   **Fix:** Pre-compile shaders or use `Impeller` (now default on iOS) to eliminate run-time compilation.

## 🛠️ State Management Patterns (Riverpod V2)

### 1. The "Controller-Service-Repository" Triad
*   **Presentation:** `AsyncNotifierProvider` (Controller). Handles UI state (Loading, Error, Data).
*   **Domain:** Pure Dart classes (Entities). `freezed` for immutability.
*   **Data:** Repository providers. Talk to API/DB.
*   **Rule:** UI never talks to Repository. UI talks to Controller.

## 🔒 Security Best Practices
1.  **NSAppTransportSecurity:** Always block HTTP (Allow Arbitrary Loads = NO).
2.  **FlutterSecureStorage:** Never store tokens in SharedPreferences.
3.  **Obfuscation:** Always build release with `--obfuscate --split-debug-info`.

## 🔄 Common Pitfalls & Fixes
| Symptom | Diagnosis | Fix |
| :--- | :--- | :--- |
| `Keyboard Overflows Pixel` | `Scaffold` resizing body. | Set `resizeToAvoidBottomInset: false` or wrap in `SingleChildScrollView`. |
| `Looking up a deactivated widget` | `context` usage across async gaps. | Check `mounted` before using `context` after `await`. |
| `Memory Leak in Image` | `Image.network` caching large images. | Use `ResizeImage` provider or cache width/height. |
�2<file:///c:/Users/Abdullah/.gemini/knowledge/mobile_engine.md