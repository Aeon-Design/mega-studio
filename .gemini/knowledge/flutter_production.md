# 🏭 Flutter Production Grimoire

> **Domain:** Production Patterns, AppConfig, Versioning, Cross-Platform
> **Primary Agent:** Tech Lead (`/tech-lead`)
> **Secondary:** Mobile Developer (`/mobile`)

---

## 📋 AppConfig System Pattern

### Purpose
Central configuration system (like .NET's `appsettings.json`) for managing:
- Environment (dev/prod)
- App metadata
- Store IDs
- Premium product IDs
- Feature flags

### Implementation

#### 1. Create `lib/core/config/app_config.dart`

```dart
import 'dart:io';

enum Environment { development, production }

class AppConfig {
  // Singleton
  AppConfig._();
  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  // Properties
  late final Environment environment;
  late final String appName;
  late final String appVersion;
  late final int buildNumber;

  // Store IDs
  late final String appStoreId;
  late final String playStorePackage;

  // Premium Product IDs
  late final String premiumProductIdAndroid;
  late final String premiumProductIdIOS;
  String get premiumProductId =>
      Platform.isIOS ? premiumProductIdIOS : premiumProductIdAndroid;

  // Trial
  late final int initialTrialDays;

  // AdMob IDs
  late final String _adMobBannerIdAndroid;
  late final String _adMobBannerIdIOS;
  String get adMobBannerId =>
      Platform.isIOS ? _adMobBannerIdIOS : _adMobBannerIdAndroid;

  late final String _adMobInterstitialIdAndroid;
  late final String _adMobInterstitialIdIOS;
  String get adMobInterstitialId =>
      Platform.isIOS ? _adMobInterstitialIdIOS : _adMobInterstitialIdAndroid;

  // Feature Flags
  late final bool enableDebugLogs;
  late final bool enableCrashlytics;

  // Computed
  bool get isProduction => environment == Environment.production;
  bool get isDebug => environment == Environment.development;

  /// Initialize from --dart-define=ENV=prod
  static void initializeFromEnvironment() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    final env = envString == 'prod'
        ? Environment.production
        : Environment.development;

    _instance = AppConfig._()
      ..environment = env
      ..appName = 'My App'
      ..appVersion = '1.0.0'
      ..buildNumber = 1
      // Store
      ..appStoreId = '123456789'
      ..playStorePackage = 'com.example.myapp'
      // Premium
      ..premiumProductIdAndroid = 'premium_lifetime_android'
      ..premiumProductIdIOS = 'premium_lifetime_ios'
      // Trial
      ..initialTrialDays = 7
      // AdMob (Use test IDs in dev)
      .._adMobBannerIdAndroid = env == Environment.production
          ? 'ca-app-pub-XXXX/YYYY'
          : 'ca-app-pub-3940256099942544/6300978111' // Test
      .._adMobBannerIdIOS = env == Environment.production
          ? 'ca-app-pub-XXXX/ZZZZ'
          : 'ca-app-pub-3940256099942544/2934735716' // Test
      .._adMobInterstitialIdAndroid = env == Environment.production
          ? 'ca-app-pub-XXXX/AAAA'
          : 'ca-app-pub-3940256099942544/1033173712' // Test
      .._adMobInterstitialIdIOS = env == Environment.production
          ? 'ca-app-pub-XXXX/BBBB'
          : 'ca-app-pub-3940256099942544/4411468910' // Test
      // Feature Flags
      ..enableDebugLogs = env == Environment.development
      ..enableCrashlytics = env == Environment.production;
  }
}
```

#### 2. Initialize in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initializeFromEnvironment();
  
  if (AppConfig.instance.enableCrashlytics) {
    // Initialize Crashlytics
  }
  
  runApp(const MyApp());
}
```

#### 3. Usage Throughout App

```dart
// Version display
Text('v${AppConfig.instance.appVersion}')

// AdMob
AdWidget(adUnitId: AppConfig.instance.adMobBannerId)

// Premium check
purchaseManager.purchase(AppConfig.instance.premiumProductId)

// Debug logging
if (AppConfig.instance.enableDebugLogs) {
  print('Debug: $message');
}
```

#### 4. Build Commands

```bash
# Development
flutter run

# Production
flutter build appbundle --dart-define=ENV=prod --release
flutter build ipa --dart-define=ENV=prod --release
```

---

## 📋 Versioning Best Practices

### Semantic Versioning (SemVer)

```
MAJOR.MINOR.PATCH+BUILD
1.0.0+1
```

| Part | When to Increment |
|------|-------------------|
| MAJOR | Breaking changes, major redesign |
| MINOR | New features, behavior changes |
| PATCH | Bug fixes, small UX improvements |
| BUILD | Always increment for each store upload |

### pubspec.yaml

```yaml
version: 1.2.3+45
# 1.2.3 = Version Name (shown to users)
# 45 = Build Number (internal, must always increase)
```

### Version Sync Checklist
- [ ] `pubspec.yaml` version updated
- [ ] `version.txt` (if exists) updated
- [ ] CHANGELOG.md updated
- [ ] Release notes written in `docs/release_notes/`

---

## 📋 Cross-Platform Parity Rules

### Golden Rule
> Every feature must work identically on Android and iOS unless platform limitations prevent it.

### Checklist
- [ ] UI looks correct on both platforms
- [ ] Navigation behavior is consistent
- [ ] IAP products exist on both stores
- [ ] Push notifications work on both
- [ ] Deep links configured for both
- [ ] Widgets (if any) implemented for both

### Platform-Specific Code Pattern

```dart
import 'dart:io';

if (Platform.isIOS) {
  // iOS-specific code
} else if (Platform.isAndroid) {
  // Android-specific code
}
```

---

## 📋 Pre-Production Cleanup Checklist

- [ ] Remove all `print()` statements (use logger instead)
- [ ] Remove TODO comments (or document in backlog)
- [ ] Remove test/debug code
- [ ] Verify no hardcoded test values
- [ ] Run `flutter analyze` - zero errors
- [ ] Run `dart fix --apply` for auto-fixes
- [ ] Verify `.gitignore` excludes build artifacts
- [ ] Organize docs into `docs/` folder
- [ ] Remove unused assets
- [ ] Verify all dependencies are up to date
