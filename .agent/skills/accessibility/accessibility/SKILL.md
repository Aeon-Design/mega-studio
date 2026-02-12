# ♿ Accessibility Skill

> WCAG 2.1 AA uyumluluk, Semantics, TalkBack/VoiceOver desteği

---

## Temel İlkeler

1. **Perceivable:** Tüm içerik algılanabilir olmalı
2. **Operable:** Tüm işlevler kullanılabilir olmalı
3. **Understandable:** İçerik anlaşılabilir olmalı
4. **Robust:** Yardımcı teknolojilerle uyumlu olmalı

---

## Semantics Widget

```dart
// ❌ YANLIŞ — Semantics bilgisi yok
GestureDetector(
  onTap: () => _deleteItem(),
  child: Icon(Icons.delete, color: Colors.red),
)

// ✅ DOĞRU — Tam semantics
Semantics(
  label: 'Görevi sil',
  hint: 'Çift dokunarak görevi kalıcı olarak silin',
  button: true,
  child: GestureDetector(
    onTap: () => _deleteItem(),
    child: const Icon(Icons.delete, color: Colors.red),
  ),
)

// ✅ DAHA İYİ — IconButton zaten semantics içerir
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Görevi sil',  // Hem görsel tooltip hem screen reader
  onPressed: () => _deleteItem(),
)
```

---

## Kontrol Listesi

### Görsel
- [ ] Renk kontrastı ≥ 4.5:1 (normal metin), ≥ 3:1 (büyük metin)
- [ ] Bilgi sadece renkle iletilmiyor (ikon/metin de var)
- [ ] Metin boyutu kullanıcı tarafından ölçeklenebilir
- [ ] Touch target minimum 48x48dp
- [ ] Focus göstergesi görünür

### Screen Reader
- [ ] Tüm görsellerin `semanticLabel` veya `Semantics(label:)` değeri var
- [ ] Dekoratif görseller `ExcludeSemantics` ile gizli
- [ ] Form alanlarının label'ları var
- [ ] Hata mesajları screen reader'a duyuruluyor
- [ ] Sayfa başlıkları `Semantics(header: true)` ile işaretli

### Navigation
- [ ] Mantıksal odak sırası (soldan sağa, yukarıdan aşağı)
- [ ] Modal/dialog açıldığında focus dialog'a geçiyor
- [ ] Geri butonu her zaman çalışıyor

---

## Renk Kontrastı

```dart
// Kontrast hesaplama
double _luminance(Color color) {
  double _linearize(double c) =>
      c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * _linearize(color.red / 255) +
      0.7152 * _linearize(color.green / 255) +
      0.0722 * _linearize(color.blue / 255);
}

double contrastRatio(Color foreground, Color background) {
  final l1 = _luminance(foreground);
  final l2 = _luminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// Minimum kontrastlar:
// Normal metin (<18sp): 4.5:1
// Büyük metin (≥18sp bold veya ≥24sp): 3:1
// UI bileşenleri: 3:1
```

---

## Metin Ölçekleme Desteği

```dart
// ❌ YANLIŞ — Sabit metin boyutu, ölçeklenmiyor
Text('Başlık', style: TextStyle(fontSize: 24))

// ✅ DOĞRU — Theme'den al, otomatik ölçeklenir
Text('Başlık', style: Theme.of(context).textTheme.headlineMedium)

// ✅ MaxLines ve overflow ile taşmayı engelle
Text(
  'Çok uzun bir metin...',
  style: context.textTheme.bodyMedium,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// ❌ YANLIŞ — textScaler'ı devre dışı bırakma
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
  child: child,  // Erişilebilirlik ihlali!
)
```

---

## Screen Reader Duyuruları

```dart
// Önemli durum değişikliklerini duyur
SemanticsService.announce('Görev tamamlandı', TextDirection.ltr);

// Bloc listener'da kullanım
BlocListener<TaskBloc, TaskState>(
  listener: (context, state) {
    if (state.status == TaskStatus.success) {
      SemanticsService.announce(
        '${state.completedCount} görev tamamlandı',
        TextDirection.ltr,
      );
    }
    if (state.status == TaskStatus.failure) {
      SemanticsService.announce(
        'Hata: ${state.errorMessage}',
        TextDirection.ltr,
      );
    }
  },
)
```

---

## Erişilebilir Form

```dart
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  decoration: const InputDecoration(
    labelText: 'E-posta',  // Screen reader için önemli
    hintText: 'ornek@email.com',
    errorText: 'Lütfen geçerli bir e-posta girin', // Hata okunur
  ),
  validator: (value) {
    // ...
  },
)
```
