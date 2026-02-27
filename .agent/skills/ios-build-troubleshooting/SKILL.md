---
name: ios-build-troubleshooting
description: Comprehensive iOS build error detection and resolution for Flutter projects
version: "1.0.0"
author: "Mega Studio / iOS Platform Specialist"
triggers:
  - "iOS build error"
  - "Xcode error"
  - "CocoaPods"
  - "pod install"
  - "code signing"
  - "provisioning profile"
  - "Xcode Cloud"
  - "TestFlight"
  - "archive failed"
  - "export failed"
dependencies:
  - flutter-foundations
  - store-publishing
  - platform-integration
---

# 🔧 iOS Build Troubleshooting Skill

> **Expert-level iOS build error diagnosis and resolution for Flutter projects**

Bu skill, Flutter iOS build sürecinde karşılaşılan hataları tespit eder ve çözer.

---

## 📋 Error Categories

### 1. Package Dependency Conflicts
### 2. CocoaPods Configuration Issues  
### 3. Swift API Compatibility Errors
### 4. Code Signing & Provisioning
### 5. Xcode Cloud Configuration
### 6. Generated Files Conflicts
### 7. App Store Submission Errors (ITMS)

---


## 🔍 CATEGORY 1: Package Dependency Conflicts

### Symptom Detection
```
Because [package] X.X.X requires SDK version >=X.X.X <X.X.X
version solving failed
```

### Diagnostic Checklist
```bash
# 1. Check current Flutter/Dart version
flutter --version

# 2. Check package requirements
flutter pub deps

# 3. Identify conflicting packages
flutter pub get 2>&1 | grep "requires"
```

### Common Incompatible Packages (Dart 3.5.0 / Flutter 3.24.0)

| Package | Problem Version | Compatible Version | Required SDK |
|---------|-----------------|-------------------|--------------|
| `google_mobile_ads` | ^7.0.0 | ^5.0.0 | Dart >=3.9.0 |
| `google_fonts` | ^8.0.1 | ^6.0.0 | Dart >=3.9.0 |
| `flutter_local_notifications` | ^20.0.0 | ^18.0.0 | Dart >=3.6.0 |
| `app_links` | ^7.0.0 | ^6.4.1 | Dart >=3.10.0 |
| `flutter_lints` | ^6.0.0 | ^5.0.0 | Dart >=3.6.0 |
| `workmanager` | ^0.9.0 | ^0.7.0 | Flutter >=3.32.0 |
| `home_widget` | ^0.9.0 | ^0.7.0 | Flutter >=3.32.0 |
| `flutter_svg` | ^2.2.3 | ^2.0.17 | Dart >=3.8.0 |
| `image_picker` | ^1.1.2 | ^1.0.7 | Dart >=3.6.0 |
| `awesome_notifications` | ^0.10.1 | ^0.10.0 | intl conflict |

### Resolution Steps
```yaml
# pubspec.yaml - Downgrade to compatible versions
dependencies:
  google_mobile_ads: ^5.0.0
  google_fonts: ^6.0.0
  flutter_local_notifications: ^18.0.0
  # ... other compatible versions
```

### intl Version Conflict (Special Case)
```
awesome_notifications requires intl ^0.20.0
flutter_localizations pins intl 0.19.0
```
**Solution:** Downgrade `awesome_notifications` to `^0.10.0`

---

## 🔍 CATEGORY 2: CocoaPods Configuration Issues

### Symptom Detection
```
Invalid `Podfile` file: cannot load such file
Pods not found
Google-Mobile-Ads-SDK version mismatch
```

### Issue 2.1: Generated.xcconfig with Wrong Path

**Symptom:**
```
cannot load such file -- /path/to/C:\Users\PC\flutter
```

**Cause:** `Generated.xcconfig` committed with Windows path

**Solution:**
```bash
# Remove from git tracking (file is auto-generated)
git rm --cached ios/Flutter/Generated.xcconfig
git commit -m "fix: remove Generated.xcconfig from git"
```

**Prevention:** Ensure in `.gitignore`:
```gitignore
**/ios/Flutter/Generated.xcconfig
```

### Issue 2.2: Podfile.lock Version Mismatch

**Symptom:**
```
CocoaPods could not find compatible versions for pod "Google-Mobile-Ads-SDK":
  In snapshot (Podfile.lock): X.X.X
  In Podfile: ~> Y.Y.Y
```

**Solution:**
```bash
# Remove stale lock file
git rm --cached ios/Podfile.lock
git commit -m "fix: remove Podfile.lock - regenerate on CI"
```

### Issue 2.3: Optional Pods Include

**Symptom:** Build fails before `pod install` completes

**Solution:** Make Pods includes optional in xcconfig:
```xcconfig
# ios/Flutter/Debug.xcconfig
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"

# ios/Flutter/Release.xcconfig  
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
```

### Issue 2.4: Clean CocoaPods Installation

**CI/CD Script:**
```bash
cd ios
rm -rf Pods
rm -rf ~/Library/Caches/CocoaPods
rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate || true
pod cache clean --all
pod install --repo-update --verbose
```

---

## 🔍 CATEGORY 3: Swift API Compatibility Errors

### Issue 3.1: AppIntents ParameterSummary

**Symptom (Xcode 16+):**
```
Cannot infer key path type from context
No exact matches in call to initializer
```

**Problem Code:**
```swift
static var parameterSummary: some ParameterSummary {
    When(\.$amount == nil, {
        Summary("Log water")
    }, otherwise: {
        Summary("Log \(\.$amount) ml")
    })
}
```

**Solution - Simplified:**
```swift
static var parameterSummary: some ParameterSummary {
    Summary("Log \(\.$amount) milliliters of water")
}
```

### Issue 3.2: IntentDialog Initialization

**Symptom:**
```
Missing argument label 'stringLiteral:' in call
```

**Problem:**
```swift
return .result(dialog: IntentDialog(message))
```

**Solution:**
```swift
return .result(dialog: "Your message here")
```

### Issue 3.3: App Shortcut Utterances

**Symptom:**
```
Invalid Utterance. Every App Shortcut utterance should have one '${applicationName}'
```

**Problem:** Phrases without applicationName:
```swift
phrases: [
    "I drank water",  // ❌ No applicationName
    "Log water in \(.applicationName)"  // ✅ Has applicationName
]
```

**Solution:** Every phrase MUST include `\(.applicationName)`:
```swift
phrases: [
    "Log water in \(.applicationName)",
    "Add water in \(.applicationName)",
    "Track water with \(.applicationName)"
]
```

---

## 🔍 CATEGORY 4: Code Signing & Provisioning

### Issue 4.1: Missing Provisioning Profile

**Symptom:**
```
Exporting for Ad Hoc Distribution failed
Exporting for Development Distribution failed
Command exited with non-zero exit-code: 70
```

**Diagnosis:**
1. Go to Apple Developer Portal → Certificates, Identifiers & Profiles
2. Check **Profiles** section
3. If empty, create new profile

**Solution - Create App Store Profile:**
1. Profiles → Generate a profile
2. Select: **App Store Connect** (under Distribution)
3. Select App ID: `com.yourcompany.yourapp`
4. Select Certificate: Your Distribution certificate
5. Name it: `YourApp App Store`
6. Generate

### Issue 4.2: Xcode Cloud Signing

**For Xcode Cloud (Automatic):**
1. Xcode Cloud creates certificates automatically
2. Look for "Distribution Managed (Xcode Cloud)" in Certificates
3. Profile sync may take 5-15 minutes

**Workflow Settings:**
- Distribution Preparation: **TestFlight (Internal Testing Only)**
- NOT "None"

---

## 🔍 CATEGORY 5: Xcode Cloud Configuration

### Issue 5.1: ci_post_clone.sh Not Executable

**Symptom:**
```
The ci_post_clone.sh is not executable
```

**Solution:**
```bash
# On Windows with Git
git update-index --chmod=+x ios/ci_scripts/ci_post_clone.sh
git add ios/ci_scripts/ci_post_clone.sh
git commit -m "fix: make ci_post_clone.sh executable"
```

### Issue 5.2: Flutter Not Found in Xcode Cloud

**Required Script:** `ios/ci_scripts/ci_post_clone.sh`
```bash
#!/bin/sh
set -e

echo "=== ci_post_clone.sh started ==="
cd $CI_PRIMARY_REPOSITORY_PATH

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Prepare
flutter precache --ios
flutter doctor -v
flutter pub get

# CocoaPods
cd ios
pod install --repo-update

echo "=== ci_post_clone.sh completed ==="
```

### Issue 5.3: Xcode Version Compatibility

**If bitcode_strip errors occur:**
- Workflow → Environment → Xcode Version
- Try specific version like "Xcode 15.4" instead of "Latest"

---

## 🔍 CATEGORY 6: Deprecation Warnings (Non-Blocking)

### StoreKit Deprecation Warnings

**Symptom:** ~40+ warnings like:
```
'SKPaymentQueue' is deprecated: first deprecated in iOS 18.0
'SKProduct' is deprecated: first deprecated in iOS 18.0
```

**Source:** `in_app_purchase` Flutter package

**Impact:** ⚠️ Warnings only - **DOES NOT block build**

**Notes:**
- These are iOS 18 StoreKit 2 migration notices
- Flutter team will update `in_app_purchase` package
- No action required unless you own the native code

---

## 🔍 CATEGORY 7: App Store Submission Errors

### Issue 7.1: ITMS-90717 - Invalid App Icon (Alpha Channel)

**Symptom:**
```
ITMS-90717: Invalid large app icon
The app icon in the asset catalog can't be transparent.
```

**Cause:** App icon has alpha channel (transparency). Apple **does not allow** transparent app icons.

**Diagnosis:**
```bash
# Check if icon has alpha channel
sips -g hasAlpha ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-1024.png
# If hasAlpha: yes → Problem!
```

**Solution:**
```bash
# Remove alpha channel using sips (macOS)
cd ios/Runner/Assets.xcassets/AppIcon.appiconset
for f in *.png; do
  sips -s format png -r 0 "$f" --out "$f"
done

# Or using ImageMagick
convert Icon-1024.png -alpha off Icon-1024.png
```

**Alternative - Photoshop/GIMP:**
1. Open icon file
2. Add solid background layer (white or brand color)
3. Flatten image
4. Export as PNG **without transparency**

**Prevention:**
- Always export app icons with solid background
- Use AppIconMaker.co or similar tools that auto-remove transparency
- Add pre-flight check in CI:
```bash
hasAlpha=$(sips -g hasAlpha Icon-1024.png | grep hasAlpha | awk '{print $2}')
if [ "$hasAlpha" = "yes" ]; then
  echo "ERROR: Icon has alpha channel!"
  exit 1
fi
```

### Issue 7.2: ITMS-90027 - Missing Required Sizes

**Symptom:**
```
ITMS-90027: The bundle contains an invalid large app icon
Expected icons: 1024x1024
```

**Solution:** Ensure ALL required sizes exist in AppIcon.appiconset:
- 20x20 (1x, 2x, 3x)
- 29x29 (1x, 2x, 3x)
- 40x40 (1x, 2x, 3x)
- 60x60 (2x, 3x)
- 76x76 (1x, 2x)
- 83.5x83.5 (2x)
- 1024x1024 (1x - App Store)

### Issue 7.3: ITMS-90057 / ITMS-90360 - Widget Extension Version Missing

**Symptom:**
```
ITMS-90057: The bundle 'Payload/Runner.app/PlugIns/WaterLifeWidgetExtension.appex' 
is missing plist key: CFBundleShortVersionString

ITMS-90360: Missing Info.plist value - 'CFBundleShortVersionString' in bundle 
Runner.app/PlugIns/WaterLifeWidgetExtension.appex is required.
```

**Also related:**
```
The CFBundleVersion of an app extension (null) must match that of its 
containing parent app ('43').
```

**Cause:** Widget Extension's `Info.plist` uses build variables (`$(MARKETING_VERSION)`, `$(CURRENT_PROJECT_VERSION)`) that are not defined in the extension's build settings, resulting in null values.

**Diagnosis:**
```bash
# Check Widget Extension Info.plist
cat ios/WaterLifeWidgetExtension/Info.plist | grep -A1 "CFBundleShortVersionString"
cat ios/WaterLifeWidgetExtension/Info.plist | grep -A1 "CFBundleVersion"

# If values show $(MARKETING_VERSION) or $(CURRENT_PROJECT_VERSION), they may be null
```

**Solution - Quick Fix (Hard-coded):**
Update `ios/[ExtensionName]/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.1</string>  <!-- Match main app version -->
<key>CFBundleVersion</key>
<string>43</string>  <!-- Match main app build number -->
```

**Solution - Proper Integration:**
1. Open Xcode
2. Add extension target to project properly
3. Set `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in extension's Build Settings
4. Or use Flutter variables: `$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)`

### ⚠️ PRE-RELEASE CHECKLIST (iOS Agent Must Check)

Before every App Store submission, verify:

```bash
# 1. Main app version
grep FLUTTER_BUILD_NAME pubspec.yaml
grep FLUTTER_BUILD_NUMBER pubspec.yaml

# 2. Widget Extension version (must match!)
cat ios/*/Info.plist | grep -A1 "CFBundleShortVersionString"
cat ios/*/Info.plist | grep -A1 "CFBundleVersion"
```

**Rule:** Extension's `CFBundleShortVersionString` and `CFBundleVersion` MUST match parent app.

---

## 🛠️ Quick Diagnostic Script


```bash
#!/bin/bash
# ios_build_diagnostic.sh

echo "=== Flutter/Dart Versions ==="
flutter --version

echo "=== iOS Deployment Target ==="
grep IPHONEOS_DEPLOYMENT_TARGET ios/Runner.xcodeproj/project.pbxproj | head -5

echo "=== Checking pubspec.yaml for known problematic packages ==="
grep -E "(google_mobile_ads|google_fonts|flutter_local_notifications|app_links|workmanager|home_widget)" pubspec.yaml

echo "=== Checking for Generated.xcconfig in git ==="
git ls-files ios/Flutter/Generated.xcconfig

echo "=== Checking for Podfile.lock in git ==="
git ls-files ios/Podfile.lock

echo "=== Script permissions ==="
ls -la ios/ci_scripts/*.sh 2>/dev/null || echo "No CI scripts found"

echo "=== Checking App Icon alpha channel ==="
sips -g hasAlpha ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-1024.png 2>/dev/null || echo "Icon not found"

echo "=== Diagnostic complete ==="
```

---

## 📚 References

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Xcode Cloud Documentation](https://developer.apple.com/xcode-cloud/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [CocoaPods Troubleshooting](https://guides.cocoapods.org/using/troubleshooting.html)
- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2026-02-09 | Added Issue 7.3: ITMS-90057/90360 Widget Extension Version + PRE-RELEASE CHECKLIST |
| 1.1.0 | 2026-02-09 | Added Category 7: App Store Submission Errors (ITMS-90717, ITMS-90027) |
| 1.0.0 | 2026-02-09 | Initial release based on WaterLife build debugging session |


