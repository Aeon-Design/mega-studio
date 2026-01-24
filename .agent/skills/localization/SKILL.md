---
name: "Localization"
version: "1.0.0"
description: "Flutter i18n, ARB files, RTL support, and pluralization"
primary_users:
  - localizer
  - mobile-developer
dependencies:
  - flutter-foundations
tags:
  - i18n
  - localization
---

# 🌍 Localization

## Quick Start

Flutter'ın built-in intl paketi ile çoklu dil desteği.
ARB dosyaları, pluralization, ve RTL layout.

---

## 📚 Setup

### 1. pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1

flutter:
  generate: true  # l10n code generation
```

### 2. l10n.yaml

```yaml
# l10n.yaml (project root)
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

### 3. ARB Files

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  
  "appTitle": "TaskMaster",
  "@appTitle": {
    "description": "The app title"
  },
  
  "hello": "Hello, {name}!",
  "@hello": {
    "description": "Greeting message",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  },
  
  "taskCount": "{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}",
  "@taskCount": {
    "description": "Task count with pluralization",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },
  
  "dueDate": "Due on {date}",
  "@dueDate": {
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMd"
      }
    }
  },
  
  "welcomeGender": "{gender, select, male{Welcome, Mr. {name}} female{Welcome, Ms. {name}} other{Welcome, {name}}}",
  "@welcomeGender": {
    "placeholders": {
      "gender": {"type": "String"},
      "name": {"type": "String"}
    }
  }
}
```

```json
// lib/l10n/app_tr.arb
{
  "@@locale": "tr",
  
  "appTitle": "GörevUstası",
  
  "hello": "Merhaba, {name}!",
  
  "taskCount": "{count, plural, =0{Görev yok} =1{1 görev} other{{count} görev}}",
  
  "dueDate": "Bitiş: {date}",
  
  "welcomeGender": "{gender, select, male{Hoş geldiniz, Bay {name}} female{Hoş geldiniz, Bayan {name}} other{Hoş geldiniz, {name}}}"
}
```

---

## 🔧 Integration

### 1. MaterialApp Configuration

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Supported locales
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('ar'), // RTL
      ],
      
      // Optional: locale resolution
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      
      home: const HomePage(),
    );
  }
}
```

### 2. Using Translations

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Column(
        children: [
          // Simple string
          Text(l10n.appTitle),
          
          // With placeholder
          Text(l10n.hello('Ali')),
          
          // Pluralization
          Text(l10n.taskCount(5)),
          Text(l10n.taskCount(1)),
          Text(l10n.taskCount(0)),
          
          // Date formatting
          Text(l10n.dueDate(DateTime.now())),
          
          // Gender select
          Text(l10n.welcomeGender('male', 'Ahmet')),
        ],
      ),
    );
  }
}

// Extension for easier access
extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Usage: context.l10n.appTitle
```

---

## 🔄 Dynamic Locale Change

```dart
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}

// In MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            locale: localeProvider.locale,
            // ... other config
          );
        },
      ),
    );
  }
}

// Language selector
class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (locale) {
        context.read<LocaleProvider>().setLocale(locale);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: Locale('en'), child: Text('English')),
        const PopupMenuItem(value: Locale('tr'), child: Text('Türkçe')),
        const PopupMenuItem(value: Locale('ar'), child: Text('العربية')),
      ],
    );
  }
}
```

---

## ↔️ RTL Support

### 1. Automatic RTL

```dart
// Flutter otomatik olarak ar, he, fa için RTL yapar
MaterialApp(
  supportedLocales: [
    Locale('en'),
    Locale('ar'), // Otomatik RTL
  ],
)
```

### 2. Directional Widgets

```dart
// ❌ Hardcoded direction
Padding(
  padding: EdgeInsets.only(left: 16), // RTL'de yanlış
)

// ✅ Directional
Padding(
  padding: EdgeInsetsDirectional.only(start: 16), // RTL'de sağdan
)

// ✅ Symmetric (her iki yönde aynı)
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
)
```

### 3. Directional Properties

```dart
// ❌
Row(
  children: [
    Icon(Icons.arrow_back), // RTL'de yanlış yön
    Text('Back'),
  ],
)

// ✅
Row(
  children: [
    Icon(Icons.arrow_back_ios), // Otomatik flip
    Text(context.l10n.back),
  ],
)

// ✅ Manuel kontrol
Directionality.of(context) == TextDirection.rtl
    ? Icons.arrow_forward
    : Icons.arrow_back
```

### 4. RTL Testing

```dart
testWidgets('RTL layout test', (tester) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        home: MyWidget(),
      ),
    ),
  );
  
  // RTL assertions
  final widget = tester.widget<Padding>(find.byType(Padding));
  expect(widget.padding, EdgeInsetsDirectional.only(start: 16));
});
```

---

## 📝 Best Practices

### 1. String Externalization

```dart
// ❌ Hardcoded
Text('Welcome to the app')

// ✅ Externalized
Text(context.l10n.welcome)
```

### 2. Avoid String Concatenation

```dart
// ❌ Concatenation (word order varies by language)
Text('Hello ' + name + '!')

// ✅ Placeholder
Text(context.l10n.hello(name))
```

### 3. Handle Pluralization

```dart
// ❌ Simple conditional
Text(count == 1 ? '1 item' : '$count items')

// ✅ Proper pluralization (handles 0, 1, few, many, other)
Text(context.l10n.itemCount(count))
```

---

## ✅ Localization Checklist

- [ ] Tüm UI string'ler externalize edildi mi?
- [ ] Pluralization doğru mu?
- [ ] Tarih/saat formatları locale-aware mı?
- [ ] Para birimi formatları doğru mu?
- [ ] RTL layout test edildi mi?
- [ ] Tüm hedef diller için ARB var mı?
- [ ] Screenshots locale bazlı mı?

---

## 🔗 Related Resources

- [templates/arb_template.arb](templates/arb_template.arb)
- [checklists/rtl_support.md](checklists/rtl_support.md)
