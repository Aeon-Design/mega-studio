# 🔒 Security Hardening Skill

> OWASP Mobile Top 10, encryption, obfuscation, certificate pinning

---

## Güvenlik Kontrol Listesi

### Release Öncesi Zorunlu Kontroller
- [ ] Tüm API key'leri `--dart-define` ile enjekte ediliyor
- [ ] `flutter_secure_storage` ile hassas veriler korunuyor
- [ ] `--obfuscate` flag'i aktif
- [ ] ProGuard/R8 kuralları tanımlı
- [ ] Debug log'lar release'de devre dışı
- [ ] HTTP trafiği sadece HTTPS (cleartext kapalı)
- [ ] Root/Jailbreak detection var
- [ ] Screenshot protection (hassas ekranlar)
- [ ] Certificate pinning aktif
- [ ] Input validation tüm formlarda var

---

## Güvenli Veri Depolama

```dart
/// Veri sınıflandırması ve depolama stratejisi:
///
/// HASSAS (token, şifre, kişisel)    → FlutterSecureStorage
/// NORMAL (tercihler, cache)          → SharedPreferences / Hive
/// BÜYÜK (veritabanı)                → Drift + SQLCipher
/// DOSYA (indirilen medya)           → App Documents Directory

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'com.yourapp.secure',
    ),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  Future<String?> getToken() =>
      _storage.read(key: 'auth_token');

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: 'refresh_token', value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  Future<void> clearAll() => _storage.deleteAll();
}
```

---

## Root/Jailbreak Detection

```dart
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class DeviceSecurityService {
  Future<bool> isDeviceCompromised() async {
    final jailbroken = await FlutterJailbreakDetection.jailbroken;
    final developerMode = await FlutterJailbreakDetection.developerMode;
    return jailbroken || developerMode;
  }

  Future<void> enforceSecurityPolicy() async {
    if (await isDeviceCompromised()) {
      // Uyarı göster veya hassas özellikleri devre dışı bırak
      // Production'da: kritik özellikler kısıtlanır
    }
  }
}
```

---

## Screenshot ve Screen Recording Koruması

```dart
// Android: FLAG_SECURE
// ios/Runner/AppDelegate.swift içinde:
/*
override func applicationWillResignActive(_ application: UIApplication) {
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window!.frame
    blurView.tag = 999
    window?.addSubview(blurView)
}

override func applicationDidBecomeActive(_ application: UIApplication) {
    window?.viewWithTag(999)?.removeFromSuperview()
}
*/

// Flutter tarafında MethodChannel ile:
class ScreenSecurityService {
  static const _channel = MethodChannel('screen_security');

  static Future<void> enableSecureMode() async {
    await _channel.invokeMethod('enableSecure');
  }

  static Future<void> disableSecureMode() async {
    await _channel.invokeMethod('disableSecure');
  }
}
```

---

## API Key Güvenliği

```dart
// ❌ ASLA — Koda gömme
const apiKey = 'sk-1234567890abcdef';

// ✅ DOĞRU — Compile-time injection
class ApiConfig {
  static const baseUrl = String.fromEnvironment('BASE_URL');
  static const apiKey = String.fromEnvironment('API_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
}

// Build komutu:
// flutter build apk --dart-define=API_KEY=sk-1234 --dart-define=BASE_URL=https://api.app.com
```

---

## Android Güvenlik Konfigürasyonu

### network_security_config.xml
```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Cleartext (HTTP) trafiğini engelle -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>

    <!-- Debug build için localhost izni -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user"/>
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

### AndroidManifest.xml
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:allowBackup="false"
    android:fullBackupContent="false"
    ...>
```

### ProGuard Kuralları
```
# android/app/proguard-rules.pro
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Retrofit
-keepattributes Signature
-keepattributes Exceptions
```

---

## iOS Güvenlik Konfigürasyonu

### Info.plist
```xml
<!-- App Transport Security -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- Sadece gerekli domain'lere izin ver -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.yourapp.com</key>
        <dict>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>

<!-- Clipboard erişimi açıklaması -->
<key>NSPasteboardUsageDescription</key>
<string>Kopyalanan içeriği yapıştırmak için</string>
```

---

## Güvenli Logging

```dart
// lib/core/utils/secure_logger.dart
import 'package:logger/logger.dart';

class SecureLogger {
  static final _logger = Logger(
    filter: _SecureFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
    ),
  );

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Hassas verileri maskele
  static String mask(String value) {
    if (value.length <= 4) return '****';
    return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}

class _SecureFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Release modda sadece error ve warning logla
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
```
