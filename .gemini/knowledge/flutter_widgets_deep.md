# 🧱 Flutter Widgets Deep Grimoire

> **Owner:** Mobile Developer / Tech Lead
> **Purpose:** Mastery of the Widget layer, RenderObjects, and advanced composition patterns.

---

## 🎯 The Widget Tree Mental Model

### 1. The Three Trees
*   **Widget Tree:** Blueprint (immutable, cheap to rebuild).
*   **Element Tree:** Manager (long-lived, handles lifecycle).
*   **RenderObject Tree:** Painter (layout, paint, hit-testing).

### 2. Keys: The Identity Card
*   **GlobalKey:** Access state from anywhere. Heavy. Use sparingly.
*   **ValueKey:** Identifies by value (`ValueKey(item.id)`).
*   **ObjectKey:** Identifies by object instance.
*   **UniqueKey:** Forces new state. Use for list shuffling.

**Rule:** Always use Keys in `ListView.builder` when items can reorder.

---

## 🔧 Custom RenderObject (The Nuclear Option)

### When to Use
*   When `CustomPaint` isn't enough (need custom layout).
*   When performance is critical (bypass Widget overhead).

### The Recipe
```dart
class MyRenderBox extends RenderBox {
  @override
  void performLayout() {
    size = constraints.biggest; // Or calculate manually
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    // Draw directly to canvas
  }
}
```

### The Widget Wrapper
```dart
class MyWidget extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) => MyRenderBox();
}
```

---

## 🎨 CustomPainter Mastery

### Basic Structure
```dart
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(size.center(Offset.zero), 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### Performance Tips
*   **`shouldRepaint`:** Return `false` if nothing changed. Compare properties.
*   **`RepaintBoundary`:** Wrap expensive painters to isolate repaints.
*   **Caching:** Use `Picture` and `PictureRecorder` for complex static shapes.

---

## 🌊 Slivers: The Scroll Titans

### Core Slivers
| Sliver | Use Case |
|--------|----------|
| `SliverList` | Variable height items |
| `SliverFixedExtentList` | Fixed height (faster) |
| `SliverGrid` | Grid layout |
| `SliverAppBar` | Collapsing header |
| `SliverToBoxAdapter` | Embed a normal widget |
| `SliverPersistentHeader` | Sticky headers |

### The Pattern
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(expandedHeight: 200, floating: true),
    SliverList(delegate: SliverChildBuilderDelegate(...)),
  ],
)
```

---

## 🧬 InheritedWidget & InheritedModel

### InheritedWidget (Global Data)
```dart
class MyData extends InheritedWidget {
  final int value;
  const MyData({required this.value, required super.child});

  static MyData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyData>()!;

  @override
  bool updateShouldNotify(MyData old) => old.value != value;
}
```

### InheritedModel (Selective Rebuild)
*   Use when widget depends on only *part* of the data.
*   Prevents unnecessary rebuilds of unrelated widgets.

---

## ⚠️ Anti-Patterns

| ❌ Bad | ✅ Good |
|--------|---------|
| Building widgets in `initState` | Build in `build()` method |
| Storing `BuildContext` in variables | Pass context through methods |
| Using `GlobalKey` everywhere | Use `ValueKey` or `ObjectKey` |
| Nesting 10+ widgets deep | Extract into named widgets |
