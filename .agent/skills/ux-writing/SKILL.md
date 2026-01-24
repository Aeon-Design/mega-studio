---
name: "UX Writing"
version: "1.0.0"
description: "Microcopy, error messages, onboarding text, and user-facing content"
primary_users:
  - tech-writer
  - mobile-developer
dependencies: []
tags:
  - content
  - ux
---

# ✍️ UX Writing

## Quick Start

Kullanıcıya yönelik tüm metin içerikleri: hata mesajları, buton etiketleri,
onboarding, boş durumlar. Açık, kısa, yardımcı.

---

## 📚 Core Principles

### 1. Be Clear, Not Clever

```dart
// ❌ Belirsiz
Text('Oops! Something went wrong.')

// ✅ Açık
Text('Bağlantı kurulamadı. İnternet ayarlarınızı kontrol edin.')
```

### 2. Be Concise

```dart
// ❌ Uzun
Text('Lütfen e-posta adresinizi aşağıdaki alana giriniz')

// ✅ Kısa
Text('E-posta')
```

### 3. Be Helpful

```dart
// ❌ Sadece hata
Text('Geçersiz şifre')

// ✅ Yardımcı
Text('Şifre en az 8 karakter olmalı')
```

---

## 📝 Content Types

### 1. Error Messages

```dart
class ErrorMessages {
  // Formula: What happened + Why it matters + What to do
  
  // Network errors
  static const networkError = 
    'Bağlantı kurulamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.';
  
  static const timeout = 
    'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
  
  // Validation errors
  static const invalidEmail = 
    'Geçerli bir e-posta adresi girin. Örnek: ad@ornek.com';
  
  static const passwordTooShort = 
    'Şifre en az 8 karakter olmalı.';
  
  static const passwordRequirements = 
    'Şifre en az 1 büyük harf, 1 rakam ve 1 özel karakter içermeli.';
  
  // Auth errors
  static const wrongPassword = 
    'E-posta veya şifre hatalı. Tekrar deneyin veya şifrenizi sıfırlayın.';
  
  static const accountLocked = 
    'Güvenlik için hesabınız geçici olarak kilitlendi. 30 dakika sonra tekrar deneyin.';
  
  // Permission errors
  static const cameraPermissionDenied = 
    'Fotoğraf çekmek için kamera izni gerekli. Ayarlardan izin verebilirsiniz.';
}
```

### 2. Empty States

```dart
class EmptyStateMessages {
  // Formula: What's empty + Why it matters + How to fix
  
  static const noTasks = EmptyState(
    title: 'Henüz görev yok',
    message: 'İlk görevinizi ekleyerek başlayın',
    actionLabel: 'Görev Ekle',
  );
  
  static const noSearchResults = EmptyState(
    title: 'Sonuç bulunamadı',
    message: 'Farklı anahtar kelimeler deneyin',
    actionLabel: null,
  );
  
  static const noNotifications = EmptyState(
    title: 'Bildirim yok',
    message: 'Yeni gelişmeler burada görünecek',
    actionLabel: null,
  );
  
  static const noConnection = EmptyState(
    title: 'Bağlantı yok',
    message: 'İnternet bağlantınızı kontrol edin',
    actionLabel: 'Tekrar Dene',
  );
}
```

### 3. Button Labels

```dart
class ButtonLabels {
  // Action-oriented, specific
  
  // ❌ Generic
  static const submit = 'Gönder';
  static const ok = 'Tamam';
  
  // ✅ Specific
  static const createAccount = 'Hesap Oluştur';
  static const saveChanges = 'Değişiklikleri Kaydet';
  static const addTask = 'Görev Ekle';
  static const deleteAccount = 'Hesabı Sil';
  static const tryAgain = 'Tekrar Dene';
  static const continueToPayment = 'Ödemeye Geç';
}

// Destructive actions - clear consequence
class DestructiveActions {
  static const delete = 'Sil';
  static const remove = 'Kaldır';
  static const cancel = 'İptal Et';
  static const logout = 'Çıkış Yap';
}
```

### 4. Confirmation Dialogs

```dart
class ConfirmationDialogs {
  // Formula: Question + Consequence + Action options
  
  static const deleteTask = ConfirmDialog(
    title: 'Görevi sil?',
    message: 'Bu işlem geri alınamaz.',
    confirmLabel: 'Sil',
    cancelLabel: 'İptal',
    isDestructive: true,
  );
  
  static const logout = ConfirmDialog(
    title: 'Çıkış yap?',
    message: 'Kaydedilmemiş değişiklikler kaybolabilir.',
    confirmLabel: 'Çıkış Yap',
    cancelLabel: 'Vazgeç',
    isDestructive: false,
  );
  
  static const deleteAccount = ConfirmDialog(
    title: 'Hesabı kalıcı olarak sil?',
    message: 'Tüm verileriniz silinecek. Bu işlem geri alınamaz.',
    confirmLabel: 'Evet, Hesabı Sil',
    cancelLabel: 'Hayır, Vazgeç',
    isDestructive: true,
  );
}
```

### 5. Loading States

```dart
class LoadingMessages {
  // Keep brief, show progress if possible
  
  static const loading = 'Yükleniyor...';
  static const saving = 'Kaydediliyor...';
  static const syncing = 'Senkronize ediliyor...';
  static const uploading = 'Yükleniyor...';
  static const processing = 'İşleniyor...';
  static const searching = 'Aranıyor...';
  
  // With progress
  static String uploadingProgress(int percent) => 
    'Yükleniyor... %$percent';
  
  static String syncingItems(int current, int total) => 
    '$current / $total senkronize ediliyor';
}
```

### 6. Success Messages

```dart
class SuccessMessages {
  // Brief, positive, dismissible
  
  static const saved = 'Kaydedildi ✓';
  static const taskCompleted = 'Görev tamamlandı 🎉';
  static const accountCreated = 'Hesabınız oluşturuldu';
  static const passwordChanged = 'Şifreniz güncellendi';
  static const profileUpdated = 'Profil güncellendi';
  static const itemDeleted = 'Silindi';
  
  // With undo option
  static const deletedWithUndo = UndoableMessage(
    message: 'Görev silindi',
    undoLabel: 'Geri Al',
  );
}
```

### 7. Onboarding

```dart
class OnboardingContent {
  static final screens = [
    OnboardingScreen(
      title: 'Hoş Geldiniz',
      subtitle: 'Görevlerinizi kolayca yönetin',
      body: 'TaskMaster ile yapılacaklarınızı organize edin, '
            'hatırlatıcılar alın, verimli olun.',
    ),
    OnboardingScreen(
      title: 'Akıllı Hatırlatıcılar',
      subtitle: 'Hiçbir şeyi kaçırmayın',
      body: 'Doğru zamanda, doğru yerde hatırlatmalar. '
            'Konum tabanlı bildirimlerle her zaman hazır olun.',
    ),
    OnboardingScreen(
      title: 'Başlamaya Hazır mısınız?',
      subtitle: 'Sadece 2 dakika',
      body: 'Ücretsiz hesap oluşturun ve verimlilik '
            'yolculuğunuza başlayın.',
      ctaLabel: 'Başla',
    ),
  ];
}
```

---

## 🎨 Tone & Voice

### Voice Attributes

| Attribute | Do | Don't |
|-----------|-----|-------|
| **Friendly** | "Tebrikler!" | "İşlem başarılı." |
| **Clear** | "Şifre en az 8 karakter" | "Geçersiz format" |
| **Helpful** | "Tekrar deneyin veya destek alın" | "Hata oluştu" |
| **Concise** | "Kaydet" | "Değişiklikleri kaydetmek için tıklayın" |
| **Respectful** | "Bağlantı yok" | "Hata yaptınız" |

### Avoid

```dart
// ❌ Technical jargon
'Error 503: Service unavailable'
// ✅ Human language
'Sunucu meşgul. Birkaç dakika sonra tekrar deneyin.'

// ❌ Blaming the user
'Yanlış şifre girdiniz'
// ✅ Neutral
'Şifre eşleşmiyor'

// ❌ Vague
'Bir hata oluştu'
// ✅ Specific
'Dosya yüklenemedi. Dosya boyutu 10MB\'ı aşamaz.'

// ❌ ALL CAPS
'HATA!'
// ✅ Normal case
'Hata'

// ❌ Exclamation overuse
'Tebrikler!!!'
// ✅ Single or none
'Tebrikler!'
```

---

## ✅ UX Writing Checklist

### Clarity
- [ ] Jargon yok mu?
- [ ] Bir bakışta anlaşılıyor mu?
- [ ] Somut mu? (ne, neden, nasıl)

### Brevity
- [ ] Gereksiz kelime var mı?
- [ ] 2 satırı geçiyor mu?
- [ ] Daha kısa söylenebilir mi?

### Helpfulness
- [ ] Kullanıcı ne yapmalı belli mi?
- [ ] Çözüm önerisi var mı?
- [ ] Gereken bilgi veriliyor mu?

### Consistency
- [ ] Aynı şey her yerde aynı mı?
- [ ] Ton tutarlı mı?
- [ ] Terminoloji aynı mı?

---

## 🔗 Related Resources

- [templates/error_messages.md](templates/error_messages.md)
- [templates/onboarding.md](templates/onboarding.md)
- [tone_guide.md](tone_guide.md)
