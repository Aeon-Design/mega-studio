�import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _languageNames = {
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'no': 'Norsk',
    'da': 'Dansk',
    'pt': 'Português',
    'it': 'Italiano',
    'pl': 'Polski',
    'fi': 'Suomi',
    'ru': 'Русский',
    'tr': 'Türkçe',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final selectedCode = currentLocale?.languageCode ?? 'en'; // Default to English if null

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.spacing8),
        itemCount: supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = supportedLocales[index];
          final code = locale.languageCode;
          final name = _languageNames[code] ?? code;
          final isSelected = code == selectedCode;

          return RadioListTile<String>(
            value: code,
            groupValue: selectedCode,
            onChanged: (value) {
              if (value != null) {
                ref.read(localeProvider.notifier).setLocale(Locale(value));
              }
            },
            title: Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing16),
            controlAffinity: ListTileControlAffinity.leading,
          );
        },
      ),
    );
  }
}
�*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842wfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/language_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life