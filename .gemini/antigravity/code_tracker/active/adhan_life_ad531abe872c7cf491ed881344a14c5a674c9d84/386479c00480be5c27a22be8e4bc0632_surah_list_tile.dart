ç!import 'package:flutter/material.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/data/models/surah.dart';

/// Surah list tile widget
class SurahListTile extends StatelessWidget {
  final SurahInfo surah;
  final VoidCallback? onTap;

  const SurahListTile({
    super.key,
    required this.surah,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing16,
        vertical: AppTokens.spacing4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.borderRadiusMedium,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing12),
          child: Row(
            children: [
              // Surah number
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity( 0.1),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Center(
                  child: Text(
                    surah.id.toString(),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spacing12),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.transliteration,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spacing2),
                    Row(
                      children: [
                        _buildTag(
                          surah.type == 'Meccan' ? 'Meccan' : 'Medinan',
                          surah.type == 'Meccan'
                              ? AppColors.gold
                              : AppColors.deepBlue,
                        ),
                        const SizedBox(width: AppTokens.spacing8),
                        Text(
                          '${surah.totalVerses} verses',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arabic name
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.name,
                    style: AppTypography.arabicTitle.copyWith(
                      color: isDark ? AppColors.gold : AppColors.primary,
                    ),
                  ),
                  Text(
                    surah.translation,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing6,
        vertical: AppTokens.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity( 0.1),
        borderRadius: AppTokens.borderRadiusSmall,
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

ç!"(ad531abe872c7cf491ed881344a14c5a674c9d842tfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/quran/presentation/widgets/surah_list_tile.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life