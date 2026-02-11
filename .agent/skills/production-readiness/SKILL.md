---
name: production-readiness
description: >
  Ensure apps are 100% store-ready, compliant, and operationally robust.
  Covers AppConfig, MinSDK checks, ID management, and Release documentation.
---

# 🛡️ Production Readiness Protocol

> "It's not done until it's shipped, safe, and scalable."

This skill bridges the gap between **Code** and **Store**. It ensures strict operational discipline.

---

## 1. AppConfig Architecture
**Mandatory Pattern:** centralized `AppConfig` class injected via DI.

```dart
class AppConfig {
  final String flavor;
  final String apiBaseUrl;
  final PlatformIds adIds;
  final PlatformIds appIds;
  final int minSupportedVersion;

  // Single source of truth
  static const AppConfig production = AppConfig(
    flavor: 'prod',
    apiBaseUrl: 'https://api.app.com',
    adIds: PlatformIds(
      ios: 'ca-app-pub-xxx/ios',
      android: 'ca-app-pub-xxx/android',
    ),
    // ...
  );
}
```
**Rule:** NEVER hardcode IDs in widgets. ALWAYS access via `config.adIds.ios` etc.

---

## 2. Release Documentation & Versioning
**Protocol:**
1. **Docs Update:** Every release MUST update `docs/release_notes/vX.Y.Z.md`.
2. **Format:**
   ```markdown
   # Release v1.2.0
   ## Features
   - [Feat] Dark mode support
   
   ## Fixes
   - [Fix] Login crash on iOS 15
   
   ## Technical
   - Bumped minSDK to 24 (Android)
   - Updated Flutter to 3.29
   ```

---

## 3. Platform & Policy Compliance
**Checks before build:**
- [ ] **MinSDK:** Verify specific `minSdkVersion` (Android) and `Deployment Target` (iOS) match business rules.
- [ ] **Cross-Platform:** Ensure feature parity or implementing "Graceful Degradation".
  - *Example:* If Apple Sign-In is iOS only, hide button on Android.
- [ ] **Policy Config:** Check past rejection database (learning/mistakes.md) for potential violations.

---

## 4. ID Management Strategy
**Rule:** Separate Test and Production IDs strictly.

| ID Type | Dev/Test | Production | Storage | Config |
|---------|----------|------------|---------|--------|
| AdMob | Test Unit IDs | Real Unit IDs | `AppConfig` | `Env` |
| Analytics| Debug View | Production Stream | `AppConfig` | `Env` |
| Maps | Unrestricted | Restricted (SHA-1) | `AndroidManifest` | `Env` |

---

## 5. Localization Audit
**Before Release:**
- Run `flutter gen-l10n`.
- Verify NO untranslated keys.
- Check RTL layout on physical device.

---

## 🔬 Audit Checklist
- [ ] AppConfig implemented & flavor-safe?
- [ ] Release Notes generated?
- [ ] Ad IDs separated (ios/android)?
- [ ] MinSDK versions verified?
