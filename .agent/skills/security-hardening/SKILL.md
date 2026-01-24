---
name: "Security Hardening"
version: "1.0.0"
description: "OWASP Mobile Top 10, secure storage, network security, and code obfuscation"
primary_users:
  - security-auditor
  - mobile-developer
dependencies:
  - flutter-foundations
tags:
  - security
  - quality
---

# 🔒 Security Hardening

## Quick Start

Mobile uygulama güvenliği: veri şifreleme, güvenli depolama, network security ve kod koruması.
OWASP Mobile Top 10'u referans al.

---

## 📚 OWASP Mobile Top 10 (2024)

| # | Risk | Flutter Çözümü |
|---|------|----------------|
| M1 | Improper Credential Usage | flutter_secure_storage |
| M2 | Inadequate Supply Chain | Dependency scanning |
| M3 | Insecure Auth/Authorization | JWT + refresh tokens |
| M4 | Insufficient I/O Validation | Input sanitization |
| M5 | Insecure Communication | TLS 1.3, cert pinning |
| M6 | Inadequate Privacy Controls | Data minimization |
| M7 | Insufficient Binary Protection | Code obfuscation |
| M8 | Security Misconfiguration | Proper build config |
| M9 | Insecure Data Storage | Encrypted storage |
| M10 | Insufficient Cryptography | Strong algorithms |

---

## 🔐 1. Güvenli Depolama

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Token storage
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }
  
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  // Biometric protected storage
  Future<void> saveSensitiveData(String key, String value) async {
    await _storage.write(
      key: key,
      value: value,
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.when_passcode_set_this_device_only,
      ),
    );
  }
}
```

### Ne nerede saklanmalı?

| Veri Türü | Depolama | Şifreleme |
|-----------|----------|-----------|
| Access Token | SecureStorage | ✅ |
| Refresh Token | SecureStorage | ✅ |
| User Preferences | SharedPreferences | ❌ |
| Cached API Data | Hive/Drift (encrypted) | ✅ |
| Sensitive User Data | SecureStorage | ✅ |
| App Settings | SharedPreferences | ❌ |

---

## 🌐 2. Network Security

### Certificate Pinning

```dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

Dio createSecureDio() {
  final dio = Dio();
  
  // Certificate pinning
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Pinned certificate fingerprints
      const pinnedFingerprints = [
        'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ];
      
      final fingerprint = cert.sha256Fingerprint;
      return pinnedFingerprints.contains(fingerprint);
    };
    return client;
  };
  
  return dio;
}
```

### API Security Headers

```dart
class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Security headers
    options.headers.addAll({
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    });
    
    // Request signing (optional)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _signRequest(options, timestamp);
    options.headers['X-Timestamp'] = timestamp;
    options.headers['X-Signature'] = signature;
    
    handler.next(options);
  }
  
  String _signRequest(RequestOptions options, String timestamp) {
    final payload = '${options.method}|${options.path}|$timestamp';
    return HmacUtils.sha256(payload, secretKey);
  }
}
```

---

## 🔑 3. Authentication Security

### JWT Token Management

```dart
class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;
  
  // Token refresh with retry queue
  bool _isRefreshing = false;
  final _refreshQueue = <Completer<String>>[];
  
  Future<String?> getValidAccessToken() async {
    final accessToken = await _storage.getAccessToken();
    
    if (accessToken == null) return null;
    
    if (_isTokenExpired(accessToken)) {
      return _refreshToken();
    }
    
    return accessToken;
  }
  
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      
      // 5 dakika buffer
      return DateTime.now().isAfter(expiry.subtract(Duration(minutes: 5)));
    } catch (e) {
      return true;
    }
  }
  
  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshQueue.add(completer);
      return completer.future;
    }
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await _storage.getRefreshToken();
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      
      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      
      // Queue'daki bekleyenlere bildir
      for (final completer in _refreshQueue) {
        completer.complete(newAccessToken);
      }
      _refreshQueue.clear();
      
      return newAccessToken;
    } catch (e) {
      for (final completer in _refreshQueue) {
        completer.completeError(e);
      }
      _refreshQueue.clear();
      
      await _storage.clearTokens();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
```

---

## 🛡️ 4. Input Validation

```dart
class InputValidator {
  // SQL Injection prevention
  static String sanitizeSql(String input) {
    return input.replaceAll(RegExp(r"['\";]"), '');
  }
  
  // XSS prevention
  static String sanitizeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
  
  // Email validation
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
  
  // Phone validation (Turkey)
  static bool isValidTurkishPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^(90)?5\d{9}$').hasMatch(cleaned);
  }
  
  // Password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;
    
    int score = 0;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 12) score++;
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}
```

---

## 🔧 5. Code Obfuscation

```bash
# Android - build.gradle (app)
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

# Flutter build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

```pro
# proguard-rules.pro
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
```

---

## ✅ Security Checklist

### Data Storage
- [ ] Sensitive data SecureStorage'da mı?
- [ ] Database encrypted mı?
- [ ] Logs'ta sensitive data yok mu?
- [ ] Clipboard temizleniyor mu?

### Network
- [ ] TLS 1.2+ kullanılıyor mu?
- [ ] Certificate pinning aktif mi?
- [ ] API keys hardcoded değil mi?
- [ ] Request/response logging production'da kapalı mı?

### Authentication
- [ ] Token secure storage'da mı?
- [ ] Refresh token rotation var mı?
- [ ] Session timeout var mı?
- [ ] Biometric auth available mı?

### Code
- [ ] Obfuscation aktif mi?
- [ ] Debug info ayrı mı?
- [ ] Jailbreak/root detection var mı?

---

## 🔗 Related Resources

- [checklists/owasp_mobile.md](checklists/owasp_mobile.md)
- [checklists/data_protection.md](checklists/data_protection.md)
- Grimoire: `store_compliance.md`
