---
name: advanced-debugging-suite
description: Deep diagnostics using Leak Tracking, DevTools Extensions, and Custom Tracing.
---

# 🐛 Advanced Debugging Suite

## 💧 Memory Leak Tracking
Leaks cause crashes. Find them early.
- **Tool:** `leak_tracker` (built-in to Flutter test).
- **Implementation:**
```dart
testWidgets('Memory leak check', (widgetTester) async {
  await widgetTester.pumpWidget(MyApp());
  // ... interactions ...
  await widgetTester.pumpWidget(Container()); // Dispose everything
  expect(LeakTracker.leaks, isEmpty);
});
```

## 🛠️ DevTools Extensions
2025's superpower.
- **Provider/Riverpod/Bloc:** Use their dedicated tabs in DevTools to inspect state history.
- **Drift/Isar:** Inspect database tables live without exporting `.db` files.
- **Network Profiler:** Inspect full JSON body of requests/responses.

## ⏱️ Performance Tracing
- **Frame Timing:** Identify frames > 16ms (Jank).
- **Custom Spans:** Add `Timeline.startSync('MyCostlyOp')` to visualize your algorithm's cost in the CPU profiler.
- **Repaint Rainbow:** Enable to see excessive repainting of layers.
