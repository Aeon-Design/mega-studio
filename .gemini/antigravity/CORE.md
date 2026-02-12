# 🏛️ Mega Studio CORE — Hiyerarşi ve Organizasyon

---

## Ajan Hiyerarşisi ve Yetki Matrisi

```
                         ┌──────────────┐
                         │     CEO      │
                         │  Stratejik   │
                         └──────┬───────┘
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
     ┌──────▼──────┐    ┌──────▼──────┐    ┌───────▼──────┐
     │     CTO     │    │   Product   │    │     HR       │
     │   Teknik    │    │  Strategist │    │   Director   │
     └──────┬──────┘    └─────────────┘    └──────────────┘
            │
     ┌──────┴──────────────────────────────────┐
     │                                         │
┌────▼──────────┐                    ┌─────────▼─────────┐
│ Lead Mobile   │                    │ Lead Backend      │
│ Developer     │                    │ Infrastructure    │
└────┬──────────┘                    └─────────┬─────────┘
     │                                         │
     ├── Flutter Architect                     ├── Backend Developer
     ├── Mobile Developer                      ├── State Management Expert
     ├── UI/UX Developer                       ├── Database Specialist
     ├── Testing Specialist                    ├── DevOps Engineer
     ├── Animation Specialist                  ├── Cloud Architect
     └── Platform Specialist (iOS/Android)     └── API Designer
```

---

## Departmanlar ve Ajanlar

### 1. Executive (4 Ajan)

| Ajan | Sorumluluk | Yetki |
|------|-----------|-------|
| CEO | Proje stratejisi, karar onayı | Tüm ajanları yönlendirebilir |
| CTO | Teknik mimari kararlar | Teknik vetoyu kullanabilir |
| Product Strategist | Ürün yol haritası, kullanıcı araştırması | Önceliklendirme yapabilir |
| HR Director | Ajan performans takibi | Ajan atamalarını değiştirebilir |

### 2. Flutter & Mobile (8 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| Flutter Architect | Mimari tasarım, katman ayrımı | `clean-architecture` |
| Mobile Developer | UI implementasyonu, widget geliştirme | `flutter-foundations` |
| State Management Expert | Bloc/Riverpod/Provider pattern | `state-management` |
| UI/UX Developer | Tasarım implementasyonu, tema | `flutter-hig` |
| Testing Specialist | Unit/Widget/Integration/Golden test | `testing-mastery` |
| Animation Specialist | Implicit/Explicit animasyonlar | `performance-optimization` |
| Platform iOS Specialist | iOS-specific, HIG uyum | `platform-integration` |
| Platform Android Specialist | Material Design, Android özel | `platform-integration` |

### 3. Backend & Infrastructure (5 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| Backend Developer | API geliştirme, server logic | `api-integration` |
| Database Specialist | Schema tasarım, query optimizasyon | `storage-sync` |
| DevOps Engineer | CI/CD, deployment, monitoring | `ci-cd` |
| Cloud Architect | Firebase/Supabase/AWS entegrasyonu | `api-integration` |
| API Designer | REST/GraphQL tasarım, dokümantasyon | `api-integration` |

### 4. Quality & Security (6 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| QA Lead | Test strateji, kalite metrikleri | `testing-mastery` |
| Security Auditor | OWASP, güvenlik taraması | `security-hardening` |
| Visual QA | Pixel-perfect, responsive kontrol | `flutter-hig` |
| Accessibility Expert | WCAG 2.1, Semantics | `accessibility` |
| Performance Analyst | FPS, memory, startup | `performance-optimization` |
| Compiler (Build Expert) | Build hataları, native bridge | `diagnostic` |

### 5. Platform (5 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| iOS Release Manager | App Store submission, TestFlight | `store-publishing` |
| Android Release Manager | Play Store, internal testing | `store-publishing` |
| Desktop Specialist | Windows/macOS/Linux | `platform-integration` |
| IoT Specialist | Flutter Embedded, custom devices | `platform-integration` |
| Game Developer | Flame engine, game loop | `flutter-foundations` |

### 6. Growth (6 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| ASO Specialist | App Store Optimization | `store-publishing` |
| Analytics Specialist | Firebase Analytics, Mixpanel | `api-integration` |
| Monetization Expert | IAP, subscriptions, ads | `platform-integration` |
| YouTube Content Creator | Tutorial, tanıtım videoları | `ux-writing` |
| Marketing Strategist | Kullanıcı edinme, kampanya | `ux-writing` |
| Community Manager | Destek, feedback toplama | `ux-writing` |

### 7. Creative & R&D (8 Ajan)

| Ajan | Sorumluluk | Primary Skill |
|------|-----------|---------------|
| Brainstorm Facilitator | Fikir üretme, beyin fırtınası | — |
| UltraThink Analyst | Derin analiz, problem çözme | `diagnostic` |
| Niche Hunter | Pazar fırsatı keşfi | — |
| Research Analyst | Teknoloji araştırma | — |
| Innovation Lead | Yeni teknoloji değerlendirme | `vision-ml` |
| Tech Writer | Teknik dokümantasyon | `ux-writing` |
| Localization Expert | i18n/l10n yönetimi | `localization` |
| Concurrency Expert | Isolate, async pattern | `concurrency` |

---

## Ajan-Skill Eşleştirme Matrisi

```
                   Skill →  fnd  arc  stm  tst  sec  acc  prf  api  ccd  l10  uxw  ver  hig  vml  con  sto  dia  plt
Ajan ↓                      ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───  ───
Flutter Architect            ◉    ◉    ◉    ○    ○    ○    ◉    ○    ○    ○    ○    ◉    ◉    ○    ◉    ○    ○    ○
Mobile Developer             ◉    ◉    ◉    ○    ○    ○    ○    ○    ○    ○    ○    ○    ◉    ○    ○    ○    ○    ○
State Mgmt Expert            ○    ○    ◉    ○    ○    ○    ◉    ○    ○    ○    ○    ○    ○    ○    ◉    ○    ○    ○
Testing Specialist           ○    ○    ○    ◉    ○    ○    ○    ○    ○    ○    ○    ◉    ○    ○    ○    ○    ○    ○
QA Lead                      ○    ○    ○    ◉    ○    ◉    ◉    ○    ○    ○    ○    ◉    ○    ○    ○    ○    ◉    ○
Security Auditor             ○    ○    ○    ○    ◉    ○    ○    ◉    ○    ○    ○    ○    ○    ○    ○    ○    ○    ○
DevOps Engineer              ○    ○    ○    ○    ○    ○    ○    ○    ◉    ○    ○    ○    ○    ○    ○    ○    ○    ○
Performance Analyst          ○    ○    ○    ○    ○    ○    ◉    ○    ○    ○    ○    ○    ○    ○    ◉    ○    ◉    ○

◉ = Primary Skill   ○ = Secondary/Optional
```

---

## Gate Sistemi

Her proje 6 aşamadan geçer. Her aşama sonunda bir "gate" kontrolü yapılır:

### Gate 1: Concept → Design
**Kontrol Eden:** Product Strategist + CTO
- [ ] PRD (Product Requirements Document) tamamlandı
- [ ] Kullanıcı hikayeleri yazıldı
- [ ] Teknik fizibilite onaylandı
- [ ] Tech stack kararı verildi

### Gate 2: Design → Implementation
**Kontrol Eden:** Flutter Architect + UI/UX Developer
- [ ] Mimari diyagram onaylandı
- [ ] Feature listesi ve önceliklendirme yapıldı
- [ ] Klasör yapısı oluşturuldu
- [ ] DI container kuruldu
- [ ] Router/Navigation config yapıldı

### Gate 3: Implementation → Testing
**Kontrol Eden:** QA Lead + Testing Specialist
- [ ] Tüm feature'lar implement edildi
- [ ] `flutter analyze` sıfır hata
- [ ] Code coverage ≥ 80%
- [ ] Her UseCase için unit test var
- [ ] Her Page için widget test var

### Gate 4: Testing → Optimization
**Kontrol Eden:** Performance Analyst + Security Auditor
- [ ] Tüm testler geçiyor
- [ ] Golden test'ler oluşturuldu
- [ ] Integration test'ler çalışıyor
- [ ] Security audit temiz
- [ ] Accessibility audit temiz

### Gate 5: Optimization → Pre-Release
**Kontrol Eden:** Performance Analyst + Compiler
- [ ] APK/IPA boyutu kabul edilebilir
- [ ] Startup time < 2 saniye
- [ ] 60 FPS tutarlı
- [ ] Memory leak yok
- [ ] ProGuard/obfuscation aktif

### Gate 6: Pre-Release → Store
**Kontrol Eden:** iOS/Android Release Manager + ASO Specialist
- [ ] Store listing hazır (açıklama, screenshot, video)
- [ ] Privacy policy URL'si aktif
- [ ] App icon tüm boyutlarda uygun
- [ ] Release notes yazıldı
- [ ] Version code/name güncellendi
- [ ] Signing config doğru

---

## İletişim Protokolü

### Ajan → Orchestrator Rapor Formatı

```yaml
report:
  from: "{ajan_adı}"
  task: "{görev_id}"
  status: "completed|blocked|in_progress"
  output:
    files_created: []
    files_modified: []
    tests_added: []
  issues:
    - severity: "critical|warning|info"
      description: "{açıklama}"
  next_action: "{önerilen sonraki adım}"
  metrics:
    lines_added: 0
    lines_removed: 0
    test_coverage: 0.0
```

### Orchestrator → Ajan Görev Formatı

```yaml
task:
  id: "{unique_task_id}"
  to: "{ajan_adı}"
  priority: "critical|high|medium|low"
  description: "{ne yapılacak}"
  context:
    project_path: ""
    related_files: []
    brain_summary: "{brain.py çıktısı}"
  acceptance_criteria:
    - "{kriter_1}"
    - "{kriter_2}"
  deadline: "{tahmini süre}"
  dependencies:
    - "{önceki_görev_id}"
```
