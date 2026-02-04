---
name: flutter-security-audit
description: Comprehensive security auditing using MobSF, Static Analysis, and Supply Chain defense.
---

# 🛡️ Flutter Security Audit

## 🕵️ MobSF (Mobile Security Framework)
The industry standard for binary analysis.
- **Action:** Run MobSF in Docker against your `.apk` / `.ipa`.
- **Checks:** Hardcoded secrets, Insecure permissions, Weak cryptography, Cleartext traffic.

## 🧹 Static Analysis & Custom Lints
Don't rely on reviews. Enforce security in code.
- **Tool:** `custom_lint` package.
- **Rules to Enforce:**
    - `avoid_print`: No logs in production.
    - `secure_storage`: For auth tokens (never SharedPreferences).
    - `unawaited_futures`: potential for race conditions/memory leaks.

## ⛓️ Supply Chain Security
- **SBOM:** Generate Software Bill Of Materials.
- **Audit:** Check `pubspec.lock` for known CVEs in dependencies.
- **Obfuscation:** Ensure `--obfuscate --split-debug-info` is used for ALL release builds.

## 🔐 Best Practices
1.  **Certificate Pinning:** Mandatory for FinTech/Health.
2.  **Biometrics:** Use `local_auth` with `biometricOnly: true` for high security.
3.  **Jailbreak Detection:** Check device integrity before performing sensitive ops.
