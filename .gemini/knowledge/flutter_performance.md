# ⚡ Flutter Performance Grimoire

> **Owner:** Performance Optimizer / Mobile Developer
> **Purpose:** Diagnosing and fixing performance issues to achieve 60 FPS.

---

## 🧠 The Two Threads

| Thread | Job | Jank Symptom |
|--------|-----|--------------|
| **UI Thread** | Dart code, layout, semantics | Frame drops, slow scrolling |
| **Raster Thread** | Paint, compositing, GPU upload | Stuttering during transitions |

**Rule:** Keep both threads under 16ms per frame.

---

## 🔍 DevTools Performance Tab

### How to Profile
1.  Run in **Profile Mode**: `flutter run --profile`
2.  Open DevTools → Performance Tab
3.  Record a session
4.  Identify red frames (>16ms)

### Reading the Timeline
*   **Build Phase:** Widget tree construction (Dart).
*   **Layout Phase:** Size/position calculation.
*   **Paint Phase:** Drawing to layers.
*   **Raster Phase:** GPU compositing.

---

## 🩺 Common Jank Causes & Fixes

### 1. Expensive Build
*   **Cause:** Heavy computation in `build()`.
*   **Fix:** Move to `initState()` or use `compute()` isolate.

### 2. Unnecessary Rebuilds
*   **Cause:** `setState()` on large subtree.
*   **Fix:** Use `const` widgets. Split into smaller widgets. Use `Selector` in Provider.

### 3. Overdraw
*   **Cause:** Stacking multiple opaque widgets.
*   **Fix:** Remove unnecessary `Container` backgrounds.

### 4. Shader Compilation Jank
*   **Cause:** First-time animation compiles shaders.
*   **Fix:** Use Impeller (default on iOS). Pre-warm shaders.

---

## 🖼️ Image Optimization

### Use `ResizeImage` / `cacheWidth`
```dart
Image.network(
  url,
  cacheWidth: 200, // Decode at lower resolution
)
```

### Cache with `CachedNetworkImage`
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => Shimmer(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
)
```

---

## 📜 ListView Optimization

### Use `ListView.builder`
*   Builds items lazily.
*   Recycles widgets.

### Use `itemExtent` or `prototypeItem`
```dart
ListView.builder(
  itemExtent: 72, // Fixed height = faster layout
  itemBuilder: (_, i) => ListTile(...),
)
```

### Use `addAutomaticKeepAlives: false`
*   Prevents caching off-screen items (saves memory).

---

## 🧪 Impeller (The Future)

*   **iOS:** Enabled by default.
*   **Android:** Experimental. Enable with `--enable-impeller`.
*   **Benefit:** Pre-compiled shaders = No jank on first animation.

---

## ⚠️ Memory Leaks

### Detection
1.  DevTools → Memory Tab
2.  Take Snapshot
3.  Perform action
4.  Take Snapshot
5. Compare: Are old objects still alive?

### Common Causes
*   Listeners not removed in `dispose()`.
*   `StreamController` not closed.
*   `AnimationController` not disposed.
