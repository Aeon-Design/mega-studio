---
name: "Flutter HIG"
version: "1.0.0"
description: |
  Platform-aware UI design guidelines for Flutter.
  Apple HIG + Material Design best practices.
  Tetikleyiciler: "design", "ui", "cupertino", "material", "platform-aware"
---

# Flutter HIG (Human Interface Guidelines)

## Amaç
Platform-native hissiyat veren UI tasarımı için rehber.

---

## Platform Detection

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isMobile => isIOS || isAndroid;
```

---

## Widget Seçimi Matrix

| Bileşen | iOS (Cupertino) | Android (Material) |
|---------|-----------------|-------------------|
| Button | CupertinoButton | ElevatedButton |
| Dialog | CupertinoAlertDialog | AlertDialog |
| Switch | CupertinoSwitch | Switch |
| Picker | CupertinoPicker | DropdownButton |
| Navigation | CupertinoTabBar | NavigationBar |
| App Bar | CupertinoNavigationBar | AppBar |
| Activity | CupertinoActivityIndicator | CircularProgressIndicator |
| Text Field | CupertinoTextField | TextField |

---

## Platform-Aware Widget Pattern

```dart
Widget buildAdaptiveButton({
  required String text,
  required VoidCallback onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: Text(text),
    );
  }
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(text),
  );
}
```

---

## Apple HIG Prensipleri (Flutter'da)

### 1. Clarity (Netlik)
- Büyük, okunabilir fontlar (min 17pt body)
- Yeterli kontrast (4.5:1 minimum)
- Negatif alan kullan

### 2. Deference (Saygı)
- İçerik öncelikli, UI ikincil
- Şeffaflık ve blur efektleri
- Minimal chrome

### 3. Depth (Derinlik)
- Katmanlı animasyonlar
- Gerçekçi gölgeler
- Parallax efektleri

---

## Material Design 3 Prensipleri

### 1. Dynamic Color
```dart
ColorScheme.fromSeed(seedColor: Colors.blue)
```

### 2. Elevation & Shadows
```dart
Material(
  elevation: 2,
  surfaceTintColor: Theme.of(context).colorScheme.primary,
  child: content,
)
```

### 3. Motion
- Easing: Curves.easeOutCubic
- Duration: 300ms standard, 200ms quick

---

## Typography Scale

### iOS (SF Pro)
```dart
CupertinoThemeData(
  textTheme: CupertinoTextThemeData(
    primaryColor: CupertinoColors.label,
    textStyle: TextStyle(fontSize: 17),
  ),
)
```

### Material (Roboto/System)
```dart
TextTheme(
  displayLarge: TextStyle(fontSize: 57),
  headlineMedium: TextStyle(fontSize: 28),
  bodyLarge: TextStyle(fontSize: 16),
  labelMedium: TextStyle(fontSize: 12),
)
```

---

## Safe Areas

```dart
SafeArea(
  child: Scaffold(
    body: content,
  ),
)

// veya padding ile
MediaQuery.of(context).padding.top  // Status bar
MediaQuery.of(context).padding.bottom  // Home indicator
```

---

## Haptic Feedback

```dart
import 'package:flutter/services.dart';

// Light impact
HapticFeedback.lightImpact();

// Medium impact
HapticFeedback.mediumImpact();

// Heavy impact
HapticFeedback.heavyImpact();

// Selection
HapticFeedback.selectionClick();
```

---

## Responsive Breakpoints

```dart
enum ScreenSize { compact, medium, expanded }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return ScreenSize.compact;
  if (width < 840) return ScreenSize.medium;
  return ScreenSize.expanded;
}
```

---

## Checklist

- [ ] Platform detection implemented
- [ ] Adaptive widgets used where appropriate
- [ ] Typography follows platform guidelines
- [ ] Safe areas respected
- [ ] Haptic feedback on key interactions
- [ ] Responsive layout for all screen sizes
