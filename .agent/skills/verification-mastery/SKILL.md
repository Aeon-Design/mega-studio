---
name: "Verification Mastery"
version: "1.0.0"
description: |
  Kanıt-tabanlı tamamlanma protokolü. İş bitmeden önce proof gerektirir.
  Maestro sisteminden adapte edilmiştir.
  Tetikleyiciler: "doğrula", "verify", "test et", "kontrol et", "kanıt"
primary_users:
  - master-orchestrator
  - flutter-testing-agent
  - qa-lead
dependencies:
  - testing-mastery
tags:
  - quality
  - verification
scripts:
  - ../ralph.py
---

# ✅ Verification Mastery

## Quick Start

**Temel Prensip:** "Trust, but verify." - İş yapıldı demeden önce kanıt göster.

---

## 📋 Verification Protocol

### 1. Four Pillars of Proof

Her iş tamamlandığında şu 4 sütun karşılanmalı:

| Sütun | Kanıt | Komut |
|-------|-------|-------|
| **Build** | ✅ Derleme başarılı | `flutter build apk --debug` |
| **Test** | ✅ Testler geçti | `flutter test` |
| **Lint** | ✅ Analiz temiz | `flutter analyze` |
| **Format** | ✅ Kod formatı doğru | `dart format --set-exit-if-changed` |

### 2. Verification Levels

```
Level 1: BASIC
└─► Build passes
└─► No compile errors

Level 2: STANDARD
└─► Level 1 +
└─► All tests pass
└─► No lint warnings

Level 3: STRICT (Production Ready)
└─► Level 2 +
└─► Coverage ≥ 80%
└─► No format issues
└─► Security scan clean
```

---

## 🎭 Ralph Wiggum Mode

Otonom QA döngüsü:

```bash
# 3 iterasyon otonom test
python C:\Users\Abdullah\.agent\skills\ralph.py --iterations 3 --project .

# Sadece analyze
python C:\Users\Abdullah\.agent\skills\ralph.py --analyze

# Sadece test
python C:\Users\Abdullah\.agent\skills\ralph.py --test
```

### Ralph'ın Çalışma Döngüsü

```
Iteration 1 ──────────────────────────────────────────────
    │
    ├─► flutter analyze
    ├─► flutter test --coverage
    ├─► dart format --check
    │
    └─► Issues bulundu? ─► Düzelt ─► Iteration 2'ye git
                          │
                          └─► Hepsi temiz? ─► ✅ DONE
```

---

## 📝 Evidence Collection

Her verification sonrası `.maestro/ralph/` klasörüne rapor yazılır:

```json
{
  "timestamp": "2026-01-24 19:45:00",
  "project": "/path/to/project",
  "summary": {
    "all_passed": true,
    "issues_found": 0,
    "tests_passed": 42,
    "tests_failed": 0,
    "coverage": 87.5
  }
}
```

---

## 🔒 Verification Checklist

### Before Completing Any Task:

- [ ] `flutter build` passes without errors
- [ ] `flutter test` passes all tests
- [ ] `flutter analyze` has no errors/warnings
- [ ] `dart format` shows no changes needed
- [ ] Coverage meets target (≥80% for production)

### Before PR/Merge:

- [ ] All above ✓
- [ ] CI pipeline green
- [ ] No TODO/FIXME comments
- [ ] Documentation updated
- [ ] Changelog entry added

### Before Release:

- [ ] All above ✓
- [ ] Release build tested on device
- [ ] Performance profiled
- [ ] Security audit passed
- [ ] Store assets ready

---

## ⚠️ Anti-Patterns

### ❌ YAPMA

```markdown
"Feature tamamlandı" (test yazmadan)
"Çalışıyor" (build vermeden)
"Bitti" (lint geçirmeden)
```

### ✅ YAP

```markdown
"Feature tamamlandı:
 - Build: ✅ APK generated
 - Tests: ✅ 15/15 passed
 - Coverage: 87%
 - Lint: ✅ 0 issues"
```

---

## 🔗 Integration

### With Orchestrator

```markdown
/orchestrate
"Add login feature. ralph 3 iterations"
```

### With Brain

```bash
# Task tamamlandığında brain'e kaydet
python brain.py --add-completed "Login feature - verified with 95% coverage"
```

---

## 📊 Metrics to Track

| Metric | Target | Red Flag |
|--------|--------|----------|
| Test Coverage | ≥ 80% | < 60% |
| Lint Issues | 0 | > 10 |
| Build Time | < 2 min | > 5 min |
| Test Time | < 1 min | > 3 min |

---

> **"No code is complete without proof it works."** - Verification Mastery
