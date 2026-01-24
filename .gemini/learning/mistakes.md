# ❌ Yapılan Hatalar ve Çözümleri

> Bu dosya, projelerde yapılan hataları ve çözümlerini kaydeder.
> Aynı hataların tekrarlanmasını önler.

---

## 🔴 Kritik Hatalar

### 1. setState after dispose
**Hata:**
```dart
Future<void> fetchData() async {
  final data = await api.getData();
  setState(() => this.data = data); // Widget disposed olmuş!
}
```
**Çözüm:**
```dart
Future<void> fetchData() async {
  final data = await api.getData();
  if (mounted) {
    setState(() => this.data = data);
  }
}
```
**Öğrenilen:** Async gap sonrası her zaman `mounted` kontrol et.

---

## 🟡 Yaygın Hatalar

### 1. BuildContext after async
**Hata:**
```dart
onPressed: () async {
  await doSomething();
  Navigator.of(context).pop(); // context geçersiz olabilir
}
```
**Çözüm:**
```dart
onPressed: () async {
  final navigator = Navigator.of(context);
  await doSomething();
  if (mounted) navigator.pop();
}
```

---

## 📝 Yeni Hata Ekleme Şablonu

```markdown
### [Hata Başlığı]
**Hata:**
\`\`\`dart
[Yanlış kod]
\`\`\`
**Çözüm:**
\`\`\`dart
[Doğru kod]
\`\`\`
**Öğrenilen:** [Kısa açıklama]
```

---

*Son güncelleme: January 2026*
