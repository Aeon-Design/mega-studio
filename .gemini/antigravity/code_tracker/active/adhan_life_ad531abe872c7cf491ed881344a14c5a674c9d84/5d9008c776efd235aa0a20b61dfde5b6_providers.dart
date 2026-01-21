ôimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../l10n/app_localizations.dart';

/// Theme mode notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

/// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Locale notifier
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    // Get stored locale synchronously
    final storageService = ref.watch(storageServiceProvider);
    final localeCode = storageService.getLocale();
    
    if (localeCode != null) {
      // Check if stored locale is actually supported
      final isSupported = AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == localeCode
      );
      if (isSupported) {
        return Locale(localeCode);
      }
    }
    
    // If no stored locale or unsupported, return English by default
    // to avoid falling back to the first alphabetical locale (e.g. Danish)
    return const Locale('en');
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final storageService = ref.read(storageServiceProvider);
    await storageService.setLocale(locale?.languageCode);
  }
}

/// Locale provider for language selection
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Supported locales
const supportedLocales = [
  Locale('en'), // English
  Locale('de'), // German
  Locale('fr'), // French
  Locale('es'), // Spanish
  Locale('nl'), // Dutch
  Locale('sv'), // Swedish
  Locale('no'), // Norwegian
  Locale('da'), // Danish
  Locale('pt'), // Portuguese
  Locale('it'), // Italian
  Locale('pl'), // Polish
  Locale('fi'), // Finnish
  Locale('ru'), // Russian
  Locale('tr'), // Turkish
];

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Material You notifier
class MaterialYouNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final materialYouEnabledProvider = NotifierProvider<MaterialYouNotifier, bool>(
  MaterialYouNotifier.new,
);

/// Calculation Method notifier
class CalculationMethodNotifier extends Notifier<String> {
  @override
  String build() => 'muslim_world_league';

  void setMethod(String method) => state = method;
}

final calculationMethodProvider = NotifierProvider<CalculationMethodNotifier, String>(
  CalculationMethodNotifier.new,
);

/// Asr Method notifier
class AsrMethodNotifier extends Notifier<String> {
  @override
  String build() => 'shafi';

  void setMethod(String method) => state = method;
}

final asrMethodProvider = NotifierProvider<AsrMethodNotifier, String>(
  AsrMethodNotifier.new,
);

/// High Latitude Rule notifier
class HighLatitudeRuleNotifier extends Notifier<String> {
  @override
  String build() => 'middle_of_night';

  void setRule(String rule) => state = rule;
}

final highLatitudeRuleProvider = NotifierProvider<HighLatitudeRuleNotifier, String>(
  HighLatitudeRuleNotifier.new,
);
ô*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842Nfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/app/providers.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life