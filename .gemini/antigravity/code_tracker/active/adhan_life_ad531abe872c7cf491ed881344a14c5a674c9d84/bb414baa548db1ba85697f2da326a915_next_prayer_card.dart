¥eimport 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/theme/islamic_pattern_painter.dart';
import 'package:adhan_life/data/models/prayer_time.dart';
import 'package:adhan_life/l10n/app_localizations.dart';

/// Next Prayer Card - Premium Glassmorphic Design with Islamic Patterns
class NextPrayerCard extends StatefulWidget {
  final Prayer prayer;
  final String time;
  final Duration remainingTime;

  const NextPrayerCard({
    super.key,
    required this.prayer,
    required this.time,
    required this.remainingTime,
  });

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getLocalizedPrayerName(BuildContext context, String key) {
    // Force rebuild on locale change
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

  /// Get prayer-specific gradient
  Gradient _getPrayerGradient() {
    return AppColors.getPrayerGradient(widget.prayer.name);
  }

  /// Get prayer-specific icon
  IconData _getPrayerIcon() {
    switch (widget.prayer.name.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.light_mode;
      case 'asr':
        return Icons.wb_cloudy;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.schedule;
    }
  }

  /// Get prayer color for glow effect
  Color _getPrayerGlowColor() {
    switch (widget.prayer.name.toLowerCase()) {
      case 'fajr':
        return AppColors.fajr;
      case 'sunrise':
        return AppColors.sunrise;
      case 'dhuhr':
        return AppColors.dhuhr;
      case 'asr':
        return AppColors.asr;
      case 'maghrib':
        return AppColors.maghrib;
      case 'isha':
        return AppColors.isha;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getPrayerGradient(),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: _getPrayerGlowColor().withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Islamic Pattern Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppTokens.borderRadiusLarge,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: Colors.white,
                  opacity: 0.15, // Slightly more visible
                  patternType: PatternType.crescentMoon,
                ),
              ),
            ),
          ),

          // Decorative Circles (corner accents) - Keeping these
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppTokens.borderRadiusLarge,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: Colors.white,
                  opacity: 0.05,
                  patternType: PatternType.cornerCircles,
                ),
              ),
            ),
          ),
          
          // REMOVED: Large Sun Icon Positioned widget to prevent overlap

          // Content
          Padding(
            padding: const EdgeInsets.all(AppTokens.spacing24),
            child: Column(
              children: [
                // Timer Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Push to right
                  children: [
                    // REMOVED "Next Prayer" text label to simplify
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.spacing16,
                            vertical: AppTokens.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2), // Darker contrast
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.0,
                            ),
                            borderRadius: AppTokens.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(context, widget.remainingTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Time Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedPrayerName(context, widget.prayer.name),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            height: 1.0,
                            fontWeight: FontWeight.w800, // Extra bold
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!
                              .timeForPrayer(_getLocalizedPrayerName(
                            context,
                            widget.prayer.name,
                          )),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.time,
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 42,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions Row (Glassmorphism)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Row(
                    children: [
                      _buildActionButton(
                        context,
                        Icons.volume_up_rounded,
                        AppLocalizations.of(context)!.btnAdhan,
                        () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Adhan Preview Active'), duration: Duration(seconds: 1)),
                            );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        context,
                        Icons.notifications_active_rounded,
                        AppLocalizations.of(context)!.btnRemind,
                        () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder Set'), duration: Duration(seconds: 1)),
                            );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        context,
                        Icons.share_rounded,
                        AppLocalizations.of(context)!.btnShare,
                        () {
                            // Share prayer time using share_plus
                            final prayerName = widget.prayer.name;
                            final prayerTime = widget.time;
                            final text = 'ðŸ•Œ Next Prayer: $prayerName at $prayerTime\n\n'
                                'â€” Shared via AdhanLife';
                            Share.share(text, subject: 'Prayer Time');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.borderRadiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    // TODO: Ideally use l10n for 'h' and 'm' if strict requirement, but 'h'/'m' is standard enough for now
    // or use context.l10n.timeRemaining(hours, minutes) if structure supports it
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }
}
¥e"(ad531abe872c7cf491ed881344a14c5a674c9d842tfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/widgets/next_prayer_card.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life