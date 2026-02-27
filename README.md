# 🏭 Mega Studio v8.0

> **Flutter için AI-Powered Geliştirme Stüdyosu**
> 52 Ajan • 19 Skill • 50+ Workflow • Maestro Features

Mega Studio, Antigravity (Gemini CLI) için tasarlanmış kapsamlı bir Flutter geliştirme sistemidir. A'dan Z'ye proje yönetimi, otonom kalite kontrolü ve modüler skill sistemi sunar. En güncel ana kurallar için lütfen [RULES.md](RULES.md) dosyasına göz atın.

---

## 📥 Kurulum

### Adım 1: Repo'yu İndir

```bash
git clone https://github.com/Aeon-Design/mega-studio.git
```

### Adım 2: Dosyaları Kopyala

Windows PowerShell:
```powershell
# .agent klasörünü kopyala
Copy-Item -Recurse "mega-studio\.agent" "$env:USERPROFILE\.agent" -Force

# .gemini klasörünü kopyala
Copy-Item -Recurse "mega-studio\.gemini" "$env:USERPROFILE\.gemini" -Force
```

macOS/Linux:
```bash
cp -r mega-studio/.agent ~/.agent
cp -r mega-studio/.gemini ~/.gemini
```

### Adım 3: Antigravity'yi Yeniden Başlat

Yeni bir Antigravity penceresi aç ve `/` yaz. 50+ workflow görünmeli.

---

## 🗂️ Klasör Yapısı

```
~/.agent/                          ← AJANLAR & SKİLLER
├── agents/                        ← 52 ajan tanımı
│   ├── ceo.md
│   ├── cto.md
│   ├── mobile-developer.md
│   └── prompts/v1.0/             ← Detaylı ajan promptları
│       ├── orchestration/
│       ├── flutter-core/
│       ├── quality/
│       └── ...
├── skills/                        ← 13 modüler skill
│   ├── clean-architecture/
│   │   └── scripts/
│   │       ├── init_project.py   ← Yeni proje başlat
│   │       └── create_feature.py ← Feature oluştur
│   ├── state-management/
│   │   └── scripts/create_bloc.py
│   ├── testing-mastery/
│   │   └── scripts/generate_tests.py
│   ├── brain.py                   ← Proje hafızası (LTM)
│   ├── ralph.py                   ← Otonom QA
│   └── skill_manager.py           ← Skill yönetimi
└── workflows/                     ← Legacy workflow'lar

~/.gemini/                         ← GLOBAL CONFIG
├── GEMINI.md                      ← Ana kurallar dosyası
├── antigravity/
│   ├── CORE.md                    ← Hiyerarşi ve organizasyon
│   └── global_workflows/          ← Antigravity slash komutları
│       ├── orchestrate.md
│       ├── architect.md
│       ├── mobile.md
│       └── ... (50+ workflow)
├── knowledge/                     ← 27 Grimoire (referans)
│   ├── flutter_architecture.md
│   ├── flutter_performance.md
│   └── ...
└── learning/                      ← Öğrenme sistemi
    ├── patterns.md               ← Öğrenilen patternler
    ├── mistakes.md               ← Yapılan hatalar
    └── successes.md              ← Başarılı çözümler
```

---

## 🚀 Kullanım

### Slash Komutları

Antigravity'de `/` yazarak tüm workflow'lara erişebilirsiniz:

| Komut | Açıklama |
|-------|----------|
| `/orchestrate` | Master Orchestrator - A'dan Z'ye proje yönetimi |
| `/architect` | Flutter Architect - Mimari tasarım |
| `/mobile` | Mobile Developer - UI implementasyonu |
| `/qa` | QA Lead - Test ve kalite |
| `/security` | Security Auditor - Güvenlik kontrolü |
| `/ralph` | Ralph Wiggum - Otonom QA döngüsü |
| `/brain` | Brain - Proje hafızası yönetimi |
| `/feature` | Yeni Clean Architecture feature oluştur |
| `/bloc` | Yeni Bloc state management oluştur |

### Script Kullanımı

#### Yeni Feature Oluşturma
```bash
cd /path/to/flutter/project
python ~/.agent/skills/clean-architecture/scripts/create_feature.py --name authentication
```

Bu komut şu yapıyı oluşturur:
```
lib/features/authentication/
├── data/
│   ├── datasources/authentication_remote_datasource.dart
│   ├── models/authentication_model.dart
│   └── repositories/authentication_repository_impl.dart
├── domain/
│   ├── entities/authentication.dart
│   ├── repositories/authentication_repository.dart
│   └── usecases/authentication_usecases.dart
└── presentation/
    ├── bloc/
    │   ├── authentication_bloc.dart
    │   ├── authentication_event.dart
    │   └── authentication_state.dart
    ├── pages/authentication_page.dart
    └── widgets/authentication_list_item.dart
```

#### Bloc Oluşturma
```bash
python ~/.agent/skills/state-management/scripts/create_bloc.py --name UserProfile --feature profile
```

#### Test Scaffold Oluşturma
```bash
# Unit test
python ~/.agent/skills/testing-mastery/scripts/generate_tests.py --type unit --class UserRepository

# Widget test
python ~/.agent/skills/testing-mastery/scripts/generate_tests.py --type widget --class ProfileCard

# Golden test
python ~/.agent/skills/testing-mastery/scripts/generate_tests.py --type golden --class HomePage
```

---

## 🧠 Maestro Features

### Brain.py - Proje Hafızası

Her proje için kalıcı hafıza sistemi. Tech stack, kararlar, hatalar ve tamamlanan işleri kayıt altına alır.

```bash
# Proje brain'ini başlat (tech stack otomatik algılanır)
python ~/.agent/skills/brain.py --project /path/to/project --init

# Brain özetini göster
python ~/.agent/skills/brain.py --project . --show

# Mimari karar kaydet
python ~/.agent/skills/brain.py --add-decision "Hive kullanarak offline-first yaklaşım"

# Tamamlanan iş kaydet
python ~/.agent/skills/brain.py --add-completed "Login feature implemented with 95% coverage"

# Bilinen hata kaydet
python ~/.agent/skills/brain.py --add-error "iOS 17.2+ notification permission issue"
```

### Ralph.py - Otonom QA

N iterasyon boyunca otonom test, lint ve build kontrolü yapar.

```bash
# 3 iterasyon otonom QA
python ~/.agent/skills/ralph.py --project . --iterations 3

# Sadece flutter analyze
python ~/.agent/skills/ralph.py --analyze

# Sadece flutter test
python ~/.agent/skills/ralph.py --test

# Build kontrolü
python ~/.agent/skills/ralph.py --build
```

Ralph'ın 4 Sütunu:
1. ✅ Build passes
2. ✅ Tests pass
3. ✅ Lint clean
4. ✅ Format correct

---

## 🤖 Ajan Hiyerarşisi

```
                    ┌─────────────────┐
                    │       CEO       │
                    │   (Stratejik)   │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼───────┐ ┌──────▼──────┐ ┌───────▼───────┐
    │      CTO      │ │   Product   │ │   HR Director │
    │  (Teknik)     │ │  Strategist │ │   (Ajanlar)   │
    └───────┬───────┘ └─────────────┘ └───────────────┘
            │
    ┌───────┴───────────────────────────┐
    │                                   │
┌───▼────────────┐            ┌─────────▼─────────┐
│ Lead Mobile Dev│            │ Lead Backend Infra│
│  (Squad Leader)│            │   (Squad Leader)  │
└───────┬────────┘            └─────────┬─────────┘
        │                               │
   ┌────┴────┐                    ┌─────┴─────┐
   │ Mobile  │                    │  Backend  │
   │ Squad   │                    │  Squad    │
   └─────────┘                    └───────────┘
```

### Departmanlar

| Departman | Ajan Sayısı | Örnekler |
|-----------|-------------|----------|
| Executive | 4 | CEO, CTO, Product Strategist, HR |
| Flutter & Mobile | 8 | Architect, Developer, State Manager, Testing |
| Backend & Infra | 5 | Backend, Database, DevOps, Infra |
| Quality & Security | 6 | QA, Security, Visual QA, Compiler |
| Platform | 5 | iOS, Android, Desktop, IoT, Game |
| Growth | 6 | ASO, Analytics, Monetization, YouTube |
| Creative & R&D | 8 | Brainstorm, UltraThink, Niche Hunter |

---

## 🛠️ Skills (19 Adet)

| Skill | Açıklama |
|-------|----------|
| `flutter-foundations` | Flutter temelleri ve widget yapısı |
| `clean-architecture` | Katman ayrımı ve SOLID prensipleri |
| `state-management` | Bloc ve Riverpod pattern'leri |
| `testing-mastery` | Unit, widget, golden ve integration testleri |
| `security-hardening` | OWASP Mobile Top 10, encryption |
| `accessibility` | WCAG 2.1 AA uyumluluk |
| `performance-optimization` | FPS optimizasyonu, memory yönetimi |
| `store-publishing` | App Store ve Play Store gereksinimleri |
| `api-integration` | Dio, Retrofit, network katmanı |
| `ci-cd` | GitHub Actions, Codemagic, Fastlane |
| `localization` | i18n, ARB dosyaları, RTL desteği |
| `ux-writing` | Microcopy, hata mesajları, onboarding |
| `verification-mastery` | Kanıt-tabanlı tamamlanma protokolü |
| **`flutter-hig`** | Apple HIG + Material Design platform-aware guidelines |
| **`vision-ml`** | ML Kit, TFLite, on-device AI |
| **`concurrency`** | Isolates, compute, async patterns |
| **`storage-sync`** | Hive, Drift, offline-first, cloud sync |
| **`diagnostic`** | Memory leaks, profiling, crash debugging |
| **`platform-integration`** | Widgets, IAP, push notifications, background tasks |

---

## 📚 Öğrenme Sistemi

Sistem sürekli öğrenir ve gelişir. Her görev sonunda:

| Dosya | İçerik |
|-------|--------|
| `learning/patterns.md` | Keşfedilen tekrar kullanılabilir patternler |
| `learning/mistakes.md` | Yapılan hatalar ve çözümleri |
| `learning/successes.md` | Başarılı çözümler ve best practices |

---

## 🔄 Tipik İş Akışı

```
1. /orchestrate "Pomodoro timer uygulaması yap"
   │
   ├─► Brain.py projeyi analiz eder
   ├─► Architect mimari tasarlar
   ├─► create_feature.py iskelet oluşturur
   │
2. Mobile Developer UI implement eder
   │
3. /ralph 3 iterations
   │
   ├─► Test çalıştırır
   ├─► Lint kontrol eder
   ├─► Build verify eder
   │
4. Security ve QA kontrolleri
   │
5. /release ile store hazırlık
```

---

## 📋 Gereksinimler

- **Antigravity** (Gemini CLI) yüklü olmalı
- **Python 3.8+** (script'ler için)
- **Flutter SDK** (geliştirme için)

---

## 🤝 Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/yeni-skill`)
3. Commit'leyin (`git commit -m 'Yeni skill eklendi'`)
4. Push'layın (`git push origin feature/yeni-skill`)
5. Pull Request açın

---

## 📄 Lisans

MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

> **Mega Studio:** Öğrenen, gelişen, mükemmelleşen AI geliştirme fabrikası.
