---
name: "CI/CD"
version: "1.0.0"
description: "GitHub Actions, Codemagic, Fastlane for Flutter CI/CD pipelines"
primary_users:
  - devops-engineer
  - mobile-release-specialist
dependencies: []
tags:
  - devops
  - automation
---

# 🔄 CI/CD

## Quick Start

Flutter için otomatik build, test ve deployment. GitHub Actions + Fastlane
kombinasyonu veya Codemagic managed solution.

---

## 🐙 GitHub Actions

### 1. Basic Flutter CI

```yaml
# .github/workflows/flutter_ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs
      
      - name: Analyze
        run: flutter analyze --fatal-infos
      
      - name: Format check
        run: dart format --set-exit-if-changed .
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  build_android:
    needs: analyze_and_test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build_ios:
    needs: analyze_and_test
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          cache: true
      
      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign
```

### 2. Release Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release_android:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
      
      - name: Build App Bundle
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=./debug-info
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.example.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed

  release_ios:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          cache: true
      
      - name: Install certificates
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          p12-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
      
      - name: Install provisioning profile
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "${{ secrets.IOS_PROVISIONING_BASE64 }}" | base64 --decode > profile.mobileprovision
          cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
      
      - name: Build IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
      
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}
```

---

## 🚀 Fastlane

### 1. Setup

```bash
# Install fastlane
gem install fastlane

# Initialize (in ios/ or android/ folder)
cd ios && fastlane init
cd android && fastlane init
```

### 2. iOS Fastfile

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    
    match(type: "appstore", readonly: true)
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "./build"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    setup_ci if ENV['CI']
    
    match(type: "appstore", readonly: true)
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    
    upload_to_app_store(
      skip_screenshots: true,
      skip_metadata: true,
      force: true
    )
  end
end
```

### 3. Android Fastfile

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Build and upload to Play Store Internal"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )
    
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab"
    )
  end
  
  desc "Promote to Production"
  lane :production do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production"
    )
  end
end
```

---

## ☁️ Codemagic

### codemagic.yaml

```yaml
# codemagic.yaml
workflows:
  flutter-workflow:
    name: Flutter CI/CD
    max_build_duration: 60
    instance_type: mac_mini_m1
    
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      groups:
        - app_store_credentials
        - google_play_credentials
      vars:
        BUNDLE_ID: "com.example.app"
        
    triggering:
      events:
        - push
        - pull_request
      branch_patterns:
        - pattern: 'main'
          include: true
        - pattern: 'develop'
          include: true
    
    scripts:
      - name: Get dependencies
        script: flutter pub get
        
      - name: Run code generation
        script: dart run build_runner build --delete-conflicting-outputs
        
      - name: Run tests
        script: flutter test --coverage
        
      - name: Build Android
        script: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=./debug-info
            
      - name: Build iOS
        script: |
          flutter build ipa --release \
            --export-options-plist=ios/ExportOptions.plist
    
    artifacts:
      - build/**/outputs/**/*.aab
      - build/**/outputs/**/*.apk
      - build/ios/ipa/*.ipa
      
    publishing:
      email:
        recipients:
          - dev@example.com
        notify:
          success: true
          failure: true
          
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_ID
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
```

---

## 📋 Secrets Management

### Required Secrets

| Secret | Platform | Description |
|--------|----------|-------------|
| `KEYSTORE_BASE64` | Android | Base64 encoded keystore |
| `KEYSTORE_PASSWORD` | Android | Keystore password |
| `KEY_ALIAS` | Android | Signing key alias |
| `KEY_PASSWORD` | Android | Signing key password |
| `PLAY_SERVICE_ACCOUNT` | Android | Google Play API JSON |
| `IOS_CERTIFICATE_BASE64` | iOS | P12 certificate |
| `IOS_CERTIFICATE_PASSWORD` | iOS | Certificate password |
| `IOS_PROVISIONING_BASE64` | iOS | Provisioning profile |
| `APP_STORE_CONNECT_*` | iOS | API credentials |

### Encoding Secrets

```bash
# Encode file to base64
base64 -i keystore.jks -o keystore.base64.txt

# Or on Linux
base64 keystore.jks > keystore.base64.txt
```

---

## ✅ CI/CD Checklist

- [ ] Branch protection enabled on main
- [ ] All secrets stored securely
- [ ] Tests run on every PR
- [ ] Builds cached for speed
- [ ] Artifacts uploaded
- [ ] Notifications configured
- [ ] Version auto-increment

---

## 🔗 Related Resources

- [templates/github_actions.yaml](templates/github_actions.yaml)
- [templates/codemagic.yaml](templates/codemagic.yaml)
- Grimoire: `advanced_devops.md`
