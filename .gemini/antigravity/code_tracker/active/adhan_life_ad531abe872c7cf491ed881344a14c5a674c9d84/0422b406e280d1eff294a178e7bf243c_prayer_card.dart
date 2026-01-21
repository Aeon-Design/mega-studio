ž9import 'package:flutter/material.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/data/models/prayer_time.dart';
import 'package:adhan_life/l10n/app_localizations.dart';

/// Prayer Card Widget - Sunrise Serenity Edition
class PrayerCard extends StatefulWidget {
  final Prayer prayer;
  final String time;
  final bool isPassed;
  final bool isNext;
  final Color accentColor;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.time,
    this.isPassed = false,
    this.isNext = false,
    required this.accentColor,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine indicator color based on state
    Color indicatorColor;
    if (widget.isPassed) {
      indicatorColor = AppColors.indicatorPassed;
    } else if (widget.isNext) {
      indicatorColor = AppColors.indicatorActive;
    } else {
      indicatorColor = AppColors.indicatorFuture;
    }

    // Sunrise Serenity Decoration
    Decoration cardDecoration;
    if (widget.isNext) {
      cardDecoration = BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      );
    } else {
      // Dark Mode: Passed/Future cards look like Surah tiles (Filled)
      // Light Mode: Passed is transparent, Future is semi-transparent
      cardDecoration = BoxDecoration(
        color: isDark 
            ? AppColors.surfaceVariantDark 
            : (widget.isPassed ? Colors.transparent : AppColors.surface.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : (widget.isPassed ? AppColors.indicatorPassed.withValues(alpha: 0.3) : Colors.white),
          width: 1,
        ),
      );
    }

    // Text Style
    final TextStyle nameStyle = AppTypography.titleMedium.copyWith(
       color: isDark 
          ? Colors.white.withValues(alpha: widget.isPassed ? 0.7 : 1.0)
          : (widget.isPassed ? AppColors.textSecondary.withValues(alpha: 0.7) : AppColors.textPrimary),
       fontWeight: widget.isNext ? FontWeight.w700 : FontWeight.w500,
    );
    
    final TextStyle timeStyle = AppTypography.titleLarge.copyWith(
       color: isDark
          ? Colors.white.withValues(alpha: widget.isPassed ? 0.7 : 1.0)
          : (widget.isPassed ? AppColors.textSecondary.withValues(alpha: 0.7) : (widget.isNext ? AppColors.primary : AppColors.textPrimary)),
       fontWeight: widget.isNext ? FontWeight.w800 : FontWeight.w600,
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: () {
            // Show prayer info feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.prayer.name} at ${widget.time}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            decoration: cardDecoration,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacing16,
                vertical: AppTokens.spacing16, 
              ),
              child: Row(
                children: [
                   // Minimal Indicator for Active/Future
                   if (!widget.isPassed) 
                     Container(
                        width: 4, 
                        height: 40,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                     ),
                    
                   // Check icon for passed
                   if (widget.isPassed)
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.check_circle_outline, color: AppColors.indicatorPassed, size: 24),
                      ),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedPrayerName(context, widget.prayer.name),
                          style: nameStyle,
                        ),
                        if (widget.isNext)
                          Text(
                            AppLocalizations.of(context)!.labelNextPrayer,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Time
                  Text(widget.time, style: timeStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedPrayerName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key.toLowerCase()) {
      case 'fajr': return l10n.prayerFajr;
      case 'dhuhr': return l10n.prayerDhuhr;
      case 'asr': return l10n.prayerAsr;
      case 'maghrib': return l10n.prayerMaghrib;
      case 'isha': return l10n.prayerIsha;
      case 'sunrise': return l10n.prayerSunrise;
      default: return key;
    }
  }
}
ž9"(ad531abe872c7cf491ed881344a14c5a674c9d842ofile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/widgets/prayer_card.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life