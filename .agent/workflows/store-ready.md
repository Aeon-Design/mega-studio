---
description: Complete store-ready workflow including policies, audits, and config checks.
---

This workflow prepares an app for store submission. Execute in order:

## Phase 1: Configuration (Tech Lead)
1. Read `~/.gemini/knowledge/flutter_production.md`.
2. Implement AppConfig pattern if missing.
3. Verify `--dart-define=ENV=prod` build works.
4. Organize docs into `docs/` folder.

## Phase 2: Localization (Localizer)
1. Verify all ARB files are complete.
2. Check RTL support if applicable.

## Phase 3: Policy Generation (Store Policy Expert)
1. Read `~/.gemini/knowledge/store_compliance.md`.
2. Generate Privacy Policy, Terms, EULA.
3. Generate Data Safety Form answers.
4. Update website with policies.

## Phase 4: Code Health (Tech Lead)
1. Run `flutter analyze` - fix all errors.
2. Remove debug code, test configs.
3. Verify versioning in pubspec.yaml.

## Phase 5: Release Audit (QA Lead)
1. Read `~/.gemini/knowledge/release_engineering.md`.
2. Execute Pre-Release Audit Protocol.
3. Provide Final Verdict.

## Deliverable
- [ ] AppConfig implemented
- [ ] Localization complete
- [ ] Policies generated and published
- [ ] flutter analyze clean
- [ ] Release audit passed
