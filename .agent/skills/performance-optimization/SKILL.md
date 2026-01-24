---
name: "Performance Optimization"
version: "1.0.0"
description: "FPS optimization, memory management, build optimization, and profiling"
primary_users:
  - performance-optimizer
  - mobile-developer
dependencies:
  - flutter-foundations
tags:
  - performance
  - quality
---

# ⚡ Performance Optimization

## Quick Start

Hedef: 60 FPS (16ms per frame), düşük memory footprint, hızlı startup.
"Measure first, optimize second" - DevTools kullan.

---

## 📊 Key Metrics

| Metric | Target | Red Flag |
|--------|--------|----------|
| Frame time | < 16ms | > 32ms |
| FPS | 60 | < 45 |
| Cold start | < 2s | > 5s |
| Memory | < 150MB | > 300MB |
| App size | < 30MB | > 100MB |

---

## 🔧 1. Build Optimization

### const Everything

```dart
// ❌ Her build'de yeni instance
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16), // Yeni instance
    decoration: BoxDecoration(  // Yeni instance
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.star),    // Yeni instance
  );
}

// ✅ const kullan - cache'lenir
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    child: const Icon(Icons.star),
  );
}

// ✅ EN İYİ - Widget'ı const yap
class StarContainer extends StatelessWidget {
  const StarContainer({super.key}); // const constructor
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: const Icon(Icons.star),
    );
  }
}
```

### Widget Splitting

```dart
// ❌ Büyük widget - her setState tümünü rebuild eder
class ProductPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(product.imageUrl),  // Static - her seferinde rebuild
        Text(product.title),               // Static
        Text('Fiyat: ${product.price}'),   // Static
        Counter(count: count),             // Dynamic
        ElevatedButton(                    // setState her şeyi rebuild eder!
          onPressed: () => setState(() => count++),
          child: Text('Ekle'),
        ),
      ],
    );
  }
}

// ✅ Küçük widget'lara böl - sadece değişen rebuild olur
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProductImage(),       // Ayrı const widget
        const ProductInfo(),        // Ayrı const widget
        const AddToCartSection(),   // State buraya izole
      ],
    );
  }
}
```

### Selective Rebuilds (Riverpod/Bloc)

```dart
// ❌ Tüm state değişiminde rebuild
Widget build(context, ref) {
  final state = ref.watch(userProvider); // Tüm user değişirse rebuild
  return Text(state.name);
}

// ✅ Sadece gereken field'ı izle
Widget build(context, ref) {
  final name = ref.watch(userProvider.select((u) => u.name));
  return Text(name); // Sadece name değişirse rebuild
}
```

---

## 📜 2. ListView Optimization

### ListView.builder (Lazy Loading)

```dart
// ❌ Tüm items bellekte
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ Lazy - sadece görünen items bellekte
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ + const itemExtent (exact height biliniyorsa)
ListView.builder(
  itemCount: items.length,
  itemExtent: 72, // Scroll performance artışı
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### RepaintBoundary

```dart
// Karmaşık widget'ları izole et
ListView.builder(
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: ComplexItemCard(items[index]),
    );
  },
)
```

### AutomaticKeepAlive

```dart
class _ItemWidgetState extends State<ItemWidget> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Scroll dışında kalsa bile state koru
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Unutma!
    return ExpensiveWidget();
  }
}
```

---

## 🖼️ 3. Image Optimization

### CachedNetworkImage

```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 200,  // Memory'de küçük tut
  memCacheHeight: 200,
  maxWidthDiskCache: 400, // Disk'te makul boyut
  placeholder: (context, url) => const Shimmer(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### ResizeImage

```dart
// Büyük resmi küçült
Image(
  image: ResizeImage(
    AssetImage('assets/hero.png'),
    width: 200,
    height: 200,
  ),
)
```

### Precaching

```dart
// Önceden yükle
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/logo.png'), context);
}
```

---

## ⏱️ 4. Startup Optimization

### Deferred Loading

```dart
// Heavy feature'ı lazy load et
import 'package:myapp/features/analytics/analytics.dart' deferred as analytics;

Future<void> initAnalytics() async {
  await analytics.loadLibrary();
  analytics.init();
}
```

### Splash Screen Optimization

```dart
// Native splash screen kullan (flutter_native_splash)
// main() içinde heavy init yapma

void main() {
  // Sadece kritik init
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// Heavy init uygulama açıldıktan sonra
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Background'da init
    Future.microtask(() async {
      await initAnalytics();
      await initNotifications();
      await warmUpCache();
    });
  }
}
```

---

## 🧠 5. Memory Management

### Dispose Resources

```dart
class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription _subscription;
  late final AnimationController _controller;
  late final TextEditingController _textController;
  
  @override
  void initState() {
    super.initState();
    _subscription = stream.listen(handleData);
    _controller = AnimationController(vsync: this);
    _textController = TextEditingController();
  }
  
  @override
  void dispose() {
    _subscription.cancel();  // Memory leak önle!
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

### Image Memory

```dart
// Large image'ları temizle
@override
void dispose() {
  // Image cache'i temizle
  imageCache.clear();
  imageCache.clearLiveImages();
  super.dispose();
}
```

---

## 📈 6. Profiling with DevTools

### Steps

```bash
# 1. Profile mode'da çalıştır
flutter run --profile

# 2. DevTools aç
# Observatory URL'e git veya VS Code'da "Open DevTools"

# 3. Performance tab
# - Timeline view
# - Frame chart
# - Jank detection

# 4. Memory tab
# - Heap snapshot
# - Allocation tracking
# - Memory leaks
```

### Frame Analysis

```
Good frame:    ████████░░░░░░░░ 10ms ✓
Janky frame:   ████████████████████████ 32ms ✗

Build phase:   ████░░░░░░░░░░░░  4ms (widget creation)
Layout phase:  ██░░░░░░░░░░░░░░  2ms (size/position)
Paint phase:   ████░░░░░░░░░░░░  4ms (drawing)

Target: Each phase < 16ms total
```

---

## ✅ Performance Checklist

### Build
- [ ] const kullanılabilir yerlerde kullanılıyor mu?
- [ ] Widget'lar küçük parçalara bölünmüş mü?
- [ ] Gereksiz rebuild var mı? (DevTools ile kontrol)

### Lists
- [ ] ListView.builder kullanılıyor mu?
- [ ] RepaintBoundary gerekli yerlerde var mı?
- [ ] itemExtent belirli mi?

### Images
- [ ] CachedNetworkImage kullanılıyor mu?
- [ ] Resize yapılıyor mu?
- [ ] Placeholder var mı?

### Memory
- [ ] dispose() içinde temizlik yapılıyor mu?
- [ ] Stream subscription cancel ediliyor mu?
- [ ] Controller'lar dispose ediliyor mu?

---

## 🔗 Related Resources

- [benchmarks/baseline_metrics.md](benchmarks/baseline_metrics.md)
- Grimoire: `flutter_performance.md`
