# 📚 Öğrenilen Patternler

> Bu dosya, projelerden öğrenilen tekrar kullanılabilir pattern'leri içerir.
> Her yeni pattern keşfedildiğinde buraya eklenir.

---

## 🏗️ Architecture Patterns

### 1. Feature-First + Clean Architecture
```
features/
└── feature_name/
    ├── data/       (DataSource, Model, Repository Impl)
    ├── domain/     (Entity, Repository Interface, UseCase)
    └── presentation/ (Bloc, Page, Widget)
```
**Neden çalışıyor:** Özellik bazlı organizasyon + katman ayrımı = maintainable code

---

## 🔄 State Management Patterns

### 1. Optimistic Update with Rollback
```dart
// Önce UI güncelle, hata olursa geri al
final previousState = state;
emit(newState);
try {
  await api.update();
} catch (e) {
  emit(previousState); // Rollback
}
```
**Kullanım:** User-facing CRUD işlemleri

---

## 🧪 Testing Patterns

### 1. AAA Pattern
```dart
test('description', () {
  // Arrange - hazırlık
  // Act - eylem
  // Assert - doğrulama
});
```

---

## 📝 Yeni Pattern Ekleme Şablonu

```markdown
### [Pattern Adı]
\`\`\`[dil]
[Kod örneği]
\`\`\`
**Neden çalışıyor:** [Açıklama]
**Kullanım:** [Ne zaman kullanılacak]
```

---

*Son güncelleme: January 2026*
