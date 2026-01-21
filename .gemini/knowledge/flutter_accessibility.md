# ♿ Flutter Accessibility Grimoire

> **Owner:** Head of UX / QA Lead
> **Purpose:** Building apps usable by everyone, including screen reader users.

---

## 🌳 The Semantics Tree

Flutter builds a **Semantics Tree** parallel to the Widget Tree.
This tree is read by:
*   **TalkBack** (Android)
*   **VoiceOver** (iOS)
*   **Screen Readers** (Desktop)

---

## 🏷️ Key Semantic Properties

| Property | Purpose |
|----------|---------|
| `label` | What the element is ("Submit Button") |
| `hint` | How to use it ("Double tap to submit") |
| `value` | Current state ("50%") |
| `button`, `link`, `header` | Roles |
| `enabled`, `checked`, `selected` | States |

---

## 🛠️ Implementing Semantics

### Option 1: Built-in Widget Properties
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'), // Automatically read as "Submit, Button"
)
```

### Option 2: `Semantics` Widget
```dart
Semantics(
  label: 'Profile Picture',
  hint: 'Double tap to view full size',
  image: true,
  child: CircleAvatar(backgroundImage: ...),
)
```

### Option 3: `ExcludeSemantics`
```dart
ExcludeSemantics(
  child: DecorativeImage(), // Not read by screen reader
)
```

### Option 4: `MergeSemantics`
```dart
MergeSemantics(
  child: Row(
    children: [Icon(Icons.star), Text('5.0')], // Read as "5.0, star"
  ),
)
```

---

## 🎨 Visual Accessibility

### 1. Color Contrast
*   **WCAG AA:** 4.5:1 for normal text, 3:1 for large text.
*   **Tool:** Use Accessibility Insights or contrast-ratio.com.

### 2. Touch Target Size
*   **Minimum:** 48x48 dp (Material guideline).
*   **Fix:** Use `IconButton` padding or wrap in `InkWell` with `Padding`.

### 3. Text Scaling
```dart
Text(
  'Hello',
  textScaler: MediaQuery.textScalerOf(context), // Respect system setting
)
```

**Rule:** Never hardcode font sizes that ignore `textScaleFactor`.

---

## 🧪 Testing Accessibility

### 1. Enable TalkBack/VoiceOver and Navigate
*   Manually test every screen.

### 2. Semantic Debugger
```dart
MaterialApp(
  showSemanticsDebugger: true, // Shows semantic labels
)
```

### 3. Automated Checks
```dart
testWidgets('button is accessible', (tester) async {
  await tester.pumpWidget(MyApp());
  
  final semantics = tester.getSemantics(find.byType(ElevatedButton));
  expect(semantics.label, isNotEmpty);
});
```

---

## ⚠️ Common Mistakes

| ❌ Bad | ✅ Good |
|--------|---------|
| Icon-only buttons with no label | Add `tooltip` or `Semantics(label:)` |
| Images without description | Add `semanticLabel` to `Image` |
| Decorative icons read aloud | Wrap in `ExcludeSemantics` |
| Low contrast text | Check WCAG guidelines |
