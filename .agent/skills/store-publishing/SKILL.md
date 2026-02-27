---
name: store-publishing
description: Comprehensive guide for App Store Optimization (ASO), Build Generation, and Store Submission (iOS/Android).
---

# 🚀 Store Publishing & ASO Skill

> Master the art of optimizing, building, and publishing mobile apps.
> Combines strategic ASO with technical Release Engineering.

---

## 🧠 Part 1: App Store Optimization (ASO)

### 1.1 Metadata Strategy
Optimize your store listing *before* you build.

#### Apple App Store
- **Title (30 chars):** Brand Name + Main Keyword (e.g., "Mega Studio: Flutter IDE")
- **Subtitle (30 chars):** Unique Value Prop + Secondary Keyword (e.g., "AI-Powered Code Assistant")
- **Keywords (100 chars):** comma,separated,no,spaces,singular,forms,only
- **Promotional Text (170 chars):** Editable without updat. Use for announcements/sales.
- **Description:** First 3 lines are critical. Focus on benefits, not features.

#### Google Play Store
- **Title (30/50 chars):** Brand + Keyword
- **Short Description (80 chars):** The "Subtitle" equivalent. High conversion impact.
- **Full Description (4000 chars):** SEO-rich. Repeat main keywords 3-5 times naturally.

### 1.2 Keyword Research Checklist
1.  **Brainstorm:** List 50+ words related to your app.
2.  **Volume vs. Competition:**
    *   High Volume / High Comp: Hard to rank (e.g., "Fitness")
    *   Mid Volume / Low Comp: Sweet spot (e.g., "Postpartum Yoga")
3.  **Long-Tail:** "Offline Todo List for Students" > "Todo List"
4.  **Localization:** Do NOT auto-translate keywords. Research per market.

### 1.3 Asisstant Prompt for ASO
Use the `aso-specialist` agent for this:
```
"Analyze these 5 competitors [Link1, Link2] and suggest 10 high-opportunity keywords for my [Category] app."
"Draft a 30-char Subtitle and 80-char Short Description for [App Name]."
```

---

## 🛠️ Part 2: Build & Export (iOS/macOS)

### 2.1 iOS Build (Clean & Archive)
Use `xcodebuild` for reproducible builds.

```bash
# 1. Clean & Archive
xcodebuild clean archive \
  -workspace "Runner.xcworkspace" \
  -scheme "Runner" \
  -configuration Release \
  -archivePath "./build/ios/Runner.xcarchive" \
  -destination "generic/platform=iOS"

# 2. Export IPA
xcodebuild -exportArchive \
  -archivePath "./build/ios/Runner.xcarchive" \
  -exportPath "./build/ios/export" \
  -exportOptionsPlist "ios/ExportOptions.plist" \
  -allowProvisioningUpdates
```

**ExportOptions.plist:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string> <!-- or 'ad-hoc', 'enterprise', 'development' -->
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/> <!-- Bitcode is deprecated in Xcode 14+ -->
</dict>
</plist>
```

### 2.2 macOS Build (PKG)
flutter build macos generates an .app, you need a .pkg for Store.

```bash
# 1. Build
flutter build macos --release

# 2. Sign & Package (using productbuild usually, or simple archive)
# The safest way for direct store upload via CLI:
xcrun altool --upload-app \
  -f "build/macos/Build/Products/Release/MyApp.pkg" \
  --type macos \
  --apiKey "AUTH_KEY_ID" \
  --apiIssuer "ISSUER_ID"
```

---

## 🚀 Part 3: Store Submission (CLI)

### 3.1 Upload to TestFlight
Requires `fastlane` or `xcrun altool`.

**Using Fastlane (Recommended):**
```bash
fastlane pilot upload --ipa "./build/ios/export/Runner.ipa" --skip_waiting_for_build_processing
```

**Using xcrun altool:**
```bash
xcrun altool --upload-app \
  -f "./build/ios/export/Runner.ipa" \
  -t ios \
  --apiKey "AUTH_KEY_ID" \
  --apiIssuer "ISSUER_ID"
```

### 3.2 Submission Workflow
1.  **Upload Build:** Send `.ipa` or `.aab` to store console.
2.  **Processing:** Wait for "Processing" -> "Ready to Submit".
3.  **Compliance:**
    *   **Encryption:** Set `ITSAppUsesNonExemptEncryption` to `false` in Info.plist if exempt.
    *   **Rights:** Confirm you own the content.
4.  **Release Notes:** "Fixed bug X, Added feature Y."
5.  **Submit for Review:** Click the button (or automate via API).

---

## 📊 Part 4: ASO Strategy Execution

### Visual Assets Checklist
- [ ] **Icon:** Simple, no text, distinct shape. Correct size (1024x1024).
- [ ] **Screenshots:**
    *   Show, don't just tell.
    *   Use captions on top of device frames.
    *   First 2 screenshots determine 80% of downloads.
    *   Order: Core Value -> Secondary Feature -> Social Proof.
- [ ] **Preview Video:** Short (15-30s), silent-friendly, focus on UI flow.

### Post-Launch Optimization
- **Day 1-7:** Monitor crash rate (Crashlytics) & "Not Installing" errors.
- **Day 7-14:** Check Impression-to-Install conversion rate.
    *   Below 2%? → Change Icon/Screenshots.
    *   High Impressions, Low Installs? → Metadata issue.
    *   Low Impressions? → Keyword issue.
- **Reviews:** Reply to EVERY review within 24h. It boosts ranking.

---

## 🤖 Integration with Agents
- **Metadata:** Ask `aso-specialist` to generate descriptions.
- **Builds:** Ask `mobile-release-specialist` to run the build commands.
- **CI/CD:** Ask `devops-engineer` to put these scripts into GitHub Actions.
