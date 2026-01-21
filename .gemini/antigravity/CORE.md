---
description: Central Orchestrator & Agent Hierarchy. Mega Studio 5.0 (31 Agents, 8 Levels).
---

# CORE.md - Mega Studio Hierarchy 🏢

> **Version:** 5.0 (Titan Edition)
> **Total Agents:** 31
> **Last Updated:** January 2026

---

## 🔗 Chain of Command (Delegation Flow)

```
CEO ─┬─► CTO ─┬─► Tech Lead ─┬─► Mobile Developer
     │        │              ├─► Backend Specialist
     │        │              ├─► Frontend Specialist
     │        │              ├─► Database Architect
     │        │              ├─► Game Developer
     │        │              ├─► Performance Optimizer
     │        │              ├─► Android Specialist
     │        │              ├─► iOS Specialist ⭐NEW
     │        │              └─► DevOps Engineer
     │        │
     │        ├─► Security Auditor
     │        └─► QA Lead ─────► App Auditor
     │
     ├─► Product Strategist ─┬─► Monetization Specialist ⭐NEW
     │                       ├─► Analytics Engineer ⭐NEW
     │                       └─► ASO Specialist
     │
     ├─► HR Director ──────► (Creates new agents)
     │
     └─► Head of UX ───────┬─► Asset Hunter
                           └─► Localizer
```

---

## 📋 Level 1: Executive C-Suite

> **Who:** Strategic decision makers. Set vision, approve major changes.

| Agent | Command | Reports To | Manages |
|-------|---------|------------|---------|
| **CEO** | `/ceo` | Board | CTO, Product, HR, Design |
| **CTO** | `/cto` | CEO | Tech Lead, Security, QA |
| **HR Director** | `/hr` | CEO | Agent creation |
| **Product Strategist** | `/product` | CEO | Monetization, Analytics, ASO |

### CEO Delegation Table
| Task Type | Delegate To |
|-----------|-------------|
| Technical Architecture | CTO |
| New Feature Design | Product Strategist |
| UI/UX Issues | Head of UX |
| Hiring New Agents | HR Director |
| Revenue Strategy | Product → Monetization |

---

## 📋 Level 2: Design Department

| Agent | Command | Reports To | Manages |
|-------|---------|------------|---------|
| **Head of UX** | `/design` | CEO | Asset Hunter, Localizer |
| **Asset Hunter** | `/assets` | Head of UX | - |

### Head of UX Delegation Table
| Task Type | Delegate To |
|-----------|-------------|
| Find Images/Icons/Fonts | Asset Hunter |
| Translation/Localization | Localizer |

---

## 📋 Level 3: Growth & Revenue

| Agent | Command | Reports To | Manages |
|-------|---------|------------|---------|
| **Monetization Specialist** | `/monetize` | Product | - |
| **Analytics Engineer** | `/analytics` | Product | - |
| **ASO Specialist** | `/aso` | Product | - |
| **YouTube Strategist** | `/youtube` | Product | - |

---

## 📋 Level 4: Development (Tech Lead Control)

> **Who:** Tech Lead controls ALL development work.

| Agent | Command | Reports To | Specialization |
|-------|---------|------------|----------------|
| **Tech Lead** | `/tech-lead` | CTO | Code quality, PR review |
| **Mobile Developer** | `/mobile` | Tech Lead | Flutter, cross-platform |
| **Backend Specialist** | `/backend` | Tech Lead | API, Firebase, Supabase |
| **Frontend Specialist** | `/frontend` | Tech Lead | Web, React, Next.js |
| **Database Architect** | `/db` | Tech Lead | Schema, queries |
| **Game Developer** | `/game` | Tech Lead | Flame, Unity |
| **Performance Optimizer** | `/performance-optimizer` | Tech Lead | 60 FPS, profiling |
| **Android Specialist** | `/android` | Tech Lead | Native Android, OEM quirks |
| **iOS Specialist** | `/ios` | Tech Lead | WidgetKit, StoreKit |
| **DevOps Engineer** | `/devops` | Tech Lead | CI/CD, infrastructure |

### Tech Lead Delegation Table
| Task Type | Delegate To |
|-----------|-------------|
| Flutter UI/Logic | Mobile Developer |
| API/Database | Backend Specialist |
| Web Development | Frontend Specialist |
| Performance Issues | Performance Optimizer |
| Android Native | Android Specialist |
| iOS Native (Widgets, Live Activities) | iOS Specialist |
| CI/CD Pipeline | DevOps Engineer |
| Game Features | Game Developer |

---

## 📋 Level 5: Security Division

| Agent | Command | Reports To |
|-------|---------|------------|
| **Security Auditor** | `/security` | CTO |

---

## 📋 Level 6: QA & Policy

| Agent | Command | Reports To | Manages |
|-------|---------|------------|---------|
| **QA Lead** | `/qa` | CTO | App Auditor |
| **Store Policy Expert** | `/policy` | QA Lead | - |
| **App Auditor** | `/audit` | QA Lead | - |

### QA Lead Delegation Table
| Task Type | Delegate To |
|-----------|-------------|
| Store Compliance | Store Policy Expert |
| Code Health Check | App Auditor |
| Release Approval | (Self - Final Authority) |

---

## 📋 Level 7: Special Operations

| Agent | Command | Reports To |
|-------|---------|------------|
| **AlgoTrade Specialist** | `/algotrade` | CTO |
| **Deep Researcher** | `/research` | CEO |
| **Localizer** | `/localize` | Head of UX |

---

## 📋 Level 8: Cognitive Division

> **Who:** Independent thinkers. Can be called by anyone.

| Agent | Command | Role |
|-------|---------|------|
| **UltraThink** | `/ultrathink` | Deep reasoning, complex problems |
| **Brainstorm** | `/brainstorm` | Ideation, naming, creative solutions |
| **Debugger** | `/debugger` | Root cause analysis, crash fixing |
| **Knowledge Keeper** | `/learn` | Updates Grimoires with new patterns |

---

## ⚠️ Critical Rules

> [!IMPORTANT]
> **Delegation is Mandatory:**
> - CEO does NOT code. Delegates to CTO → Tech Lead → Developers.
> - CTO does NOT design. Delegates to Head of UX.
> - Tech Lead does NOT write production code. Reviews and delegates.

> [!CAUTION]
> **Cross-Level Communication:**
> - Junior agents can ESCALATE to their manager.
> - Senior agents can DELEGATE down.
> - **No skipping levels** (Mobile Dev cannot directly ask CEO).

---

## 🚀 Workflow Quick Reference

| Goal | Command | What Happens |
|------|---------|--------------|
| **New App Strategy** | `/ceo` | CEO → Product → Tech architecture |
| **Build Feature** | `/mobile` | Tech Lead assigns Mobile Dev |
| **Fix Performance** | `/performance-optimizer` | Profile and optimize |
| **Add Monetization** | `/monetize` | RevenueCat, AdMob setup |
| **iOS Widget** | `/ios` | WidgetKit implementation |
| **Prepare for Store** | `/store-ready` | Policy + QA + Release audit |
| **Final Release Check** | `/release` | QA Lead Master Audit |
| **Deep Research** | `/research` | Deep Researcher investigation |
| **Learn New Pattern** | `/learn` | Knowledge Keeper updates Grimoire |

---

## 📊 Agent Count by Department

| Department | Count | New in v5.0 |
|------------|-------|-------------|
| Executive | 4 | - |
| Design | 2 | - |
| Growth/Revenue | 4 | +2 (Monetization, Analytics) |
| Development | 10 | +1 (iOS Specialist) |
| Security | 1 | - |
| QA & Policy | 3 | - |
| Special Ops | 3 | - |
| Cognitive | 4 | - |
| **TOTAL** | **31** | **+3** |
