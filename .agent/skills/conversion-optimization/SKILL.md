---
name: conversion-optimization
description: CRO for landing pages, signup flows, and paywalls. Use when "optimize", "convert", "cro", "paywall", "signup" mentioned.
---

# 💰 Conversion Rate Optimization (CRO)

Combined skill from: `page-cro`, `signup-flow-cro`, `paywall-upgrade-cro`.

## Core Capabilities

### 1. Paywall & Upgrade Optimization
**Goal:** Convert Free -> Paid.

- **Value-First:** Show value *before* the paywall (Aha Moment first).
- **Trigger Points:**
  - Feature Gate (Clicking a Pro feature)
  - Usage Limit (3/3 projects used)
  - Trial End (3 days left warning)
- **Psychology:**
  - **Anchoring:** Show annual price vs monthly.
  - **Decoy:** "Pro" vs "Pro+" to make Pro look cheap.

### 2. Landing Page Optimization
- **Heuristic:** Lift Model (Value Prop, Relevance, Clarity, Urgency, Distraction, Anxiety).
- **Above the Fold:** Clear H1, Hero Image, Social Proof, CTA.
- **Copy:** Feature vs Benefit ("10GB Storage" vs "Never run out of space").

### 3. Signup Flow Friction
- **SSO:** Google/Apple Sign-in is mandatory.
- **Lazy Registration:** Let them use the app *before* asking for email.
- **Progressive Profiling:** Ask details later, not at signup.

## Usage

```bash
# Paywall Audit
/paywall-upgrade-cro --audit "AdhanLife Paywall Screen"

# Landing Page Check
/page-cro --url "https://adhanlife.com"
```
