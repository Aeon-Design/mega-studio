# 🚀 Release Engineering Grimoire

> **Domain:** Production Release Audits, Version Management, Store Submissions
> **Primary Agent:** QA Lead (`/qa`)
> **Secondary:** Tech Lead (`/tech-lead`)

---

## 📋 Master Release Audit Protocol

Use this protocol before **FIRST PRODUCTION RELEASE** (Internal → Closed → Production).

### Role
Principal mobile engineer, release manager, and store-compliance auditor.

### Global Rules
1. **Ignore emulator-only issues** unless proven app-level defects
2. **Treat Flutter engine warnings** as non-blocking, not fixable at app level
3. **Focus ONLY on:** App code, Release builds, Store policies, Real production risks
4. **No hypothetical issues. No over-engineering.**

### Audit Checklist (Execute In Order)

#### 1️⃣ Code Health & Stability
```bash
flutter analyze
```
- Fix all errors
- Fix high-confidence warnings
- Remove dead code, debug flags, test configs
- Ensure release mode stability

#### 2️⃣ Platform Compatibility
- Verify Android API level compatibility (14/15)
- Modern system UI / edge-to-edge behavior
- No deprecated app-level APIs
- **Do NOT fix Flutter engine internals**

#### 3️⃣ Store Compliance
- App category matches functionality
- Description vs actual behavior alignment
- Screenshots & media accuracy
- No misleading claims
- Privacy policy, data safety, permissions verified

#### 4️⃣ In-App Purchases & Monetization
- Subscriptions audit
- Lifetime / one-time products
- Store-driven entitlement logic
- Account-based access (no local hacks)
- UI reflects real store behavior

#### 5️⃣ Versioning & Release Hygiene
- Semantic versioning consistency
- Build numbers incremented correctly
- No test tracks leaking into production
- Production build is clean and intentional

#### 6️⃣ Cross-Platform Readiness
- iOS App Store review compatible
- Future subscription changes supported
- Device diversity handled

### Final Deliverable
```markdown
## A. RELEASE CHECKLIST
- [ ] What was checked
- [ ] What was fixed
- [ ] What was intentionally ignored (and why)

## B. RISK SUMMARY
- Only REAL production risks
- No emulator-only or hypothetical issues

## C. FINAL VERDICT
✅ READY FOR PRODUCTION RELEASE
OR
❌ NOT READY – DO NOT PUBLISH
   - Blocking issues listed
   - Concrete fix steps provided
```

---

## 📋 Version Release Protocol

Use this protocol before **EVERY NEW VERSION** (after initial production release).

### Pre-Version Checklist

#### 1️⃣ Versioning Consistency
- Verify `pubspec.yaml` version (semantic + build number)
- Confirm Play Console / App Store version names match
- Patch = bugfixes, Minor = behavior changes

#### 2️⃣ Store Metadata Alignment
- Store description vs app behavior
- Screenshots vs actual UI
- Premium/demo/subscription claims accurate
- Ads behavior disclosed

#### 3️⃣ Monetization Audit
- Free usage boundaries verified
- No legacy trial/demo logic leaks
- No local-only unlock paths
- Widget/premium features respect entitlements

#### 4️⃣ UX Edge Cases
- No dead-end screens
- No unintentional paywalls
- No confusing CTAs
- Every screen has safe exit path

#### 5️⃣ Platform-Specific
**Android:**
- Target SDK compatibility
- In-App Review behavior
- Billing library usage

**iOS:**
- App Tracking Transparency
- StoreKit usage
- Restore purchases flow

#### 6️⃣ Data & State Integrity
- No duplicate events
- Idempotent writes
- Lifecycle handling verified

#### 7️⃣ Code Hygiene
- Dead code removed
- Debug prints removed
- `flutter analyze` clean

#### 8️⃣ Reviewer Simulation
- Test as first-time user
- No context, no willingness to "figure things out"
- If something could be misunderstood → fix it

### Final Deliverable
```markdown
## Fixes Applied
- [List of changes]

## Store-Ready: YES / NO
## Risk Assessment: Low / Medium / High
## Recommended Next Action: [if any]
```

---

## 📋 Store-Ready Workflow

Sequential tasks before store submission:

| Step | Task | Agent |
|------|------|-------|
| 1 | AppConfig setup (`--dart-define=ENV=prod`) | `/tech-lead` |
| 2 | Remove .txt files, organize docs to `docs/` | `/tech-lead` |
| 3 | Localization completeness check | `/localize` |
| 4 | Ad creatives + AdMob ID configuration | `/mobile` |
| 5 | Cross-platform parity verification | `/qa` |
| 6 | Website update + Policy generation | `/policy` |
| 7 | `flutter analyze` error resolution | `/tech-lead` |
| 8 | Android keystore configuration | `/android` |
| 9 | AdMob manifest integration | `/mobile` |
| 10 | Store → App review redirects | `/mobile` |

---

## 📝 Release Notes Template

For `docs/release_notes/v{version}.md`:

```markdown
# Release Notes - v{version}

**Release Date:** YYYY-MM-DD
**Build Number:** {build}

## ✨ New Features
- Feature 1
- Feature 2

## 🐛 Bug Fixes
- Fix 1
- Fix 2

## 🔧 Improvements
- Improvement 1

## ⚠️ Known Issues
- Issue 1 (will be fixed in next version)

## 📱 Platform Notes
### Android
- Min SDK: {version}
- Target SDK: {version}

### iOS
- Min iOS: {version}
```
