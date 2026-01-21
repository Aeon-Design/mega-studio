# 🔌 Flutter Platform Channels Grimoire

> **Owner:** Mobile Developer / Android Specialist
> **Purpose:** Native iOS & Android integration via MethodChannel, EventChannel, and Pigeon.

---

## 📡 Channel Types

| Channel | Direction | Use Case |
|---------|-----------|----------|
| `MethodChannel` | Dart ↔ Native | One-shot calls (get battery level) |
| `EventChannel` | Native → Dart | Streams (sensor data, Bluetooth) |
| `BasicMessageChannel` | Bidirectional | Raw message passing |

---

## 📞 MethodChannel (Request-Response)

### Dart Side
```dart
const channel = MethodChannel('com.example.app/battery');

Future<int> getBatteryLevel() async {
  try {
    final int result = await channel.invokeMethod('getBatteryLevel');
    return result;
  } on PlatformException catch (e) {
    print('Failed: ${e.message}');
    return -1;
  }
}
```

### Android Side (Kotlin)
```kotlin
class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.example.app/battery"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        if (call.method == "getBatteryLevel") {
          val level = getBatteryLevel()
          result.success(level)
        } else {
          result.notImplemented()
        }
      }
  }
}
```

### iOS Side (Swift)
```swift
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.app/battery", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { (call, result) in
      if call.method == "getBatteryLevel" {
        result(UIDevice.current.batteryLevel * 100)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 📡 EventChannel (Streams)

### Dart Side
```dart
const eventChannel = EventChannel('com.example.app/sensors');

Stream<dynamic> get sensorStream => eventChannel.receiveBroadcastStream();

// Usage
sensorStream.listen((event) {
  print('Sensor data: $event');
});
```

### Android Side (Kotlin)
```kotlin
EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/sensors")
  .setStreamHandler(object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      // Start sending events
      sensorManager.registerListener(object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
          events?.success(event?.values?.toList())
        }
      }, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onCancel(arguments: Any?) {
      // Stop sensor
    }
  })
```

---

## 🐦 Pigeon (Type-Safe Code Generation)

### Why Pigeon?
*   No string-based method names.
*   Type-safe data classes.
*   Auto-generates Dart, Kotlin, Swift code.

### Setup
```yaml
dev_dependencies:
  pigeon: ^17.0.0
```

### Define API (pigeons/messages.dart)
```dart
import 'package:pigeon/pigeon.dart';

class Book {
  String? title;
  String? author;
}

@HostApi()
abstract class BookApi {
  Book getBook(String id);
}
```

### Generate
```bash
flutter pub run pigeon --input pigeons/messages.dart
```

---

## 🔧 FFI (Foreign Function Interface)

### For C/C++ Libraries
```dart
import 'dart:ffi';

final DynamicLibrary nativeLib = Platform.isAndroid
    ? DynamicLibrary.open('libnative.so')
    : DynamicLibrary.process();

typedef AddFunc = Int32 Function(Int32 a, Int32 b);
typedef Add = int Function(int a, int b);

final Add add = nativeLib.lookupFunction<AddFunc, Add>('add');
print(add(2, 3)); // 5
```

---

## ⚠️ Debugging Tips

1.  **Channel Name Mismatch:** Most common error. Copy-paste exact string.
2.  **Threading:** Native calls run on Platform Thread. Offload heavy work.
3.  **Error Handling:** Always use `result.error()` on native, `try-catch` on Dart.
