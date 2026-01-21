Õ,import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Product IDs for in-app purchases
class ProductIds {
  static const String premiumLifetime = 'premium_lifetime';
  static const String premiumMonthly = 'premium_monthly';
  static const String premiumYearly = 'premium_yearly';

  static const Set<String> all = {
    premiumLifetime,
    premiumMonthly,
    premiumYearly,
  };
}

/// In-App Purchase Service
class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isPremium = false;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isPremium => _isPremium;

  /// Initialize the purchase service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('In-app purchases are not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    // Load products
    await loadProducts();

    // Restore purchases
    await restorePurchases();
  }

  /// Load available products
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final response = await _inAppPurchase.queryProductDetails(ProductIds.all);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  /// Buy a product
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) return false;

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Use buyNonConsumable for lifetime/subscriptions
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _inAppPurchase.restorePurchases();
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending: ${purchase.productID}');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify and deliver the product
          final valid = await _verifyPurchase(purchase);
          if (valid) {
            _deliverProduct(purchase);
            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchase);
            }
          }
          break;

        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled: ${purchase.productID}');
          break;
      }
    }
  }

  /// Verify purchase (in production, verify with your backend)
  /// WARNING: This is client-side verification only. For production,
  /// implement server-side receipt verification to prevent fraud.
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // PRODUCTION NOTE: Implement server-side verification here.
    // Send purchase.verificationData to your backend for validation.
    // For now, we trust the Play Store / App Store verification.
    debugPrint('[IAP] âš ï¸ Client-side verification only - implement server verification for production');
    return true;
  }

  /// Deliver the product and persist premium status
  void _deliverProduct(PurchaseDetails purchase) {
    if (ProductIds.all.contains(purchase.productID)) {
      _isPremium = true;
      // Premium status will be persisted via StorageService by the caller
      debugPrint('[IAP] âœ… Premium unlocked: ${purchase.productID}');
    }
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Dispose
  void dispose() {
    _subscription?.cancel();
  }
}

/// Provider for PurchaseService
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService();
  service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Premium status notifier
class IsPremiumNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(purchaseServiceProvider);
    return service.isPremium;
  }

  void setPremium(bool value) => state = value;
}

/// Provider for premium status
final isPremiumProvider = NotifierProvider<IsPremiumNotifier, bool>(
  IsPremiumNotifier.new,
);

/// Provider for available products
final productsProvider = Provider<List<ProductDetails>>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.products;
});

Õ,"(ad531abe872c7cf491ed881344a14c5a674c9d842_file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/services/purchase_service.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life