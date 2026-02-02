---
name: "Concurrency"
version: "1.0.0"
description: |
  Dart concurrency patterns: Isolates, compute, async/await.
  Adapted from Swift Concurrency patterns.
  Tetikleyiciler: "isolate", "compute", "async", "parallel", "background", "thread"
---

# Flutter Concurrency

## Amaç
Performanslı, non-blocking async patterns.

---

## Async/Await Basics

```dart
// Sequential
Future<void> loadData() async {
  final user = await fetchUser();
  final posts = await fetchPosts(user.id);
  final comments = await fetchComments(posts.first.id);
}

// Parallel
Future<void> loadDataParallel() async {
  final results = await Future.wait([
    fetchUser(),
    fetchConfig(),
    fetchNotifications(),
  ]);
}
```

---

## Compute (Simple Background)

```dart
import 'package:flutter/foundation.dart';

// Heavy computation
Future<List<ProcessedItem>> processItems(List<RawItem> items) {
  return compute(_processItemsIsolate, items);
}

List<ProcessedItem> _processItemsIsolate(List<RawItem> items) {
  return items.map((item) => ProcessedItem.from(item)).toList();
}
```

---

## Isolate.run (Dart 2.19+)

```dart
Future<String> parseJson(String json) async {
  return await Isolate.run(() {
    final data = jsonDecode(json);
    return processData(data);
  });
}
```

---

## Long-Running Isolate

```dart
class BackgroundProcessor {
  late Isolate _isolate;
  late SendPort _sendPort;
  final _receivePort = ReceivePort();
  
  Future<void> start() async {
    _isolate = await Isolate.spawn(
      _isolateEntry,
      _receivePort.sendPort,
    );
    _sendPort = await _receivePort.first;
  }
  
  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) {
      // Process message
      final result = heavyComputation(message);
      mainSendPort.send(result);
    });
  }
  
  Future<T> process<T>(dynamic data) async {
    _sendPort.send(data);
    return await _receivePort.first;
  }
  
  void stop() {
    _isolate.kill();
    _receivePort.close();
  }
}
```

---

## Stream Processing

```dart
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Usage
await for (final count in countDown(10)) {
  print(count);
}
```

---

## Completer Pattern

```dart
class AsyncOperation {
  final _completer = Completer<String>();
  
  Future<String> get result => _completer.future;
  
  void complete(String value) {
    if (!_completer.isCompleted) {
      _completer.complete(value);
    }
  }
  
  void error(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }
}
```

---

## Debounce & Throttle

```dart
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

class Throttler {
  final Duration interval;
  DateTime? _lastAction;
  
  Throttler({this.interval = const Duration(milliseconds: 300)});
  
  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastAction == null || 
        now.difference(_lastAction!) >= interval) {
      _lastAction = now;
      action();
    }
  }
}
```

---

## Cancelable Operation

```dart
class CancelableOperation<T> {
  bool _isCanceled = false;
  
  Future<T?> run(Future<T> Function() operation) async {
    try {
      final result = await operation();
      if (_isCanceled) return null;
      return result;
    } catch (e) {
      if (_isCanceled) return null;
      rethrow;
    }
  }
  
  void cancel() {
    _isCanceled = true;
  }
}
```

---

## Best Practices

### 1. compute vs Isolate.run
| Use Case | Recommendation |
|----------|---------------|
| One-off heavy task | `Isolate.run` |
| Repeated same task | `compute` |
| Continuous processing | Long-running Isolate |
| Simple async | `async/await` |

### 2. UI Thread Protection
```dart
// YANLIŞ - UI thread'i bloklar
final data = jsonDecode(hugeJson);

// DOĞRU - Background'da işle
final data = await Isolate.run(() => jsonDecode(hugeJson));
```

### 3. Error Handling
```dart
try {
  final result = await compute(riskyOperation, data);
} on IsolateSpawnException {
  // Isolate spawn failed
} catch (e) {
  // Operation failed
}
```

---

## Checklist

- [ ] Heavy operations use compute/Isolate
- [ ] Parallel loads use Future.wait
- [ ] Streams properly closed
- [ ] Debounce on search/input
- [ ] Throttle on scroll/resize
- [ ] Cancelable operations for navigation
