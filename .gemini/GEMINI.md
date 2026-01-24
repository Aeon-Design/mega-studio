---
description: Global agent rules. All operations must follow CORE.md directives and load appropriate skills.
---

# GEMINI.md - Mega Studio Configuration v7.0

> **Version 7.0 (Ultimate Evolution)** - The Constitution of the Autonomous Software Studio.
> **Total Agents:** 52 | **Skills:** 12 | **Grimoires:** 27
> This file defines the immutable laws of this workspace.

---

## 🗂️ DOSYA KONUMLARI (HER ZAMAN GÖRÜNÜR)

```
📂 MEGA STUDIO SYSTEM
│
├── 📋 GLOBAL CONFIG
│   ├── C:\Users\Abdullah\.gemini\GEMINI.md        ← BU DOSYA
│   └── C:\Users\Abdullah\.gemini\antigravity\CORE.md
│
├── 🤖 AJANLAR (52 adet)
│   ├── C:\Users\Abdullah\.agent\agents\           ← Ajan tanımları
│   └── C:\Users\Abdullah\.agent\agents\prompts\v1.0\  ← Detaylı promptlar
│       ├── orchestration\    (master-orchestrator, workflow-engine)
│       ├── flutter-core\     (architect, developer, state, bridge, deps, mock)
│       ├── quality\          (compiler, visual-qa, testing, error-sim)
│       ├── security-compliance\ (privacy, accessibility)
│       └── release-growth\   (sre, feedback, tech-writer)
│
├── 🛠️ SKİLLER (12 adet)
│   └── C:\Users\Abdullah\.agent\skills\
│       ├── flutter-foundations\
│       ├── clean-architecture\  (scripts: init_project.py, create_feature.py)
│       ├── state-management\    (scripts: create_bloc.py)
│       ├── testing-mastery\     (scripts: generate_tests.py)
│       ├── security-hardening\
│       ├── accessibility\
│       ├── performance-optimization\
│       ├── store-publishing\
│       ├── api-integration\
│       ├── ci-cd\
│       ├── localization\
│       ├── ux-writing\
│       └── skill_manager.py     ← Skill yönetim scripti
│
├── 📚 GRİMOİRELER (27 adet)
│   └── C:\Users\Abdullah\.gemini\knowledge\
│       ├── flutter_*.md         (9 grimoire)
│       ├── ios_advanced.md
│       ├── monetization_patterns.md
│       └── ... (27 total)
│
├── 🧠 ÖĞRENME SİSTEMİ
│   ├── C:\Users\Abdullah\.gemini\learning\patterns.md    ← Öğrenilen patternler
│   ├── C:\Users\Abdullah\.gemini\learning\mistakes.md    ← Yapılan hatalar
│   └── C:\Users\Abdullah\.gemini\learning\successes.md   ← Başarılı çözümler
│
└── 📁 PROJELER
    └── C:\Users\Abdullah\Projects\
        ├── AdhanLife\
        ├── WaterLife-1\
        ├── Finora\
        └── ... (17 proje)
```

---

## 🚀 VARSAYILAN AJAN: MASTER ORCHESTRATOR

**Tüm complex istekler otomatik olarak Master Orchestrator'a yönlendirilir.**

```yaml
default_agent: master-orchestrator
command: /orchestrate

capabilities:
  - PRD oluşturma
  - Mimari tasarım
  - Kod implementasyonu
  - Test coverage
  - Güvenlik kontrolü
  - Store submission
  - 7-Gate pipeline yönetimi
  - Skill ve ajan koordinasyonu
```

---

## 🧠 ÖĞRENME SİSTEMİ (CONTINUOUS EVOLUTION)

### Her görev sonunda:
1. **Başarılı çözümler** → `learning/successes.md`ye ekle
2. **Hatalar ve düzeltmeler** → `learning/mistakes.md`ye ekle
3. **Yeni patternler** → `learning/patterns.md`ye ekle
4. **Skill eksikleri** → İlgili SKILL.md'yi güncelle
5. **Grimoire ihtiyacı** → Yeni grimoire oluştur

### Öğrenme Protokolü:
```
Görev tamamlandı →
  │
  ├─► "Bu projeden ne öğrendim?"
  │       └─► patterns.md güncelle
  │
  ├─► "Hangi hataları yaptım?"
  │       └─► mistakes.md güncelle
  │
  └─► "Hangi çözüm işe yaradı?"
          └─► successes.md güncelle
```

---

## 🛑 THE DISTINGUISHED PROTOCOL

### 1. Socratic Gate
- Karmaşık görevlerden önce **3 soru** sor
- Belirsizlik varsa **kesinlikle sor**
- Assumption yapma

### 2. Skill Loading Protocol
```
Görev alındı →
  │
  ├─► Tetikleyici kelimeleri kontrol et
  │       └─► "bloc", "feature", "test" vs.
  │
  ├─► İlgili skill'in SKILL.md'sini oku
  │
  └─► Gerekli script veya referansları yükle
```

### 3. Self-Audit
- Her görev sonunda kalite kontrolü
- Learning system güncelleme
- Grimoire'lara katkı

---

## 📥 REQUEST CLASSIFIER

| Request Type | Trigger | Action |
|--------------|---------|--------|
| **QUESTION** | "nedir", "nasıl" | Açıkla |
| **SIMPLE CODE** | "düzelt", "ekle" | Inline edit |
| **COMPLEX CODE** | "oluştur", "yap" | /orchestrate |
| **NEW PROJECT** | "proje başlat" | /orchestrate + init_project.py |
| **NEW FEATURE** | "feature ekle" | clean-architecture skill |
| **BLOC/STATE** | "bloc", "state" | state-management skill |
| **TEST** | "test yaz" | testing-mastery skill |

---

## 🔧 HIZLI ERİŞİM KOMUTLARI

```bash
# Skill'leri listele
python C:\Users\Abdullah\.agent\skills\skill_manager.py --list

# Yeni feature oluştur
python C:\Users\Abdullah\.agent\skills\clean-architecture\scripts\create_feature.py --name <name>

# Bloc oluştur
python C:\Users\Abdullah\.agent\skills\state-management\scripts\create_bloc.py --name <name>

# Test oluştur
python C:\Users\Abdullah\.agent\skills\testing-mastery\scripts\generate_tests.py --type <type> --class <class>
```

---

## 🧠 MAESTRO FEATURES (YENİ!)

### Brain.py - Proje Hafızası
```bash
# Brain başlat (tech stack algıla)
python C:\Users\Abdullah\.agent\skills\brain.py --project <path> --init

# Brain göster
python C:\Users\Abdullah\.agent\skills\brain.py --project <path> --show

# Karar kaydet
python C:\Users\Abdullah\.agent\skills\brain.py --add-decision "Local-first yaklaşım"

# Tamamlanan iş kaydet
python C:\Users\Abdullah\.agent\skills\brain.py --add-completed "Login feature implemented"
```

### Ralph.py - Otonom QA
```bash
# 3 iterasyon otonom test
python C:\Users\Abdullah\.agent\skills\ralph.py --project <path> --iterations 3

# Sadece analyze
python C:\Users\Abdullah\.agent\skills\ralph.py --analyze

# Sadece test
python C:\Users\Abdullah\.agent\skills\ralph.py --test
```

### Verification Protocol
Her iş tamamlandığında 4 sütun:
1. ✅ Build passes
2. ✅ Tests pass
3. ✅ Lint clean
4. ✅ Format correct

---

## 📋 QUICK REFERENCE

| Ajan | Komut | Görev |
|------|-------|-------|
| Master Orchestrator | `/orchestrate` | Her şeyi A-Z yönet |
| Flutter Architect | `/architect` | Mimari tasarım |
| Mobile Developer | `/mobile-dev` | UI implementasyonu |
| Testing Agent | `/test` | Test yazma/coverage |
| Security Auditor | `/security` | Güvenlik kontrolü |
| Release Specialist | `/release` | Store hazırlık |

---

> **MEGA STUDIO:** Öğrenen, gelişen, mükemmelleşen AI geliştirme fabrikası.
