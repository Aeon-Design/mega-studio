# Master Prompt Integration Plan

> **Goal:** Integrate 6 critical operational prompts into the Mega Studio agent system.

---

## 📋 Prompt Inventory & Agent Mapping

| # | Prompt Name | Primary Agent | Secondary Agent | Status |
|---|------------|---------------|-----------------|--------|
| 1 | Xiaomi Notification Fix | `/mobile` | `/android` | 🔴 Missing |
| 2 | AppConfig System | `/tech-lead` | `/mobile` | 🔴 Missing |
| 3 | Policy Generation | `/policy` | `/ceo` | 🟡 Partial |
| 4 | Master Release Audit | `/qa` | `/policy` | 🔴 Missing |
| 5 | Version Release Prompt | `/qa` | `/tech-lead` | 🔴 Missing |
| 6 | Store-Ready Workflow | `/policy` | `/qa` | 🔴 Missing |

---

## 🎯 Gap Analysis

### Missing Grimoires (Knowledge Base)
1. `release_engineering.md` - Master release audit protocols
2. `store_compliance.md` - Policy generation templates + Data Safety answers
3. `flutter_production.md` - AppConfig, versioning, cross-platform patterns
4. `platform_quirks.md` - Xiaomi, Samsung, Huawei-specific fixes

### Agent Updates Required
| Agent | Update Type | Content |
|-------|------------|---------|
| `qa-lead.md` | Add Protocol | "Pre-Release Audit Protocol" |
| `store-policy-expert.md` | Add Protocol | "Policy Generation Protocol" |
| `mobile-developer.md` | Add Skill | `platform_quirks.md` |
| `tech-lead.md` | Add Protocol | "AppConfig Enforcement Protocol" |

### New Workflows Required
| Workflow | Description |
|----------|-------------|
| `/release` | Triggers QA Lead for Master Release Audit |
| `/store-ready` | Triggers Policy Expert + QA for full store prep |

---

## 📦 Deliverables

### Phase 1: Create Grimoires
1. `release_engineering.md` - Contains:
   - Master Release Prompt
   - Version Release Prompt
   - Release Checklist Template

2. `store_compliance.md` - Contains:
   - Policy Generation Prompt
   - Data Safety Form answers
   - App Store Privacy answers
   - Store Policies Checklist

3. `flutter_production.md` - Contains:
   - AppConfig pattern (full code)
   - Versioning best practices
   - Cross-platform parity rules

4. `platform_quirks.md` - Contains:
   - Xiaomi/MIUI notification fix
   - Samsung-specific issues
   - Huawei HMS considerations

### Phase 2: Update Agents
- Add `release_engineering` skill to `/qa`
- Add `store_compliance` skill to `/policy`
- Add `flutter_production` skill to `/tech-lead`
- Add `platform_quirks` skill to `/mobile` and `/android`

### Phase 3: Create Workflows
- `/release` → QA Lead + Release Engineering
- `/store-ready` → Policy Expert + QA Lead

### Phase 4: Sync to GitHub
- Push all changes to `agent-flutters` repo

---

## ✅ Success Criteria
- [ ] All 6 prompts are accessible via agents
- [ ] New grimoires created and linked
- [ ] Workflows for `/release` and `/store-ready` work
- [ ] Changes synced to `agent-flutters` repo
