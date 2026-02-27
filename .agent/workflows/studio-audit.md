---
description: Perform a full project quality audit with the Studio Quality Guard system.
---

# /studio-audit Workflow

This workflow executes a comprehensive project health check, scans all features, and generates an actionable quality report.

## Steps

1. **Verify Environment**: Ensure Flutter is installed and you are in the project root.
2. **Execute Guardian**:
// turbo
```bash
python C:\Users\Abdullah\.agent\skills\studio-quality-guard\scripts\guardian.py --project . --full-audit
```
3. **Analyze Report**: Read the generated report at `[project_root]/.studio/audit/latest_report.md`.
4. **Distribute Tasks**:
   - If build/analyze fails: Activate `/debugger`.
   - If tests fail: Use the "Fix Plan" in the report to guide implementation.
   - If visual issues are noted: Adjust UI components accordingly.
