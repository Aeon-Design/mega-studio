# 🍎 iOS Advanced Grimoire

> **Domain:** WidgetKit, Live Activities, StoreKit, App Intents, watchOS
> **Primary Agent:** iOS Platform Specialist (`/ios`)
> **Secondary:** Mobile Developer (`/mobile`)

---

## 📱 WidgetKit Complete Guide

### 1. Create Widget Target

1. In Xcode: File → New → Target → Widget Extension
2. Name it (e.g., `AppWidgets`)
3. Activate scheme when prompted

### 2. Widget Structure

```swift
import WidgetKit
import SwiftUI

// Data model
struct WidgetData: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let progress: Double
}

// Data provider
struct WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetData {
        WidgetData(date: Date(), title: "Loading...", subtitle: "", progress: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetData) -> ()) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetData>) -> ()) {
        // Read from UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.widgets")
        let title = sharedDefaults?.string(forKey: "widgetTitle") ?? "No Data"
        let subtitle = sharedDefaults?.string(forKey: "widgetSubtitle") ?? ""
        let progress = sharedDefaults?.double(forKey: "widgetProgress") ?? 0
        
        let entry = WidgetData(date: Date(), title: title, subtitle: subtitle, progress: progress)
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// Widget view
struct WidgetView: View {
    let entry: WidgetData
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Widget definition
@main
struct AppWidgets: Widget {
    let kind: String = "AppWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("App Widget")
        .description("Shows your current status")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
```

### 3. Flutter ↔ Widget Communication

```yaml
# pubspec.yaml
dependencies:
  home_widget: ^0.5.0
```

```dart
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.yourapp.widgets';
  static const String iOSWidgetName = 'AppWidget';
  
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }
  
  static Future<void> updateWidget({
    required String title,
    required String subtitle,
    required double progress,
  }) async {
    await HomeWidget.saveWidgetData('widgetTitle', title);
    await HomeWidget.saveWidgetData('widgetSubtitle', subtitle);
    await HomeWidget.saveWidgetData('widgetProgress', progress);
    
    await HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: 'AppWidgetProvider',
    );
  }
}
```

---

## 🏝️ Live Activities & Dynamic Island

### 1. Define Activity Attributes

```swift
import ActivityKit

struct OrderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var estimatedTime: String
        var progressPercent: Double
    }
    
    var orderNumber: String
    var storeName: String
}
```

### 2. Live Activity Views

```swift
struct OrderActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            // Lock Screen view
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.storeName)
                        .font(.headline)
                    Text(context.state.status)
                        .font(.subheadline)
                }
                Spacer()
                Text(context.state.estimatedTime)
                    .font(.title2)
                    .bold()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bag.fill")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedTime)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progressPercent)
                }
            } compactLeading: {
                Image(systemName: "bag.fill")
            } compactTrailing: {
                Text(context.state.estimatedTime)
            } minimal: {
                Image(systemName: "bag.fill")
            }
        }
    }
}
```

### 3. Start/Update/End Activity

```swift
class LiveActivityManager {
    private var currentActivity: Activity<OrderActivityAttributes>?
    
    func startActivity(orderNumber: String, storeName: String) async throws {
        let attributes = OrderActivityAttributes(orderNumber: orderNumber, storeName: storeName)
        let state = OrderActivityAttributes.ContentState(
            status: "Preparing",
            estimatedTime: "15 min",
            progressPercent: 0.2
        )
        
        currentActivity = try Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: nil),
            pushType: nil
        )
    }
    
    func updateActivity(status: String, eta: String, progress: Double) async {
        let state = OrderActivityAttributes.ContentState(
            status: status,
            estimatedTime: eta,
            progressPercent: progress
        )
        await currentActivity?.update(ActivityContent(state: state, staleDate: nil))
    }
    
    func endActivity() async {
        let finalState = OrderActivityAttributes.ContentState(
            status: "Delivered!",
            estimatedTime: "Done",
            progressPercent: 1.0
        )
        await currentActivity?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
    }
}
```

---

## 🔊 App Intents (Siri & Shortcuts)

### 1. Define Intent

```swift
import AppIntents

struct StartFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Session"
    static var description = IntentDescription("Starts a focus timer for productivity")
    
    @Parameter(title: "Duration (minutes)", default: 25)
    var durationMinutes: Int
    
    @Parameter(title: "Category")
    var category: FocusCategory?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start \(\.$durationMinutes) minute focus session for \(\.$category)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Start timer logic here
        return .result(dialog: "Starting \(durationMinutes) minute focus session")
    }
}

enum FocusCategory: String, AppEnum {
    case work = "Work"
    case study = "Study"
    case creative = "Creative"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Focus Category")
    static var caseDisplayRepresentations: [FocusCategory: DisplayRepresentation] = [
        .work: "Work",
        .study: "Study",
        .creative: "Creative"
    ]
}
```

### 2. Register in App

```swift
// AppShortcuts.swift
import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: [
                "Start focus in \(.applicationName)",
                "Begin focus session with \(.applicationName)"
            ],
            shortTitle: "Start Focus",
            systemImageName: "timer"
        )
    }
}
```

---

## 📊 StoreKit 2 (Native iOS IAP)

```swift
import StoreKit

class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: ["premium_monthly", "premium_yearly"])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            purchasedProductIDs.insert(product.id)
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
```

---

## ✅ iOS Deployment Checklist

- [ ] App Icons (all sizes including 1024x1024)
- [ ] Launch Screen configured
- [ ] Info.plist permissions justified
- [ ] Capabilities enabled in Xcode
- [ ] App Tracking Transparency implemented (if using ads)
- [ ] Widget configured with App Groups
- [ ] TestFlight build uploaded
- [ ] App Store screenshots (6.7", 6.5", 5.5", iPad)
- [ ] Privacy labels completed
- [ ] Age rating questionnaire done
