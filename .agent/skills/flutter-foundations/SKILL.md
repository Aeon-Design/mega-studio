---
name: "Flutter Foundations"
version: "1.0.0"
description: "Core Flutter development patterns, widget best practices, and fundamental concepts"
primary_users:
  - mobile-developer
  - flutter-architect
dependencies: []
tags:
  - flutter
  - core
  - widgets
---

# 🎯 Flutter Foundations

## Quick Start

Bu skill, Flutter geliştirmenin temel taşlarını içerir: widget lifecycle, build optimization, 
layout sistemi ve platform-aware UI patterns. Her Mobile Developer bu skill'i master etmelidir.

---

## 📚 Core Concepts

### 1. Widget Lifecycle

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 1️⃣ Constructor - State oluşturulur
  
  @override
  void initState() {
    super.initState();
    // 2️⃣ Widget tree'ye eklendiğinde (1 kez)
    // ✅ Subscription başlat
    // ✅ Controller oluştur
    // ❌ Context kullanma (henüz yok)
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3️⃣ InheritedWidget değiştiğinde
    // ✅ Theme, MediaQuery okumak için uygun
  }
  
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 4️⃣ Parent yeni widget verdiğinde
    // ✅ Prop değişikliğine tepki ver
  }
  
  @override
  Widget build(BuildContext context) {
    // 5️⃣ Her frame (sık çağrılır!)
    // ❌ Heavy computation yapma
    // ❌ Side effect yapma
    return Container();
  }
  
  @override
  void deactivate() {
    super.deactivate();
    // 6️⃣ Tree'den çıkarıldığında (geri dönebilir)
  }
  
  @override
  void dispose() {
    super.dispose();
    // 7️⃣ Kalıcı olarak kaldırıldığında
    // ✅ Controller.dispose()
    // ✅ Subscription.cancel()
    // ✅ Timer.cancel()
  }
}
```

### 2. Widget Türleri Karar Ağacı

```
Widget ihtiyacı var →
│
├─► Sadece UI göster, state yok
│   └─► StatelessWidget ✅
│
├─► Internal state var (counter, toggle)
│   └─► StatefulWidget
│
├─► AnimationController gerekli
│   └─► StatefulWidget + SingleTickerProviderStateMixin
│
├─► Provider/Riverpod kullanıyorsun
│   ├─► ConsumerWidget (Riverpod)
│   └─► Consumer/Selector (Provider)
│
├─► Hooks kullanmak istiyorsun
│   └─► HookWidget / HookConsumerWidget
│
└─► Inherited data paylaşmak istiyorsun
    └─► InheritedWidget / InheritedNotifier
```

### 3. Build Optimization

```dart
// ❌ YANLIŞ: Her build'de yeni instance
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: (context, index) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.star), // Her seferinde yeni
          title: Text(items[index].title),
          onTap: () => onItemTap(index), // Her seferinde yeni closure
        ),
      );
    },
  );
}

// ✅ DOĞRU: const ve method reference
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: _buildItem,
  );
}

Widget _buildItem(BuildContext context, int index) {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.star), // const = cache
      title: Text(items[index].title),
      onTap: () => _onItemTap(index),
    ),
  );
}

// ✅ EN İYİ: Ayrı widget sınıfı
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.onTap});
  
  final Item item;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star),
        title: Text(item.title),
        onTap: onTap,
      ),
    );
  }
}
```

### 4. Layout System

```dart
// Flex Layout (Row/Column)
Column(
  mainAxisAlignment: MainAxisAlignment.center,     // Y ekseni
  crossAxisAlignment: CrossAxisAlignment.stretch, // X ekseni
  mainAxisSize: MainAxisSize.min,                 // Minimum alan
  children: [
    Text('Header'),
    Expanded(child: Content()),    // Kalan alanı kap
    Flexible(flex: 2, child: X()), // Oransal pay
    const Spacer(),                // Boşluk
  ],
)

// Constraints sistemi
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: child,
)

// Intrinsic - DİKKATLİ KULLAN (expensive)
IntrinsicHeight(  // Çocukların max yüksekliğine eşitle
  child: Row(children: [A(), B(), C()]),
)
```

---

## ✅ Code Review Checklist

### Widget Hygiene
- [ ] const constructor kullanılabilir mi?
- [ ] Widget çok büyük mü? (>200 satır = parçala)
- [ ] StatefulWidget gerçekten gerekli mi?
- [ ] dispose()'da tüm kaynaklar temizleniyor mu?

### Performance
- [ ] build() içinde heavy computation var mı?
- [ ] Gereksiz rebuild var mı? (DevTools ile kontrol)
- [ ] ListView.builder kullanılıyor mu? (büyük listeler için)
- [ ] const kullanılabilecek yerler var mı?

### Accessibility
- [ ] Semantics label var mı?
- [ ] Touch target 44x44 minimum mi?
- [ ] Kontrast yeterli mi?

---

## ⚠️ Common Mistakes

### 1. setState After Dispose
```dart
// ❌ CRASH!
Future<void> fetchData() async {
  final data = await api.getData();
  setState(() => this.data = data); // Widget disposed olmuş olabilir!
}

// ✅ SAFE
Future<void> fetchData() async {
  final data = await api.getData();
  if (mounted) {
    setState(() => this.data = data);
  }
}
```

### 2. Context After Async Gap
```dart
// ❌ UNSAFE
onPressed: () async {
  await doSomething();
  Navigator.of(context).pop(); // context invalid olabilir!
}

// ✅ SAFE
onPressed: () async {
  final navigator = Navigator.of(context);
  await doSomething();
  if (mounted) navigator.pop();
}
```

### 3. Missing Keys
```dart
// ❌ ReorderableListView'da key yok = bug
ReorderableListView(
  children: items.map((item) => ListTile(title: Text(item.name))).toList(),
)

// ✅ Her item'a unique key
ReorderableListView(
  children: items.map((item) => ListTile(
    key: ValueKey(item.id),
    title: Text(item.name),
  )).toList(),
)
```

---

## 🔗 Related Resources

- [examples/widget_patterns.dart](examples/widget_patterns.dart)
- [checklists/code_review.md](checklists/code_review.md)
- Grimoire: `flutter_widgets_deep.md`
