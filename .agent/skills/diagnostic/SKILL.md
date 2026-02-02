---
name: "Diagnostic"
version: "1.0.0"
description: |
  Flutter debugging and diagnostic patterns.
  Memory leaks, performance profiling, deep link debugging.
  Tetikleyiciler: "debug", "memory", "leak", "performance", "profil", "crash", "error"
---

# Flutter Diagnostic

## Amaç
Hata ayıklama ve performans analizi.

---

## Memory Leak Detection

### Common Leak Sources
1. **Stream subscriptions not cancelled**
2. **Timer not cancelled**
3. **AnimationController not disposed**
4. **BuildContext used after dispose**
5. **Static references to widgets**

### Leak Prevention Pattern
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;
  Timer? _timer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen(_onData);
    _timer = Timer.periodic(duration, _onTick);
    _animController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _subscription.cancel();    // ✓ Stream cancelled
    _timer?.cancel();          // ✓ Timer cancelled  
    _animController.dispose(); // ✓ Animation disposed
    super.dispose();
  }
}
```

---

## Performance Profiling

### Frame Timing
```dart
// Enable in main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show performance overlay
  runApp(MaterialApp(
    showPerformanceOverlay: true,
    home: MyApp(),
  ));
}
```

### Custom Timeline Events
```dart
import 'dart:developer';

void expensiveOperation() {
  Timeline.startSync('expensiveOperation');
  try {
    // Heavy work
  } finally {
    Timeline.finishSync();
  }
}
```

### Build Tracking
```dart
class BuildTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building ${widget.runtimeType}');
    return child;
  }
}
```

---

## Deep Link Debugging

### Setup
```dart
// Android: android/app/src/main/AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="myapp" android:host="open"/>
</intent-filter>
```

### Debug Handler
```dart
class DeepLinkDebugger {
  static void init() {
    // Log all incoming links
    GoRouter.of(context).routerDelegate.addListener(() {
      final location = GoRouter.of(context).location;
      debugPrint('🔗 Navigation: $location');
    });
  }
  
  static void testDeepLink(String uri) {
    debugPrint('🧪 Testing deep link: $uri');
    try {
      final parsedUri = Uri.parse(uri);
      debugPrint('  Scheme: ${parsedUri.scheme}');
      debugPrint('  Host: ${parsedUri.host}');
      debugPrint('  Path: ${parsedUri.path}');
      debugPrint('  Params: ${parsedUri.queryParameters}');
    } catch (e) {
      debugPrint('  ❌ Parse error: $e');
    }
  }
}
```

---

## Crash Reporting Setup

### Firebase Crashlytics
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Catch Flutter errors
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  
  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}
```

---

## Network Debugging

### HTTP Interceptor
```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('📤 ${options.method} ${options.uri}');
    debugPrint('   Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('   Body: ${options.data}');
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('📥 ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ${err.type} ${err.requestOptions.uri}');
    debugPrint('   ${err.message}');
    handler.next(err);
  }
}
```

---

## State Debugging

### BLoC Observer
```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('📦 ${bloc.runtimeType} $change');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('❌ ${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}

// In main.dart
Bloc.observer = AppBlocObserver();
```

---

## DevTools Integration

### Logging
```dart
import 'dart:developer' as developer;

void logInfo(String message) {
  developer.log(message, name: 'MyApp');
}

void logError(Object error, StackTrace stack) {
  developer.log(
    'Error occurred',
    name: 'MyApp',
    error: error,
    stackTrace: stack,
    level: 1000, // Error level
  );
}
```

### Debugger Breakpoint
```dart
import 'dart:developer';

void suspiciousFunction() {
  debugger(when: someCondition, message: 'Check this!');
}
```

---

## Debug Utilities

```dart
class DebugUtils {
  static void printWidgetTree(BuildContext context) {
    debugDumpApp();
  }
  
  static void printRenderTree() {
    debugDumpRenderTree();
  }
  
  static void printLayerTree() {
    debugDumpLayerTree();
  }
  
  static void printFocusTree() {
    debugDumpFocusTree();
  }
}
```

---

## Checklist

- [ ] All subscriptions cancelled in dispose
- [ ] All timers cancelled
- [ ] AnimationControllers disposed
- [ ] Crashlytics configured
- [ ] Network logging in debug mode
- [ ] BLoC observer active
- [ ] Memory profiling done before release
