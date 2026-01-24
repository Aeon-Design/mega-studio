---
name: "Accessibility"
version: "1.0.0"
description: "WCAG 2.1 AA compliance, screen readers, dynamic type, and inclusive design"
primary_users:
  - accessibility-specialist
  - mobile-developer
dependencies:
  - flutter-foundations
tags:
  - accessibility
  - quality
  - a11y
---

# ♿ Accessibility (A11y)

## Quick Start

Erişilebilirlik lüks değil, haktır. WCAG 2.1 AA standardı hedefle.
VoiceOver (iOS) ve TalkBack (Android) ile test et.

---

## 📚 4 Temel Prensip (POUR)

| Prensip | Açıklama | Örnek |
|---------|----------|-------|
| **P**erceivable | İçerik algılanabilir olmalı | Alt text, kontrastlı renkler |
| **O**perable | UI kullanılabilir olmalı | Keyboard nav, yeterli touch target |
| **U**nderstandable | İçerik anlaşılır olmalı | Açık dil, tutarlı navigasyon |
| **R**obust | Farklı teknolojilerle uyumlu | Semantic HTML, ARIA |

---

## 🔊 1. Screen Reader Support

### Semantics Widget

```dart
// Temel semantic label
Semantics(
  label: 'Görevi tamamlandı olarak işaretle',
  child: IconButton(
    icon: Icon(Icons.check),
    onPressed: onComplete,
  ),
)

// Container semantics
Semantics(
  container: true,
  label: 'Görev kartı: ${task.title}',
  hint: 'Çift dokunarak detayları görün',
  child: TaskCard(task: task),
)

// Excluding decorative elements
Semantics(
  excludeSemantics: true, // veya ExcludeSemantics widget
  child: DecorativeImage(),
)

// Button semantics
Semantics(
  button: true,
  enabled: isEnabled,
  label: 'Görevi sil',
  child: DeleteButton(onPressed: onDelete),
)
```

### MergeSemantics

```dart
// Birden çok elementi tek birim olarak oku
MergeSemantics(
  child: Row(
    children: [
      Icon(Icons.star, color: Colors.amber),
      Text('4.5'),
      Text('(128 değerlendirme)'),
    ],
  ),
)
// Screen reader: "4.5, 128 değerlendirme, yıldız"
```

### Focus Order

```dart
// Otomatik focus sırası yerine manuel kontrol
FocusScope(
  child: Column(
    children: [
      Focus(
        autofocus: true, // İlk focus
        child: TextField(decoration: InputDecoration(labelText: 'E-posta')),
      ),
      TextField(decoration: InputDecoration(labelText: 'Şifre')),
      ElevatedButton(
        onPressed: onSubmit,
        child: Text('Giriş Yap'),
      ),
    ],
  ),
)
```

---

## 🎨 2. Color & Contrast

### Minimum Contrast Ratios (WCAG AA)

| Element | Normal Text | Large Text |
|---------|-------------|------------|
| Body text | 4.5:1 | 3:1 |
| UI components | 3:1 | 3:1 |
| Graphics | 3:1 | 3:1 |

### Contrast Calculator

```dart
class ContrastChecker {
  static double calculateRatio(Color foreground, Color background) {
    final l1 = _luminance(foreground);
    final l2 = _luminance(background);
    
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  static double _luminance(Color color) {
    double channel(int value) {
      final v = value / 255;
      return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4);
    }
    
    return 0.2126 * channel(color.red) + 
           0.7152 * channel(color.green) + 
           0.0722 * channel(color.blue);
  }
  
  static bool meetsAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = calculateRatio(foreground, background);
    return ratio >= (largeText ? 3.0 : 4.5);
  }
}

// Kullanım
final passes = ContrastChecker.meetsAA(
  Colors.white,
  Colors.blue,
); // true veya false
```

### Don't Rely on Color Alone

```dart
// ❌ YANLIŞ - Sadece renk ile durum belirtme
Container(
  color: isError ? Colors.red : Colors.green, // Renk körü göremez
  child: Text('Status'),
)

// ✅ DOĞRU - Renk + ikon + text
Row(
  children: [
    Icon(
      isError ? Icons.error : Icons.check_circle,
      color: isError ? Colors.red : Colors.green,
    ),
    Text(isError ? 'Hata oluştu' : 'Başarılı'),
  ],
)
```

---

## 📏 3. Touch Targets

### Minimum Sizes

| Platform | Minimum | Recommended |
|----------|---------|-------------|
| iOS | 44x44 pt | 48x48 pt |
| Android | 48x48 dp | 48x48 dp |
| Material 3 | 48x48 dp | 48x48 dp |

```dart
// ❌ KÜÇÜK - Dokunması zor
IconButton(
  iconSize: 20,
  padding: EdgeInsets.zero,
  icon: Icon(Icons.close),
  onPressed: onClose,
)

// ✅ YETERLİ - Minimum 44x44
IconButton(
  iconSize: 24,
  padding: EdgeInsets.all(12), // Total: 48x48
  icon: Icon(Icons.close),
  onPressed: onClose,
)

// Alternatif: ConstrainedBox ile garanti
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 48, minHeight: 48),
  child: InkWell(
    onTap: onTap,
    child: Icon(Icons.close),
  ),
)
```

---

## 📝 4. Dynamic Type

```dart
// ❌ YANLIŞ - Fixed font size
Text(
  'Başlık',
  style: TextStyle(fontSize: 24),
)

// ✅ DOĞRU - Theme kullan (otomatik scale)
Text(
  'Başlık',
  style: Theme.of(context).textTheme.headlineMedium,
)

// Text scale factor ile test
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaleFactor: 2.0),
  child: MyWidget(),
)
```

### Handling Large Text

```dart
// Overflow kontrolü
Text(
  'Çok uzun bir metin...',
  style: Theme.of(context).textTheme.bodyLarge,
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)

// Responsive layout for large text
LayoutBuilder(
  builder: (context, constraints) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    
    if (textScale > 1.5) {
      // Büyük font için dikey layout
      return Column(children: [icon, label]);
    } else {
      // Normal için yatay layout
      return Row(children: [icon, label]);
    }
  },
)
```

---

## 🎬 5. Motion & Animation

```dart
// Reduced motion tercihini kontrol et
class AccessibleAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    if (reduceMotion) {
      // Animasyonsuz versiyon
      return Container(color: Colors.blue);
    }
    
    // Animasyonlu versiyon
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: Colors.blue,
    );
  }
}
```

---

## 🧪 6. Testing

### Flutter A11y Test

```dart
void main() {
  testWidgets('accessibility test', (tester) async {
    final handle = tester.ensureSemantics();
    
    await tester.pumpWidget(MyApp());
    
    // Built-in guidelines
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    
    handle.dispose();
  });
}
```

### Manual Testing Checklist

```markdown
## VoiceOver (iOS)
- [ ] Tüm interactive elementler announce ediliyor mu?
- [ ] Focus sırası mantıklı mı (top-to-bottom, left-to-right)?
- [ ] Custom gesture'lar için alternatif var mı?

## TalkBack (Android)
- [ ] Touch exploration çalışıyor mu?
- [ ] Double-tap ile activation doğru mu?
- [ ] Swipe navigation mantıklı mı?

## Keyboard Navigation
- [ ] Tab ile tüm elementlere erişilebiliyor mu?
- [ ] Focus indicator görünür mü?
- [ ] Escape modal'ları kapatıyor mu?
```

---

## ✅ A11y Checklist

### Perceivable
- [ ] Tüm görsellerin alt text'i var mı?
- [ ] Renk kontrastı 4.5:1 minimum mi?
- [ ] Sadece renge bağımlı bilgi yok mu?

### Operable
- [ ] Touch target 48x48 dp minimum mi?
- [ ] Keyboard ile navigasyon mümkün mü?
- [ ] Focus indicator görünür mü?

### Understandable
- [ ] Form hata mesajları açık mı?
- [ ] Navigasyon tutarlı mı?
- [ ] Dil basit ve anlaşılır mı?

### Robust
- [ ] Semantic widgets kullanılıyor mu?
- [ ] Screen reader testleri yapıldı mı?
- [ ] Dynamic type destekleniyor mu?

---

## 🔗 Related Resources

- [checklists/wcag_aa.md](checklists/wcag_aa.md)
- [checklists/screen_reader.md](checklists/screen_reader.md)
- Grimoire: `flutter_accessibility.md`
