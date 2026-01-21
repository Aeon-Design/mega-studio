# 🎬 Flutter Animations Grimoire

> **Owner:** Mobile Developer / Head of UX
> **Purpose:** Mastery of motion design, from implicit to explicit animations, Rive, and Lottie.

---

## 🎭 The Animation Spectrum

| Type | Control | Use Case |
|------|---------|----------|
| **Implicit** | Low | Simple transitions (fade, slide) |
| **Explicit** | High | Complex, sequenced animations |
| **Physics-based** | Natural | Spring, friction, gravity |
| **Rive/Lottie** | Designer | Complex vector animations |

---

## 🔮 Implicit Animations (The Easy Path)

### The Pattern
Replace any widget with its `Animated` counterpart.

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _expanded ? 200 : 100,
  color: _expanded ? Colors.blue : Colors.red,
)
```

### The Family
`AnimatedOpacity`, `AnimatedPositioned`, `AnimatedPadding`, `AnimatedSwitcher`, `AnimatedCrossFade`, `TweenAnimationBuilder`.

---

## 🎛️ Explicit Animations (Full Control)

### The Controller Pattern
```dart
class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Staggered Animations
```dart
final opacityTween = Tween(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)),
);
final scaleTween = Tween(begin: 0.5, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0)),
);
```

---

## 🦸 Hero Transitions

### Basic Hero
```dart
// Page 1
Hero(tag: 'avatar', child: CircleAvatar(backgroundImage: ...))

// Page 2
Hero(tag: 'avatar', child: Image.network(...))
```

### Custom Flight
```dart
Hero(
  tag: 'avatar',
  flightShuttleBuilder: (context, anim, direction, from, to) {
    return ScaleTransition(scale: anim, child: from.widget);
  },
)
```

---

## 🎨 Rive Integration

### Setup
```yaml
dependencies:
  rive: ^0.13.0
```

### Usage
```dart
RiveAnimation.asset(
  'assets/animation.riv',
  artboard: 'New Artboard',
  animations: ['idle'],
  onInit: (artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
  },
)
```

### State Machine Input
```dart
final trigger = controller.findInput<bool>('isPressed') as SMIBool;
trigger.value = true; // Triggers animation
```

---

## 🎥 Lottie Integration

### Setup
```yaml
dependencies:
  lottie: ^3.0.0
```

### Usage
```dart
Lottie.asset(
  'assets/animation.json',
  controller: _controller,
  onLoaded: (composition) {
    _controller.duration = composition.duration;
    _controller.forward();
  },
)
```

---

## ⚡ Performance Rules

1.  **RepaintBoundary:** Wrap animated widgets to isolate repaints.
2.  **`addPostFrameCallback`:** Schedule animations after build.
3.  **Avoid `setState` in listeners:** Use `AnimatedBuilder` instead.
4.  **Pre-warm shaders:** Use `ShaderWarmUp` for complex effects.
