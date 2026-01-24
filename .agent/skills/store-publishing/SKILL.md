---
name: "Store Publishing"
version: "1.0.0"
description: "App Store and Play Store submission guidelines, metadata, and review preparation"
primary_users:
  - mobile-release-specialist
  - store-policy-expert
dependencies:
  - security-hardening
tags:
  - release
  - store
---

# 🚀 Store Publishing

## Quick Start

App Store ve Play Store'a başarılı yayın için gereken tüm adımlar.
Rejection sebeplerini önceden önle, metadata'yı optimize et.

---

## 🍎 App Store (iOS)

### 1. App Store Connect Hazırlığı

```yaml
# Gerekli bilgiler
app_name: "TaskMaster"  # max 30 char
subtitle: "Verimlilik artık çok kolay"  # max 30 char
privacy_url: "https://example.com/privacy"
support_url: "https://example.com/support"
marketing_url: "https://example.com"  # optional

# Kategoriler
primary_category: "Productivity"
secondary_category: "Utilities"  # optional

# Age Rating
age_rating: "4+"  # 4+, 9+, 12+, 17+
```

### 2. Screenshots Gereksinimleri

| Device | Size | Required |
|--------|------|----------|
| iPhone 6.7" | 1290 x 2796 | ✅ |
| iPhone 6.5" | 1284 x 2778 | ✅ |
| iPhone 5.5" | 1242 x 2208 | ✅ |
| iPad Pro 12.9" | 2048 x 2732 | If Universal |
| iPad Pro 11" | 1668 x 2388 | If Universal |

### 3. Common Rejection Reasons

| Reason | Çözüm |
|--------|-------|
| **Guideline 2.1** - App Completeness | Dummy content kaldır, tüm özellikler çalışsın |
| **Guideline 2.3** - Accurate Metadata | Screenshot'lar uygulamayı yansıtsın |
| **Guideline 4.2** - Minimum Functionality | Basit web wrapper kabul edilmez |
| **Guideline 5.1.1** - Data Collection | Privacy policy zorunlu |
| **Guideline 5.1.2** - Data Use | ATT dialog gerekli (tracking) |

### 4. Info.plist Permissions

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Profil fotoğrafı çekmek için kamera erişimi gerekiyor</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Profil fotoğrafı seçmek için galeri erişimi gerekiyor</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Yakındaki görevleri göstermek için konum erişimi gerekiyor</string>

<!-- Notifications -->
<key>NSUserNotificationsUsageDescription</key>
<string>Görev hatırlatıcıları için bildirim izni gerekiyor</string>

<!-- App Tracking Transparency (iOS 14.5+) -->
<key>NSUserTrackingUsageDescription</key>
<string>Daha iyi deneyim için reklam takibi izni istiyoruz</string>
```

---

## 🤖 Play Store (Android)

### 1. Google Play Console Hazırlığı

```yaml
# Store listing
app_name: "TaskMaster - Görev Yönetimi"  # max 30 char
short_description: "Görevlerinizi düzenleyin, hatırlatıcılar alın"  # max 80 char
full_description: |  # max 4000 char
  TaskMaster ile verimlilik...

# Kategoriler  
category: "PRODUCTIVITY"
content_rating: "Everyone"  # IARC rating

# Contact
email: "support@example.com"
phone: "+90..."  # optional
website: "https://example.com"
```

### 2. Data Safety Form

```yaml
data_collected:
  - name: "Email address"
    purpose: ["Account management"]
    optional: false
    shared: false
    
  - name: "App interactions"
    purpose: ["Analytics"]
    optional: true
    shared: true
    shared_with: ["Firebase Analytics"]

security_practices:
  data_encrypted_in_transit: true
  data_deletion_mechanism: true
```

### 3. Release Checklist

```markdown
## Pre-release
- [ ] Version code incremented
- [ ] Version name updated
- [ ] Release notes written
- [ ] App bundle signed
- [ ] ProGuard enabled
- [ ] Debug disabled

## Store Listing
- [ ] Screenshots updated (if UI changed)
- [ ] Description updated (if features changed)  
- [ ] What's New written
- [ ] Data Safety reviewed

## Testing
- [ ] Internal testing track passed
- [ ] Closed testing track passed (optional)
- [ ] Open testing track passed (optional)

## Compliance
- [ ] Target API level current (33+)
- [ ] 64-bit support included
- [ ] Permissions justified
```

### 4. AndroidManifest Permissions

```xml
<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Camera (with feature flag) -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Foreground Service -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<!-- Exact Alarms (Android 12+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

---

## 📝 Release Notes Template

```markdown
## Version 2.4.0

### 🎉 Yenilikler
- Karanlık mod desteği
- Widget özelliği (iOS 14+, Android 12+)
- Tekrarlayan görev ayarları

### ⚡ İyileştirmeler
- Uygulama %30 daha hızlı açılıyor
- Hafıza kullanımı optimize edildi
- Arayüz iyileştirmeleri

### 🐛 Hata Düzeltmeleri
- Senkronizasyon sorunları giderildi
- Bildirim zamanlaması düzeltildi
- Küçük hatalar giderildi

Geri bildirimleriniz için teşekkürler! ❤️
```

---

## 🔧 Build Commands

### iOS

```bash
# Archive for distribution
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist

# Or via Xcode
# Product > Archive > Distribute App
```

### Android

```bash
# App Bundle (recommended)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=./debug-info

# APK (if needed)
flutter build apk --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=./debug-info
```

---

## ✅ Submission Checklist

### Both Platforms
- [ ] Privacy policy URL active
- [ ] Support URL/email working
- [ ] All links in app working
- [ ] No placeholder content
- [ ] No debug logging
- [ ] Crash-free rate > 99.5%

### App Store
- [ ] ATT implemented (if tracking)
- [ ] All permission descriptions
- [ ] Screenshots 6.7" and 5.5"
- [ ] App preview video (optional)
- [ ] In-app purchase tested

### Play Store
- [ ] Data Safety form complete
- [ ] Target SDK 33+
- [ ] 64-bit libraries included
- [ ] App signing by Google enabled
- [ ] Internal testing verified

---

## 🔗 Related Resources

- [templates/app_store_listing.yaml](templates/app_store_listing.yaml)
- [templates/play_store_listing.yaml](templates/play_store_listing.yaml)
- [checklists/ios_review.md](checklists/ios_review.md)
- [checklists/android_review.md](checklists/android_review.md)
- Grimoire: `store_compliance.md`
- Grimoire: `release_engineering.md`
