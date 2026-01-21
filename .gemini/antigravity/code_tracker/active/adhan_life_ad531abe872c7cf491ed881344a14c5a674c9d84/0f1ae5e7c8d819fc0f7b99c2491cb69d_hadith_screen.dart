Ý5import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/repositories/content_repository.dart';
import 'package:adhan_life/core/services/bookmark_service.dart';
import 'package:adhan_life/app/providers.dart';

/// Hadith Screen - Daily hadith collection
class HadithScreen extends ConsumerWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithsAsync = ref.watch(hadithsProvider);
    final locale = ref.watch(localeProvider);
    final languageCode = locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              // Scroll to random hadith
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Showing random hadith...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: hadithsAsync.when(
        data: (hadiths) => ListView.builder(
          padding: const EdgeInsets.all(AppTokens.spacing16),
          itemCount: hadiths.length,
          itemBuilder: (context, index) {
            final hadith = hadiths[index];
            return _HadithCard(
              hadith: hadith,
              languageCode: languageCode,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading hadiths: $error'),
        ),
      ),
    );
  }
}



class _HadithCard extends ConsumerWidget {
  final HadithModel hadith;
  final String languageCode;

  const _HadithCard({
    required this.hadith,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = ref.watch(isHadithBookmarkedProvider(hadith.id));

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacing12,
                    vertical: AppTokens.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppTokens.borderRadiusFull,
                  ),
                  child: Text(
                    '${hadith.source} #${hadith.number}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Container()), // Spacer
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.gold : AppColors.textSecondary,
                  ),
                  onPressed: () async {
                    final bookmark = HadithBookmark(
                      hadithId: hadith.id,
                      text: hadith.arabic,
                      translation: hadith.getTranslation(languageCode),
                      source: '${hadith.source} #${hadith.number}',
                      createdAt: DateTime.now(),
                    );
                    await ref.read(bookmarkServiceProvider).toggleHadithBookmark(bookmark);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  iconSize: 20,
                  color: AppColors.textSecondary,
                  onPressed: () {
                    final text = '${hadith.arabic}\n\n'
                        '${hadith.getTranslation(languageCode)}\n\n'
                        'â€” ${hadith.source} #${hadith.number}\n'
                        'â€” Shared via AdhanLife';
                    Share.share(text, subject: 'Hadith');
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing16),

            // Arabic text
            Text(
              hadith.arabic,
              style: AppTypography.arabicLarge.copyWith(
                color: isDark ? AppColors.gold : AppColors.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppTokens.spacing16),

            // Translation
            Text(
              hadith.getTranslation(languageCode),
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spacing16),

            // Source info
            Container(
              padding: const EdgeInsets.all(AppTokens.spacing12),
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity( 0.5),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoChip(Icons.person_outline, hadith.narrator),
                  _buildInfoChip(Icons.book_outlined, '${hadith.source} #${hadith.number}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

Ý5"(ad531abe872c7cf491ed881344a14c5a674c9d842ufile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/hadith_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life