# 📱 Platform Quirks Grimoire

> **Domain:** OEM-Specific Issues, Notification Fixes, Device Compatibility
> **Primary Agent:** Mobile Developer (`/mobile`)
> **Secondary:** Android Specialist (`/android`)

---

## 🔔 Xiaomi/MIUI/HyperOS Notification Fix

### Problem
Flutter apps using `flutter_local_notifications` fail to show scheduled notifications on Xiaomi devices due to aggressive battery optimization killing the app.

### Solution: Dual Scheduling Pattern

Use **both** `flutter_local_notifications` AND `android_alarm_manager_plus` for redundancy.

### Implementation

#### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  android_alarm_manager_plus: ^4.0.0
```

#### 2. Update AndroidManifest.xml

```xml
<manifest ...>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    
    <application ...>
        <!-- Alarm Manager Service -->
        <service
            android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmService"
            android:permission="android.permission.BIND_JOB_SERVICE"
            android:exported="false"/>
        
        <!-- Reboot Receiver - Critical for Xiaomi -->
        <receiver
            android:name="dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <!-- Alarm Receiver -->
        <receiver
            android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver"
            android:exported="false"/>
    </application>
</manifest>
```

#### 3. Notification Service with Dual Scheduling

```dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize Alarm Manager (for Xiaomi)
    await AndroidAlarmManager.initialize();

    // Initialize FLN
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _fln.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Schedule notification with DUAL methods
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Method 1: Standard FLN (works on most devices)
    await _fln.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Method 2: Alarm Manager (reliable on Xiaomi/MIUI)
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      _alarmCallback,
      alarmClock: true,  // Critical: Uses system alarm clock
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  /// Callback for Alarm Manager
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    // Show notification directly when alarm fires
    await _fln.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'Reminder',
      'Your scheduled reminder',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
```

#### 4. Request Exact Alarm Permission (Android 12+)

```dart
Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      // Android 12+ requires explicit permission
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        // Guide user to settings
        openAppSettings();
      }
    }
  }
}
```

---

## 🔋 Battery Optimization Bypass

### User Guidance Dialog

Show this dialog on first launch for Xiaomi/Huawei/Samsung devices:

```dart
void showBatteryOptimizationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enable Notifications'),
      content: const Text(
        'For reliable notifications, please disable battery optimization for this app.\n\n'
        '1. Go to Settings > Apps > [App Name]\n'
        '2. Tap Battery\n'
        '3. Select "Unrestricted"',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Open battery settings
            AppSettings.openBatteryOptimizationSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

## 📱 OEM Detection

```dart
Future<String> getDeviceManufacturer() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.manufacturer.toLowerCase();
  }
  return 'apple';
}

Future<bool> isXiaomiDevice() async {
  final manufacturer = await getDeviceManufacturer();
  return manufacturer.contains('xiaomi') ||
         manufacturer.contains('redmi') ||
         manufacturer.contains('poco');
}

Future<bool> isHuaweiDevice() async {
  final manufacturer = await getDeviceManufacturer();
  return manufacturer.contains('huawei') || manufacturer.contains('honor');
}
```

---

## 🐛 Known OEM Issues

| OEM | Issue | Workaround |
|-----|-------|------------|
| **Xiaomi/MIUI** | Kills background apps aggressively | Use `alarmClock: true`, prompt user for battery settings |
| **Huawei/EMUI** | Similar to Xiaomi | Same workarounds, also check HMS availability |
| **Samsung/OneUI** | Sleeping apps feature | Add to "Never sleeping apps" list |
| **Oppo/ColorOS** | Auto-start restrictions | Request auto-start permission |
| **Vivo/FuntouchOS** | Background restrictions | Whitelist in iManager |

---

## 📝 Testing Checklist for Notifications

- [ ] Test on stock Android (Pixel/Emulator)
- [ ] Test on Xiaomi device (or MIUI emulator)
- [ ] Test after device reboot
- [ ] Test after force-stopping app
- [ ] Test with battery optimization ON
- [ ] Test scheduled notification 1 hour ahead
- [ ] Test scheduled notification 24 hours ahead
