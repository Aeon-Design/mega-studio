�Limport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/repositories/content_repository.dart';
import 'package:adhan_life/app/providers.dart';

/// Names of Allah (Esmaül Hüsna) Screen
class NamesScreen extends ConsumerWidget {
  const NamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namesAsync = ref.watch(namesProvider);
    final locale = ref.watch(localeProvider);
    final languageCode = locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              // Audio playback feedback (requires audio assets)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playing 99 Names recitation...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: namesAsync.when(
        data: (names) => GridView.builder(
          padding: const EdgeInsets.all(AppTokens.spacing16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTokens.spacing12,
            mainAxisSpacing: AppTokens.spacing12,
            childAspectRatio: 0.85,
          ),
          itemCount: names.length,
          itemBuilder: (context, index) {
            final name = names[index];
            return _NameCard(
              number: name.id,
              arabic: name.arabic,
              transliteration: name.transliteration,
              meaning: name.getMeaning(languageCode),
              onTap: () {
                _showNameDetails(context, name, languageCode);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showNameDetails(
    BuildContext context,
    AllahName name,
    String languageCode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.bottomSheetRadius),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTokens.spacing24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppTokens.borderRadiusFull,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing24),

                // Number badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${name.id}',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.spacing24),

                // Arabic
                Text(
                  name.arabic,
                  style: AppTypography.arabicDisplay.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing16),

                // Transliteration
                Text(
                  name.transliteration,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing8),

                // Meaning
                Text(
                  name.getMeaning(languageCode),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing12),

                // Description (Optional)
                if (name.description != null && name.description!.isNotEmpty)
                  Text(
                    name.description!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                const SizedBox(height: AppTokens.spacing24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing ${name.transliteration}...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Listen'),
                    ),
                    const SizedBox(width: AppTokens.spacing12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final text = '${name.arabic}\n'
                            '${name.transliteration}\n'
                            '${name.getMeaning(languageCode)}\n\n'
                            '— Name #${name.id} of Allah\n'
                            '— Shared via AdhanLife';
                        Share.share(text, subject: name.transliteration);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
  final VoidCallback onTap;

  const _NameCard({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.borderRadiusMedium,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.spacing8),

              // Arabic
              Text(
                arabic,
                style: AppTypography.arabicTitle.copyWith(
                  color: isDark ? AppColors.gold : AppColors.primary,
                ),
              ),
              const SizedBox(height: AppTokens.spacing8),

              // Transliteration
              Text(
                transliteration,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.spacing4),

              // Meaning
              Text(
                meaning,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
�L"(ad531abe872c7cf491ed881344a14c5a674c9d842tfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/names_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life