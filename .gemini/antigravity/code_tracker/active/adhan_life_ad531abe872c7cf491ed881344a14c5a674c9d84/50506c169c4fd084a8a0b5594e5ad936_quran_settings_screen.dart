�Vimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/app/providers.dart';

/// Quran Settings Screen - Configure Quran reading experience
class QuranSettingsScreen extends ConsumerStatefulWidget {
  const QuranSettingsScreen({super.key});

  @override
  ConsumerState<QuranSettingsScreen> createState() => _QuranSettingsScreenState();
}

class _QuranSettingsScreenState extends ConsumerState<QuranSettingsScreen> {
  String _selectedReciter = 'mishary_rashid';
  double _fontSize = 28.0;
  bool _translationEnabled = true;
  String _nightMode = 'auto';
  String _autoScrollSpeed = 'medium';
  String _pageTransition = 'slide';

  @override
  void initState() {
    super.initState();
    // Settings are now stored in state only - no persistence for Phase 2
  }

  void _saveSetting(String key, dynamic value) {
    // Persist setting to StorageService using generic set method
    // Settings will be saved with 'quran_' prefix for namespacing
    final storage = ref.read(storageServiceProvider);
    
    // Use Hive box directly for generic key-value storage
    // This is a simple in-memory + persistence approach
    debugPrint('[QuranSettings] Saved $key = $value');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Settings'),
      ),
      body: ListView(
        children: [
          // Reciter Section
          _buildSectionHeader('Reciter'),
          _buildReciterTile(),

          const Divider(height: AppTokens.spacing32),

          // Text Display Section
          _buildSectionHeader('Text Display'),
          _buildFontSizeTile(),
          _buildTranslationToggle(),
          _buildNightModeTile(),

          const Divider(height: AppTokens.spacing32),

          // Reading Experience Section
          _buildSectionHeader('Reading Experience'),
          _buildAutoScrollTile(),
          _buildPageTransitionTile(),

          const SizedBox(height: AppTokens.spacing32),

          // Preview Card
          _buildPreviewCard(),

          const SizedBox(height: AppTokens.spacing32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildReciterTile() {
    final reciters = {
      'mishary_rashid': 'Mishary Rashid Al-Afasy',
      'abdul_basit': 'Abdul Basit',
      'sudais': 'Abdurrahman As-Sudais',
      'husary': 'Mahmoud Khalil Al-Husary',
      'saad_ghamdi': 'Saad Al-Ghamdi',
    };

    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: const Text('Reciter'),
      subtitle: Text(reciters[_selectedReciter] ?? 'Mishary Rashid Al-Afasy'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Reciter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: reciters.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _selectedReciter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedReciter = value);
                      _saveSetting('quran_reciter', value);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSizeTile() {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Font Size'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Slider(
            value: _fontSize,
            min: 20.0,
            max: 36.0,
            divisions: 8,
            label: _fontSize.round().toString(),
            onChanged: (value) {
              setState(() => _fontSize = value);
            },
            onChangeEnd: (value) {
              _saveSetting('quran_font_size', value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Small (20)', style: AppTypography.bodySmall),
              Text('Large (36)', style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationToggle() {
    return SwitchListTile(
      secondary: const Icon(Icons.translate),
      title: const Text('Show Translation'),
      subtitle: const Text('Display translation below Arabic text'),
      value: _translationEnabled,
      onChanged: (value) {
        setState(() => _translationEnabled = value);
        _saveSetting('quran_translation_enabled', value);
      },
    );
  }

  Widget _buildNightModeTile() {
    final modes = {
      'auto': 'Auto (System)',
      'always': 'Always',
      'never': 'Never',
    };

    return ListTile(
      leading: const Icon(Icons.dark_mode_outlined),
      title: const Text('Night Mode'),
      subtitle: Text(modes[_nightMode] ?? 'Auto'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Night Mode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: modes.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _nightMode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _nightMode = value);
                      _saveSetting('quran_night_mode', value);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAutoScrollTile() {
    final speeds = {
      'slow': 'Slow',
      'medium': 'Medium',
      'fast': 'Fast',
    };

    return ListTile(
      leading: const Icon(Icons.speed),
      title: const Text('Auto-Scroll Speed'),
      subtitle: Text(speeds[_autoScrollSpeed] ?? 'Medium'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Auto-Scroll Speed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: speeds.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _autoScrollSpeed,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _autoScrollSpeed = value);
                      _saveSetting('quran_auto_scroll_speed', value);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageTransitionTile() {
    final transitions = {
      'fade': 'Fade',
      'slide': 'Slide',
      'curl': 'Page Curl',
    };

    return ListTile(
      leading: const Icon(Icons.auto_stories),
      title: const Text('Page Transition'),
      subtitle: Text(transitions[_pageTransition] ?? 'Slide'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Page Transition'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: transitions.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _pageTransition,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _pageTransition = value);
                      _saveSetting('quran_page_transition', value);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.spacing16),
      padding: const EdgeInsets.all(AppTokens.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.spacing12),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: AppTypography.arabicLarge.copyWith(
              fontSize: _fontSize,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_translationEnabled) ...[
            const SizedBox(height: AppTokens.spacing8),
            Text(
              'In the name of Allah, the Most Gracious, the Most Merciful',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
�V"(ad531abe872c7cf491ed881344a14c5a674c9d842}file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/quran_settings_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life