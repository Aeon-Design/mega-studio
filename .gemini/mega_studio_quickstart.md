# 🚀 HIZLI BAŞLANGIÇ REHBERİ

## Opus 4.5 ile Nasıl Kullanılır?

---

## 📋 ADIM 1: Master Prompt'u Yükle

Opus 4.5'e şu mesajı gönder:

```
Sana kapsamlı bir görev vereceğim. Bu görev, çoklu ajan tabanlı bir Flutter uygulama geliştirme sistemi kurmak. 

Şimdi sana iki doküman göndereceğim:
1. Master Prompt (ana kurulum promptu)
2. Agent Generator (ajan prompt üretici)

Bu dokümanları oku, anla ve sonra benim direktiflerimi bekle.
```

Ardından `mega_studio_master_prompt.md` dosyasının içeriğini yapıştır.

---

## 📋 ADIM 2: Agent Generator'ı Yükle

```
İşte ikinci doküman - Agent Generator:
```

Ardından `mega_studio_agent_generator.md` dosyasının içeriğini yapıştır.

---

## 📋 ADIM 3: Sistemi Başlat

Şu prompt ile başlat:

```
Şimdi bu iki dokümanı referans alarak:

1. Önce Master Orchestrator'ın tam ve final promptunu yaz
2. Sonra Flutter Core Team'i oluştur:
   - Flutter Architect
   - Mobile Developer  
   - State Manager
   - Platform Bridge

Her prompt için:
- Minimum 800 kelime
- Somut kod örnekleri
- Karar ağaçları
- Input/Output formatları
- Hata senaryoları
- Gerçek dünya use case'leri

Başla.
```

---

## 📋 ADIM 4: Geri Bildirim Döngüsü

İlk çıktıyı aldıktan sonra:

```
[Ajan adı] için şu konuları genişlet:
- [Eksik konu 1]
- [Eksik konu 2]

Ve şu senaryoyu ekle:
- [Spesifik senaryo]
```

---

## 📋 ADIM 5: Tüm Sistemi Tamamla

Çekirdek ekip tamamlandıktan sonra:

```
Şimdi sırayla şu ajanları ekle:

Backend & Infra:
- Backend Specialist
- Database Architect
- DevOps Engineer

Quality & Security:
- QA Lead (zaten var, güncelle)
- Security Auditor
- App Auditor

Release:
- Mobile Release Specialist
- Store Policy Expert

Her biri için aynı detay seviyesini koru.
```

---

## 📋 ADIM 6: Test Et

Sistemi test etmek için:

```
Şimdi bu sistemi test edelim. 

Senaryo: "Pomodoro tekniği ile çalışma takibi yapan bir mobil uygulama"

Master Orchestrator olarak bu projeyi başlat ve:
1. Discovery fazını çalıştır
2. Her ajanın çıktısını simüle et
3. Gate 1 kontrolünü yap

Başla.
```

---

## 🎯 ÖRNEK KULLANIM AKIŞI

### Gerçek Proje Başlatma

```
Master Orchestrator, yeni bir proje başlat:

Proje: Günlük su içme takip uygulaması
Platform: iOS + Android
Özellikler:
- Günlük su hedefi belirleme
- İçilen suyu kaydetme
- Hatırlatıcı bildirimler
- Haftalık istatistikler
- Widget desteği

Hedef: 6 hafta içinde MVP yayını

Şimdi Discovery fazını başlat.
```

### Spesifik Ajan Çağırma

```
Flutter Architect olarak şu projenin mimarisini tasarla:

[Proje detayları]

Çıktı olarak:
1. Tam klasör yapısı
2. pubspec.yaml
3. Core klasörü base sınıfları
4. Bir feature örneği (iskelet)
```

### Hata Durumu Simülasyonu

```
QA Lead olarak şu build'i test et:

Test sonuçları:
- 45 test geçti
- 3 test başarısız
- Crash log: [log]

Rapor oluştur ve karar ver.
```

---

## ⚠️ ÖNEMLİ NOTLAR

### Context Window Yönetimi

Opus 4.5'in context window'u geniş olsa da, tüm ajanları tek seferde yüklemeye çalışma:

1. **Batch 1**: Master Orchestrator + Flutter Core (4 ajan)
2. **Batch 2**: Backend & Infra (3 ajan)
3. **Batch 3**: Quality & Security (3 ajan)
4. **Batch 4**: Release + Support (4+ ajan)

### Prompt Versiyonlama

Her prompt çıktısını şu formatta kaydet:

```
/prompts/
├── v1.0/
│   ├── master_orchestrator.md
│   ├── flutter_architect.md
│   └── ...
├── v1.1/
│   └── ...
└── CHANGELOG.md
```

### İterasyon Stratejisi

1. İlk versiyon: Temel fonksiyonellik
2. Test: Gerçek senaryo ile dene
3. Feedback: Eksikleri belirle
4. Güncelleme: Promptları iyileştir
5. Tekrarla

---

## 🔧 SORUN GİDERME

### Problem: Ajan çıktısı tutarsız

**Çözüm:** Daha spesifik input formatı tanımla
```
Input formatını şu şekilde güncelle:
[Yeni format]
```

### Problem: Ajanlar arası iletişim kopuk

**Çözüm:** Interface tanımlarını netleştir
```
[Ajan A] ve [Ajan B] arasındaki veri akışını şu şekilde tanımla:
[Format]
```

### Problem: Gate kontrolleri çok gevşek/sıkı

**Çözüm:** Threshold'ları ayarla
```
Gate [X] için kabul kriterlerini şu şekilde güncelle:
[Yeni kriterler]
```

---

## 📊 BAŞARI METRİKLERİ

Sistem başarılı sayılır eğer:

| Metrik | Hedef |
|--------|-------|
| Proje başlatmadan yayına süre | < 8 hafta |
| Kritik bug sayısı (yayın sonrası) | 0 |
| Test coverage | > %80 |
| Store rejection oranı | 0 |
| Tekrar kullanılabilirlik | > %70 |

---

## 📞 DESTEK

Bu sistem iteratif olarak geliştirilmelidir. Her projeden öğrenilen dersler prompt'lara eklenmeli.

Önerilen güncelleme sıklığı:
- Minor (hata düzeltme): Her proje sonrası
- Major (yeni özellik): Ayda bir
- Breaking (mimari değişiklik): Çeyrekte bir

---

> **Son Not:** Bu sistem bir başlangıç noktasıdır. Her ekibin ihtiyaçlarına göre özelleştirilmelidir. Opus 4.5'in gücünü kullanarak sürekli iyileştirin.
