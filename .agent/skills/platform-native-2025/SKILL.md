---
name: platform-native-2025
description: Expertise in iOS 18 (App Intents, Widgets) and Android 15 (Edge-to-Edge, 16KB Page Size) features.
---

# 📱 Platform Native 2025

## 🍎 iOS 18 Specifics

### App Intents (Apple Intelligence)
Integrate with Siri and Shortcuts using App Intents.
**Requirement:** Create a Swift bridge to expose app actions.
```swift
import AppIntents

struct OrderCoffee: AppIntent {
    static var title: LocalizedStringResource = "Order Coffee"
    func perform() async throws -> some IntentResult {
        // Call Flutter engine
        return .result()
    }
}
```

### Interactive Widgets
Homescreen widgets must be interactive.
- Use SwiftUI for the widget UI.
- Share data via `UserDefaults` (App Groups) or File System.

## 🤖 Android 15 Specifics

### Edge-to-Edge (Mandatory)
Android 15 enforces Edge-to-Edge.
- Flutter 3.27+ handles this automatically.
- **Check:** Ensure `Scaffold` body doesn't get hidden behind status/nav bars. Use `SafeArea` strictly where needed.

### 16KB Page Size
**Critical:** Native libraries (NDK) must be compatible with 16KB pages.
- **Action:** audit all third-party native plugins (`.so` files). If a plugin is old, it WILL crash on Pixel 9 / Android 15.

### Predictive Back
Ensure `PopScope` (Android 14+) is used correctly to support "Predictive Back" animations.
