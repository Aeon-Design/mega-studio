¿5import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:adhan_life/core/services/storage_service.dart';
import 'package:adhan_life/app/providers.dart';

/// Notification Service for prayer time alerts
class NotificationService {
  final StorageService _storage;

  NotificationService(this._storage);

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap - navigate based on payload
  void _onNotificationTapped(NotificationResponse response) {
    // Deep-link navigation based on notification payload
    final payload = response.payload;
    debugPrint('Notification tapped with payload: $payload');
    
    // The actual navigation will happen in the router when app is opened
    // Since this service doesn't have BuildContext, we store the payload
    // and let the app handle navigation on launch.
    // For future: Use a global router key or stream to navigate.
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Schedule a prayer notification
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    String? adhanSound,
    bool playSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      sound: adhanSound != null
          ? RawResourceAndroidNotificationSound(adhanSound)
          : null,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time for $prayerName',
      'It\'s time for $prayerName prayer',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: prayerName,
    );
  }

  /// Schedule all daily prayer notifications
  Future<void> scheduleAllPrayerNotifications({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    String? adhanSound, // Deprecated/Fallback
  }) async {
    // Cancel existing notifications
    await cancelAllNotifications();

    // Helper to schedule if enabled
    Future<void> scheduleIfEnabled(int id, String name, DateTime time) async {
      final isEnabled = _storage.getPrayerNotificationEnabled(name);
      if (isEnabled) {
         // Get sound from storage (e.g. 'makkah', 'beep', 'silent') or generic fallback
         final soundKey = _storage.getPrayerSound(name);
         // Map soundKey to actual resource/asset path if needed, 
         // OR pass 'soundKey' if NotificationDetails logic handles it.
         // For now, assuming soundKey maps to RawResource name.
         // 'silent' means playSound = false
         
         final playSound = soundKey != 'silent';
         final actualSound = playSound ? soundKey : null;

         await schedulePrayerNotification(
          id: id,
          prayerName: name,
          scheduledTime: time,
          adhanSound: actualSound,
          playSound: playSound,
        );
      }
    }

    await scheduleIfEnabled(1, 'Fajr', fajr);
    await scheduleIfEnabled(2, 'Dhuhr', dhuhr);
    await scheduleIfEnabled(3, 'Asr', asr);
    await scheduleIfEnabled(4, 'Maghrib', maghrib);
    await scheduleIfEnabled(5, 'Isha', isha);
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'Notifications are working correctly!',
      details,
    );
  }
}

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationService(storage);
});
¿5"(ad531abe872c7cf491ed881344a14c5a674c9d842cfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/services/notification_service.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life