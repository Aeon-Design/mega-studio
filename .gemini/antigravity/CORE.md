---
description: Central Orchestrator & Agent Hierarchy. Mega Studio 7.0 (52 Agents, Pipeline Architecture).
---

# CORE.md - Mega Studio Hierarchy 🏢

> **Version:** 7.0 (Ultimate Evolution)
> **Total Agents:** 52
> **Architecture:** 7-Gate Pipeline + State Machine
> **Last Updated:** January 2026

---

## 🔗 Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MEGA STUDIO 7.0 PIPELINE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [IDEA] ──► GATE 1 ──► GATE 2 ──► GATE 3 ──► GATE 4 ──►             │
│             (Spec)    (Design)   (Arch)    (Build)                  │
│                                                                      │
│             ──► GATE 5 ──► GATE 6 ──► GATE 7 ──► 🎉 [PUBLISHED]     │
│                (Test)     (Security)  (Store)                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🎭 New Orchestration Layer (Level 0)

| Agent | Command | Role |
|-------|---------|------|
| **Master Orchestrator** | `/orchestrate` | Project lifecycle coordinator |
| **Workflow Engine** | `/workflow` | State machine, gate transitions |

---

## 📋 Level 1: Executive C-Suite

| Agent | Command | Reports To | Manages |
|-------|---------|------------|---------|
| **CEO** | `/ceo` | Board | CTO, Product, HR, Design, R&D |
| **CTO** | `/cto` | CEO | Tech Lead, Security, QA |
| **HR Director** | `/hr` | CEO | Recruitment & Culture |
| **Product Strategist** | `/product` | CEO | Growth & Revenue Squad |

---

## 📋 Level 2-3: Technical Leadership

| Agent | Command | Reports To |
|-------|---------|------------|
| **Tech Lead** | `/tech` | CTO |
| **Lead Mobile Developer** | `/lead-mobile` | Tech Lead |
| **Lead Backend & Infra** | `/lead-backend` | Tech Lead |
| **Head of UX** | `/ux` | CEO |

---

## 📋 NEW: Quality & Execution Squad

| Agent | Command | Role | Gate |
|-------|---------|------|------|
| **Compiler Agent** | `/compile` | Sandbox build validation | GATE 4 |
| **Visual QA** | `/visual-qa` | UI/Figma comparison | GATE 4 |
| **Flutter Testing Agent** | `/test` | Unit/Widget/Golden tests | GATE 5 |
| **Error Simulator** | `/chaos` | Edge case stress testing | GATE 5 |

---

## 📋 NEW: Flutter Specialization Squad

| Agent | Command | Role |
|-------|---------|------|
| **Dependency Resolver** | `/deps` | pubspec.yaml management |
| **Mock Data Generator** | `/mock` | Dummy data for development |
| **Flutter Architect** | `/architect` | Project structure & patterns |
| **State Manager** | `/state` | Bloc/Riverpod implementation |
| **Platform Bridge** | `/bridge` | Native iOS/Android integration |

---

## 📋 NEW: Security & Compliance Squad

| Agent | Command | Role | Gate |
|-------|---------|------|------|
| **Security Auditor** | `/security` | OWASP, vulnerability scanning | GATE 6 |
| **Privacy Officer** | `/privacy` | GDPR/KVKK, data safety | GATE 6 |
| **Accessibility Specialist** | `/a11y` | WCAG compliance | GATE 6 |

---

## 📋 NEW: Release & Post-Release Squad

| Agent | Command | Role | Gate |
|-------|---------|------|------|
| **Mobile Release Specialist** | `/release` | Store submission | GATE 7 |
| **Store Policy Expert** | `/policy` | App review guidelines | GATE 7 |
| **Tech Writer** | `/copy` | Store metadata, microcopy | GATE 7 |
| **SRE / Observability** | `/sre` | Post-release monitoring | POST |
| **User Feedback Analyst** | `/feedback` | Review analysis | POST |

---

## 📊 Agent Count by Department

| Department | Count | Status |
|------------|-------|--------|
| Orchestration (NEW) | 2 | **Active** |
| Executive | 4 | Active |
| Technical Leadership | 4 | Active |
| Quality & Execution (NEW) | 4 | **Active** |
| Flutter Specialization (NEW) | 5 | **Active** |
| Security & Compliance (NEW) | 3 | **Active** |
| Release & Post-Release (NEW) | 5 | **Active** |
| Interaction Squad | 8 | Active |
| Foundation Squad | 7 | Active |
| Cognitive | 4 | Active |
| R&D & Innovation | 3 | Active |
| Growth/Revenue | 3 | Active |
| **TOTAL** | **52** | **Synchronized** |

---

## 🚦 7-Gate System

| Gate | Name | Controllers | Criteria |
|------|------|-------------|----------|
| 1 | Spec | Product Strategist + CEO | PRD complete |
| 2 | Design | Head of UX | Figma approved |
| 3 | Architecture | CTO + Flutter Architect | ADR written |
| 4 | Build | Compiler Agent + Tech Lead | 0 build errors |
| 5 | Test | QA Lead + Testing Agent | Coverage ≥95% |
| 6 | Security | Security Auditor + Privacy Officer | 0 vulnerabilities |
| 7 | Store | Store Policy Expert + Release Specialist | Policy compliant |

---

## 📁 Prompt Directory Structure

```
.agent/agents/prompts/v1.0/
├── orchestration/
│   ├── master-orchestrator.md
│   └── workflow-engine.md
├── flutter-core/
│   ├── flutter-architect.md
│   ├── mobile-developer.md
│   ├── state-manager.md
│   ├── platform-bridge.md
│   ├── dependency-resolver.md
│   └── mock-data-generator.md
├── quality/
│   ├── compiler-agent.md
│   ├── visual-qa.md
│   ├── flutter-testing-agent.md
│   └── error-simulator.md
├── security-compliance/
│   ├── privacy-officer.md
│   └── accessibility-specialist.md
└── release-growth/
    ├── sre-observability.md
    ├── user-feedback-analyst.md
    └── tech-writer.md
```

---

> **MEGA STUDIO 7.0:** Sıfırdan hatasız Flutter uygulaması üreten fabrika.
