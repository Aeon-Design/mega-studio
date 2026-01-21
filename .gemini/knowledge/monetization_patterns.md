# 💰 Monetization Patterns Grimoire

> **Domain:** IAP, Subscriptions, Ads, Paywalls, Revenue Optimization
> **Primary Agent:** Monetization Specialist (`/monetize`)
> **Secondary:** Product Strategist (`/product`)

---

## 📦 RevenueCat Setup Guide

### 1. Installation

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^6.0.0
```

### 2. Platform Configuration

**Android (`android/app/build.gradle`):**
```gradle
defaultConfig {
    minSdkVersion 21
}
```

**iOS (`ios/Podfile`):**
```ruby
platform :ios, '13.0'
```

### 3. Initialize in main.dart

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug); // Remove in production
  
  PurchasesConfiguration config;
  if (Platform.isIOS) {
    config = PurchasesConfiguration('appl_XXXXXXXX');
  } else {
    config = PurchasesConfiguration('goog_XXXXXXXX');
  }
  
  await Purchases.configure(config);
}
```

### 4. Check Premium Status

```dart
class PremiumService {
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      return false; // Fail-safe: assume free
    }
  }
  
  static Stream<bool> get premiumStream {
    return Purchases.customerInfoStream.map(
      (info) => info.entitlements.active.containsKey('premium'),
    );
  }
}
```

### 5. Display Paywall

```dart
Future<void> showPaywall() async {
  final offerings = await Purchases.getOfferings();
  final current = offerings.current;
  
  if (current != null) {
    // Show your custom paywall UI with current.availablePackages
    showModalBottomSheet(
      context: context,
      builder: (_) => PaywallSheet(offering: current),
    );
  }
}
```

### 6. Make Purchase

```dart
Future<bool> purchasePackage(Package package) async {
  try {
    await Purchases.purchasePackage(package);
    return true;
  } on PurchasesErrorCode catch (e) {
    if (e == PurchasesErrorCode.purchaseCancelledError) {
      // User cancelled
      return false;
    }
    rethrow;
  }
}
```

### 7. Restore Purchases

```dart
Future<void> restorePurchases() async {
  try {
    await Purchases.restorePurchases();
    // Check entitlements again
    final isPremium = await PremiumService.isPremium();
    if (isPremium) {
      showSnackBar('Purchases restored!');
    } else {
      showSnackBar('No previous purchases found.');
    }
  } catch (e) {
    showSnackBar('Restore failed. Please try again.');
  }
}
```

---

## 🎨 Paywall Design Patterns

### Soft Paywall (Recommended for most apps)
- Free tier with core functionality
- Premium teaser badges on locked features
- "Unlock" button appears contextually

### Hard Paywall (Content apps only)
- Limited free content (e.g., 3 articles)
- Full access requires subscription
- Always offer trial

### Freemium with Limits
- Feature limits (e.g., 5 projects free)
- Usage limits (e.g., 10 exports/month)
- Time limits (e.g., 7-day trial)

### Paywall UI Best Practices
```
┌─────────────────────────────┐
│       [App Icon]            │
│    Unlock Premium           │
│                             │
│  ✅ Feature 1               │
│  ✅ Feature 2               │
│  ✅ Feature 3               │
│  ✅ No Ads                  │
│                             │
│  ┌─────────────────────┐    │
│  │ Weekly    $1.99/wk  │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ Monthly   $4.99/mo  │ ⭐ │
│  │ (Most Popular)      │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ Yearly    $29.99/yr │    │
│  │ (Save 50%)          │    │
│  └─────────────────────┘    │
│                             │
│  [ Start Free Trial ]       │
│                             │
│  Restore Purchases          │
│  Terms | Privacy            │
└─────────────────────────────┘
```

---

## 📺 AdMob Integration

### 1. Setup

```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

### 2. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}
```

### 3. Banner Ad

```dart
class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConfig.instance.adMobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
```

### 4. Interstitial Ad

```dart
class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  DateTime? _lastShown;
  
  Future<void> loadAd() async {
    await InterstitialAd.load(
      adUnitId: AppConfig.instance.adMobInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }
  
  Future<void> showAdIfReady() async {
    // Frequency cap: 60 seconds
    if (_lastShown != null &&
        DateTime.now().difference(_lastShown!) < Duration(seconds: 60)) {
      return;
    }
    
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _lastShown = DateTime.now();
      _interstitialAd = null;
      loadAd(); // Preload next
    }
  }
}
```

---

## 💡 Pricing Psychology

### Anchoring
Show the most expensive option first to make others seem reasonable.

### Decoy Effect
Offer 3 options where the middle one is the "obvious" best value.

### Loss Aversion
"Don't lose your progress" > "Get extra features"

### Trial Length
- 3 days: Urgency, but less time to build habit
- 7 days: Standard, balanced
- 14 days: More habit formation, lower conversion rate

### Price Points (USD)
| Duration | Budget | Standard | Premium |
|----------|--------|----------|---------|
| Weekly | $0.99 | $1.99 | $4.99 |
| Monthly | $2.99 | $4.99 | $9.99 |
| Yearly | $19.99 | $29.99 | $49.99 |
| Lifetime | $29.99 | $49.99 | $99.99 |
