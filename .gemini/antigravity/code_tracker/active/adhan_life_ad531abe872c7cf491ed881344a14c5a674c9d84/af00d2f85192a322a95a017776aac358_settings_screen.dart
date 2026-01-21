��import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:adhan_life/core/constants/api_constants.dart';
import '../../../../app/providers.dart';

/// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navSettings),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, AppLocalizations.of(context)!.appearance),
          _buildThemeTile(context, ref, themeMode),
          _buildLanguageTile(context, ref, currentLocale),
          _buildMaterialYouTile(context, ref),

          const Divider(height: AppTokens.spacing32),

          // Location & Prayer Settings
          _buildSectionHeader(context, AppLocalizations.of(context)!.locationAndPrayer),
          _buildLocationTile(context),
          _buildCalculationMethodTile(context),
          // _buildAsrMethodTile(context), // Removed - no mezhep ayrımı
          _buildHighLatitudeTile(context),

          const Divider(height: AppTokens.spacing32),

          // Quran Settings
          _buildSectionHeader(context, 'Quran'),
          _buildQuranSettingsTile(context),

          const Divider(height: AppTokens.spacing32),

          // Notifications
          _buildSectionHeader(context, AppLocalizations.of(context)!.notifications),
          _buildNotificationSettingsTile(context),

          const Divider(height: AppTokens.spacing32),

          // About
          _buildSectionHeader(context, AppLocalizations.of(context)!.about),
          _buildAboutTile(context, AppLocalizations.of(context)!.version, '1.0.0'),
          // Privacy Policy & Terms - To be implemented with web view
          // _buildAboutTile(context, AppLocalizations.of(context)!.privacyPolicy, null, onTap: () {}),
          // _buildAboutTile(context, AppLocalizations.of(context)!.termsOfService, null, onTap: () {}),
          _buildAboutTile(context, AppLocalizations.of(context)!.rateApp, null, onTap: () => _launchRateApp()),

          const SizedBox(height: AppTokens.spacing32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spacing16,
        AppTokens.spacing16,
        AppTokens.spacing16,
        AppTokens.spacing8,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Text(_getThemeModeName(context, themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showThemeDialog(context, ref, themeMode);
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
  ) {
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(_getLanguageName(context, locale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.go('/settings/language');
      },
    );
  }

  Widget _buildMaterialYouTile(BuildContext context, WidgetRef ref) {
    final materialYouEnabled = ref.watch(materialYouEnabledProvider);

    return SwitchListTile(
      secondary: const Icon(Icons.palette_outlined),
      title: const Text('Material You'),
      subtitle: const Text('Use system colors (Android 12+)'),
      value: materialYouEnabled,
      onChanged: (value) {
        ref.read(materialYouEnabledProvider.notifier).set(value);
      },
    );
  }

  Widget _buildCalculationMethodTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final method = ref.watch(calculationMethodProvider);
        return ListTile(
          leading: const Icon(Icons.calculate_outlined),
          title: Text(AppLocalizations.of(context)!.calculationMethod),
          subtitle: Text(_getCalculationMethodName(method)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showCalculationMethodDialog(context, ref, method);
          },
        );
      },
    );
  }

  Widget _buildAsrMethodTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final method = ref.watch(asrMethodProvider);
        return ListTile(
          leading: const Icon(Icons.access_time_outlined),
          title: Text(AppLocalizations.of(context)!.asrCalculation),
          subtitle: Text(_getAsrMethodName(method)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showAsrMethodDialog(context, ref, method);
          },
        );
      },
    );
  }

  Widget _buildHighLatitudeTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final rule = ref.watch(highLatitudeRuleProvider);
        return ListTile(
          leading: const Icon(Icons.public_outlined),
          title: Text(AppLocalizations.of(context)!.highLatitudeRule),
          subtitle: Text(_getHighLatitudeRuleName(rule)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showHighLatitudeDialog(context, ref, rule);
          },
        );
      },
    );
  }

  Widget _buildLocationTile(BuildContext context) {
    // We need to listen to storage to show current selection
    // But since this is a stateless method (or we need to access ref inside build to watch).
    // The build method already has 'ref', but this helper doesn't.
    // Changing signature would be best, but for quick fix we can assume parent rebuilds?
    // Actually parent `build` calls `ref.watch(localeProvider)` etc but not storage.
    // We should pass the current location string to this method or ref.
    
    return Consumer(
      builder: (context, ref, child) {
        final storage = ref.watch(storageServiceProvider);
        final isManual = storage.getIsManualLocation();
        final manualCity = storage.getManualCity();
        
        String subtitle = AppLocalizations.of(context)!.valCurrentLocation;
        if (isManual && manualCity != null) {
          subtitle = manualCity;
        }

        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(AppLocalizations.of(context)!.location),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // New route for location selection
            context.push('/settings/location'); 
          },
        );
      }
    );
  }

  Widget _buildQuranSettingsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: const Text('Quran Settings'),
      subtitle: const Text('Configure reading experience'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/settings/quran');
      },
    );
  }

  Widget _buildNotificationSettingsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: Text(AppLocalizations.of(context)!.prayerNotifications),
      subtitle: Text(AppLocalizations.of(context)!.subtitleNotifications),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/settings/notifications');
      },
    );
  }

  Widget _buildAboutTile(
    BuildContext context,
    String title,
    String? value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: value != null
          ? Text(
              value,
              style: TextStyle(color: AppColors.textSecondary),
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    // Requires context to localize
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  String _getLanguageName(BuildContext context, Locale? locale) {
    // Requires context just to be safe if we want to localize "System"
    if (locale == null) return AppLocalizations.of(context)!.langSystem;
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'nl':
        return 'Nederlands';
      case 'sv':
        return 'Svenska';
      case 'no':
        return 'Norsk';
      case 'da':
        return 'Dansk';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      case 'pl':
        return 'Polski';
      case 'fi':
        return 'Suomi';
      case 'ru':
        return 'Русский';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeName(context, mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
  ) {
    final languages = [
      (null, 'System'),
      (const Locale('en'), 'English'),
      (const Locale('de'), 'Deutsch'),
      (const Locale('fr'), 'Français'),
      (const Locale('es'), 'Español'),
      (const Locale('nl'), 'Nederlands'),
      (const Locale('sv'), 'Svenska'),
      (const Locale('no'), 'Norsk'),
      (const Locale('da'), 'Dansk'),
      (const Locale('pt'), 'Português'),
      (const Locale('it'), 'Italiano'),
      (const Locale('pl'), 'Polski'),
      (const Locale('fi'), 'Suomi'),
      (const Locale('ru'), 'Русский'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final (locale, name) = languages[index];
              return RadioListTile<Locale?>(
                title: Text(name),
                value: locale,
                groupValue: currentLocale,
                onChanged: (value) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _getCalculationMethodName(String method) {
    switch (method) {
      case 'muslim_world_league': return 'Muslim World League';
      case 'egyptian': return 'Egyptian General Authority';
      case 'karachi': return 'University of Karachi';
      case 'umm_al_qura': return 'Umm al-Qura';
      case 'dubai': return 'Dubai';
      case 'moon_sighting': return 'Moon Sighting Committee';
      case 'north_america': return 'Islamic Society of North America';
      case 'kuwait': return 'Kuwait';
      case 'qatar': return 'Qatar';
      case 'singapore': return 'Singapore';
      default: return 'Muslim World League';
    }
  }

  String _getAsrMethodName(String method) {
    switch (method) {
      case 'shafi': return 'Shafi (Standard)';
      case 'hanafi': return 'Hanafi';
      default: return 'Shafi';
    }
  }

  String _getHighLatitudeRuleName(String rule) {
    switch (rule) {
      case 'middle_of_night': return 'Middle of Night';
      case 'seventh_of_night': return 'Seventh of Night';
      case 'twilight_angle': return 'Twilight Angle';
      default: return 'Middle of Night';
    }
  }

  void _showCalculationMethodDialog(
    BuildContext context,
    WidgetRef ref,
    String currentMethod,
  ) {
    final methods = [
      ('muslim_world_league', 'Muslim World League'),
      ('egyptian', 'Egyptian General Authority'),
      ('karachi', 'University of Karachi'),
      ('umm_al_qura', 'Umm al-Qura'),
      ('dubai', 'Dubai'),
      ('moon_sighting', 'Moon Sighting Committee'),
      ('north_america', 'Islamic Society of North America'),
      ('kuwait', 'Kuwait'),
      ('qatar', 'Qatar'),
      ('singapore', 'Singapore'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.calculationMethod),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: methods.map((m) {
              return RadioListTile<String>(
                title: Text(m.$2),
                value: m.$1,
                groupValue: currentMethod,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(calculationMethodProvider.notifier).setMethod(value);
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAsrMethodDialog(
    BuildContext context,
    WidgetRef ref,
    String currentMethod,
  ) {
    final methods = [
      ('shafi', 'Shafi (Standard)', 'Shadow length = object length'),
      ('hanafi', 'Hanafi', 'Shadow length = 2x object length'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.asrCalculation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: methods.map((m) {
            return RadioListTile<String>(
              title: Text(m.$2),
              subtitle: Text(m.$3),
              value: m.$1,
              groupValue: currentMethod,
              onChanged: (value) {
                if (value != null) {
                  ref.read(asrMethodProvider.notifier).setMethod(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHighLatitudeDialog(
    BuildContext context,
    WidgetRef ref,
    String currentRule,
  ) {
    final rules = [
      ('middle_of_night', 'Middle of Night', 'Fajr & Isha based on middle of night'),
      ('seventh_of_night', 'Seventh of Night', 'Fajr & Isha based on 1/7th of night'),
      ('twilight_angle', 'Twilight Angle', 'Similar to standard calculation'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.highLatitudeRule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rules.map((r) {
            return RadioListTile<String>(
              title: Text(r.$2),
              subtitle: Text(r.$3),
              value: r.$1,
              groupValue: currentRule,
              onChanged: (value) {
                if (value != null) {
                  ref.read(highLatitudeRuleProvider.notifier).setRule(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Launch app store rating page
  Future<void> _launchRateApp() async {
    // TODO: Replace with your actual app store URLs
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.adhanlife.app';
    const appStoreUrl = 'https://apps.apple.com/app/adhanlife/id123456789';
    
    // Detect platform and launch appropriate URL
    final uri = Uri.parse(playStoreUrl); // Use appStoreUrl for iOS
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
� ��*cascade08
�� ��*cascade08��� "(ad531abe872c7cf491ed881344a14c5a674c9d842wfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/settings_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life