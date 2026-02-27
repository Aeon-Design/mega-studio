---
name: studio-quality-guard
description: Ultimate autonomous testing, visual QA, and diagnostic system that generates fix plans for detected issues.
---

# 🛡️ Studio Quality Guard (SQG)

**Studio Quality Guard** is a high-level orchestration system designed to automate the entire QA pipeline—from feature discovery to diagnostic reporting and fix planning.

## 🚀 Core Capabilities

### 1. Feature-Centric Audit
Automated discovery of all screens and features in `lib/features/`.
- **Protocol:** `guardian.py --scan`
- **Output:** A Feature Map classifying current implementation status.

### 2. Multi-Scenario Verification
Executes tests across different scenarios:
- **Functional:** Integration tests (`integration_test/`) targeting happy paths.
- **Localization:** Verification of UI across supported locales.
- **Visual QA:** (Conceptual) screenshot comparison and layout overflow detection.

### 3. Diagnostic & Fix Planning
When a test fails, SQG doesn't just report it; it analyzes it.
- **Root Cause Analysis:** Connects stack traces to specific file lines.
- **Fix Plan Generation:** Produces a markdown plan with `[MODIFY]` suggestions to be consumed by `/debugger`.

## 🛠️ Usage for Agents

### `/orchestrate` (Master Role)
Use SQG to perform a full project health check before major releases or after large PRs.
```bash
python C:\Users\Abdullah\.agent\skills\studio-quality-guard\scripts\guardian.py --project . --full-audit
```

### `/debugger` (Fix Role)
Use SQG report to prioritize and solve bugs systematically.
```bash
# Read the latest audit report
view_file C:\Users\Abdullah\Projects\AdhanLife\adhan_life\.studio\audit\latest_report.md
```

## 📋 Reporting Standards
All reports must include:
1. **Quality Score:** A 0-100 rating based on Tests, Lint, and Build status.
2. **Feature Coverage:** List of tested vs. untested features.
3. **Critical Failures:** Detailed logs of blockers.
4. **Actionable Fix Plan:** Step-by-step instructions for the `/debugger`.
