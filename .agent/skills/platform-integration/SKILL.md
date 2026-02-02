---
name: "Platform Integration"
version: "1.0.0"
description: |
  Native platform integration: Widgets, IAP, Networking.
  iOS/Android specific implementations.
  Tetikleyiciler: "widget", "iap", "purchase", "storekit", "billing", "home screen"
---

# Platform Integration

## Amaç
Native platform özelliklerini Flutter'a entegre etme.

---

## Home Screen Widgets

### Setup (home_widget package)
```yaml
dependencies:
  home_widget: ^0.4.1
```

### Android Widget
```dart
// android/app/src/main/kotlin/.../HomeWidgetProvider.kt
class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, 
                         appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            views.setTextViewText(R.id.widget_text, 
                                 widgetData.getString("text", "No data"))
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
```

### iOS Widget (WidgetKit)
```swift
// ios/WidgetExtension/Widget.swift
struct SimpleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Simple", provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
    }
}
```

### Flutter Side
```dart
class WidgetService {
  static Future<void> updateWidget({required String text}) async {
    await HomeWidget.saveWidgetData<String>('text', text);
    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider',       // Android
      iOSName: 'SimpleWidget',          // iOS
    );
  }
}
```

---

## In-App Purchases

### Setup
```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

### Purchase Service
```dart
class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: _onPurchaseError,
    );
    
    await _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    const productIds = {'premium_monthly', 'premium_yearly'};
    final response = await _iap.queryProductDetails(productIds);
    _products = response.productDetails;
  }
  
  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    
    if (product.id.contains('subscription')) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }
  
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify and deliver
        await _verifyPurchase(purchase);
        await _deliverProduct(purchase);
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
  
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Server-side verification recommended
    final receipt = purchase.verificationData.serverVerificationData;
    return await _api.verifyReceipt(receipt);
  }
  
  void dispose() {
    _subscription.cancel();
  }
}
```

---

## RevenueCat (Recommended)

### Setup
```yaml
dependencies:
  purchases_flutter: ^6.17.0
```

### Implementation
```dart
class RevenueCatService {
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    
    PurchasesConfiguration configuration;
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration('ios_api_key');
    } else {
      configuration = PurchasesConfiguration('android_api_key');
    }
    
    await Purchases.configure(configuration);
  }
  
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> isPremium() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey('premium');
  }
  
  static Future<void> restorePurchases() async {
    await Purchases.restorePurchases();
  }
}
```

---

## Native Networking

### Platform Channels
```dart
// Flutter side
class NativeNetworkService {
  static const _channel = MethodChannel('com.example/network');
  
  static Future<String> nativeFetch(String url) async {
    return await _channel.invokeMethod('fetch', {'url': url});
  }
}
```

```kotlin
// Android side
class NetworkPlugin : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "fetch" -> {
                val url = call.argument<String>("url")
                // Native HTTP request
                result.success(response)
            }
            else -> result.notImplemented()
        }
    }
}
```

---

## Background Fetch

### Setup
```yaml
dependencies:
  workmanager: ^0.5.2
```

### Implementation
```dart
class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    
    await Workmanager().registerPeriodicTask(
      'sync-task',
      'syncData',
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncData':
        await syncLocalData();
        return true;
      default:
        return false;
    }
  });
}
```

---

## Push Notifications

### Firebase Messaging
```dart
class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();
    
    // Get token
    final token = await _messaging.getToken();
    await _saveToken(token);
    
    // Handle messages
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onBackgroundMessage(_handleBackground);
  }
  
  void _handleForeground(RemoteMessage message) {
    // Show local notification
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackground(RemoteMessage message) async {
  // Handle in background
}
```

---

## Checklist

- [ ] Platform-specific setup completed
- [ ] IAP products configured in stores
- [ ] Receipt verification implemented
- [ ] Widget updates working
- [ ] Background fetch registered
- [ ] Push notifications configured
- [ ] Platform channels tested on both platforms
