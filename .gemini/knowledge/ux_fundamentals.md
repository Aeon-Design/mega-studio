# 🎯 UX Fundamentals - 7 Critical Principles

> **Kaynak:** 100+ app audit deneyiminden elde edilen en kritik UX hataları
> **Versiyon:** 1.0.0
> **Son Güncelleme:** 2026-01-25

---

## 1. Visual Hierarchy (Görsel Hiyerarşi)

### ❌ Hata
Kullanıcı "önce neye bakmalıyım?" diye saniyelerce düşünüyor.

### ✅ Çözüm
- Renk ve boyutu estetik için değil, **gözün izleyeceği yolu belirlemek** için kullan
- **CTA öne çıkmalı**, ikincil aksiyonlar arkaplanda kalmalı
- Primary > Secondary > Tertiary action hiyerarşisi net olmalı

### Flutter Implementation
```dart
// ✅ Doğru: Net hiyerarşi
ElevatedButton(    // Primary - En belirgin
  style: ElevatedButton.styleFrom(
    backgroundColor: theme.primaryColor,
    minimumSize: Size(double.infinity, 56),
  ),
  child: Text('Devam Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
),
const SizedBox(height: 12),
OutlinedButton(    // Secondary - Daha az belirgin
  child: Text('Daha Sonra'),
),
TextButton(        // Tertiary - En az belirgin
  child: Text('Atla'),
),
```

### Checklist
- [ ] Her ekranda tek bir primary CTA var mı?
- [ ] Buton boyutları hiyerarşiyi yansıtıyor mu?
- [ ] Renk kontrastı dikkat yönlendiriyor mu?

---

## 2. Micro-interactions & Feedback

### ❌ Hata
Butona basıldığında tepki yok → "Acaba algılamadı mı?" stresi.

### ✅ Çözüm
- Her etkileşime **anında görsel feedback** ver
- Küçük animasyonlar (check, renk değişimi) onay oluşturur
- Loading state'leri net olmalı

### Flutter Implementation
```dart
// ✅ Doğru: Anında feedback
InkWell(
  onTap: () async {
    // 1. Immediate visual feedback
    HapticFeedback.lightImpact();
    
    // 2. Loading state
    setState(() => _isLoading = true);
    
    // 3. Action
    await performAction();
    
    // 4. Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Kaydedildi'),
      ])),
    );
  },
  child: AnimatedContainer(
    duration: Duration(milliseconds: 150),
    // Visual state change
  ),
)
```

### Checklist
- [ ] Her butonda ripple/feedback var mı?
- [ ] Loading state gösteriliyor mu?
- [ ] İşlem sonucu (success/error) bildiriliyor mu?

---

## 3. Tutarlılık (Consistency)

### ❌ Hata
Bir ekranda fill olan primary buton, diğerinde outline → Zihin yorulur.

### ✅ Çözüm
- **Tüm app aynı dili konuşmalı**
- Design tokens kullan (renkler, spacing, typography)
- Component library oluştur

### Flutter Implementation
```dart
// ✅ Doğru: Merkezi theme
class AppTheme {
  static ThemeData get light => ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    // Tüm butonlar tutarlı
  );
}

// Kullanım - her yerde aynı
ElevatedButton(onPressed: () {}, child: Text('Primary Action'))
```

### Checklist
- [ ] Theme.of(context) her yerde kullanılıyor mu?
- [ ] Hardcoded color/size var mı?
- [ ] Component'lar reusable mı?

---

## 4. Progressive Disclosure

### ❌ Hata
Her şeyi bir anda anlatmaya çalışmak → Bilgi overload.

### ✅ Çözüm
- **Sadece o anki hedefi göster**
- Ne kadar az seçenek = O kadar net akış
- Gelişmiş özellikler secondary menu'de

### Flutter Implementation
```dart
// ❌ Yanlış: Her şey bir arada
Column(children: [
  TextField(), TextField(), TextField(),
  TextField(), TextField(), TextField(),
  Checkbox(), Checkbox(), Switch(),
  // 10+ field tek ekranda
])

// ✅ Doğru: Adım adım
Stepper(
  currentStep: _currentStep,
  steps: [
    Step(title: Text('Temel Bilgiler'), content: _basicInfo()),
    Step(title: Text('Detaylar'), content: _details()),
    Step(title: Text('Onay'), content: _confirmation()),
  ],
)
```

### Checklist
- [ ] Ekranda 5'ten fazla aksiyon var mı?
- [ ] Karmaşık flow adımlara bölündü mü?
- [ ] "Gelişmiş" seçenekler gizlendi mi?

---

## 5. Helpful Error Messages

### ❌ Hata
"Geçersiz eposta" → Azarlayıcı ton.

### ✅ Çözüm
- Hata mesajları **yönlendirmek** için vardır
- Yapıcı dil kullan
- Ne yapması gerektiğini söyle

### Flutter Implementation
```dart
// ❌ Yanlış
TextFormField(
  validator: (v) => !v.contains('@') ? 'Geçersiz eposta' : null,
)

// ✅ Doğru
TextFormField(
  validator: (v) {
    if (v == null || v.isEmpty) {
      return 'Lütfen eposta adresinizi girin';
    }
    if (!v.contains('@')) {
      return 'Lütfen geçerli bir eposta adresi girin (örn: ornek@mail.com)';
    }
    return null;
  },
)
```

### Error Message Formula
```
[Ne oldu] + [Ne yapmalı] + [Örnek (opsiyonel)]

"Şifre çok kısa. En az 8 karakter kullanın."
"Bağlantı kurulamadı. İnternet bağlantınızı kontrol edin."
```

### Checklist
- [ ] Error mesajları actionable mı?
- [ ] Teknik jargon yok mu?
- [ ] Çözüm önerisi var mı?

---

## 6. Accessibility (Erişilebilirlik)

### ❌ Hata
Sadece "ideal" koşullarda çalışan tasarım.

### ✅ Çözüm
- **Her şartta kullanılabilir** tasarım
- Güneş altında okunabilir kontrast
- Tek elle kullanılabilir touch target

### Flutter Implementation
```dart
// ✅ Accessibility requirements
Widget build(BuildContext context) {
  return Semantics(
    label: 'Profil resmi yükle',
    button: true,
    child: GestureDetector(
      child: Container(
        // Minimum 48x48 touch target
        width: 56,
        height: 56,
        // Yeterli kontrast (4.5:1 min)
        decoration: BoxDecoration(
          color: Colors.blue[700], // Dark enough
        ),
        child: Icon(Icons.add, color: Colors.white),
      ),
    ),
  );
}
```

### Checklist
- [ ] Touch target ≥ 48dp mi?
- [ ] Color contrast ≥ 4.5:1 mi?
- [ ] Screen reader labels var mı?
- [ ] Tek elle kullanılabilir mi?

---

## 7. User-Centric Iteration

### ❌ Hata
"Ben tasarladım, herkes anlar" varsayımı.

### ✅ Çözüm
- **Ego değil, veri** izle
- Kullanıcı sistemi çözmek değil, hedefine ulaşmak ister
- Analytics ile iterate et

### Implementation
```dart
// Analytics event'leri ile kullanıcı davranışını izle
analytics.logEvent(
  name: 'feature_used',
  parameters: {
    'feature': 'quick_action',
    'time_to_complete': stopwatch.elapsedMilliseconds,
    'success': true,
  },
);

// Funnel dropout noktalarını tespit et
// A/B test ile alternatifleri dene
```

### Checklist
- [ ] Kullanıcı testleri yapıldı mı?
- [ ] Kritik funnel'lar izleniyor mu?
- [ ] Dropout noktaları analiz edildi mi?

---

## 🔍 Quick Audit Checklist

Her release öncesi bu 7 maddeyi kontrol edin:

```markdown
## UX Quick Audit

### Visual Hierarchy
- [ ] Tek primary CTA per screen
- [ ] Net hiyerarşi

### Feedback
- [ ] Her aksiyona tepki
- [ ] Loading states

### Consistency
- [ ] Theme kullanımı
- [ ] No hardcoded values

### Progressive Disclosure
- [ ] Max 5 aksiyon per screen
- [ ] Kompleks flow adım adım

### Error Messages
- [ ] Actionable messages
- [ ] Çözüm önerisi

### Accessibility
- [ ] 48dp touch targets
- [ ] 4.5:1 contrast

### User-Centric
- [ ] Analytics tracking
- [ ] Funnel izleme
```

---

> **"İyi tasarım, hataları affeder ve çözüm sunar."**
