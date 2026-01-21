“A
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:adhan_life/core/utils/islamic_date_utils.dart';
import 'package:adhan_life/data/models/prayer_time.dart';
import 'package:adhan_life/features/prayer_times/providers/prayer_provider.dart';
import '../widgets/prayer_card.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_life/app/providers.dart';
import 'package:adhan_life/core/services/storage_service.dart';
import 'package:adhan_life/core/services/storage_service.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/zikr_counter_widget.dart';

/// Home Screen - Main prayer times display
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Responsive background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              centerTitle: false,
              title: Text(
                AppLocalizations.of(context)!.appTitle, 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    // Navigate to notification settings
                    context.push('/settings/notifications');
                  },
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppTokens.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Location & Date
                  _buildLocationHeader(context),
                  const SizedBox(height: AppTokens.spacing24),

                  // Next Prayer Card
                  _buildNextPrayerCard(context, ref),
                  const SizedBox(height: AppTokens.spacing24),

                  // All Prayer Times
                  _buildSectionTitle(context, AppLocalizations.of(context)!.todaysPrayerTimes),
                  const SizedBox(height: AppTokens.spacing12),

                  // Prayer list
                  _buildPrayerList(context, ref),

                  const SizedBox(height: AppTokens.spacing24),

                  // Zikr Counter
                  const ZikrCounterWidget(),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    // Dynamic Date
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final hijri = HijriDate.fromGregorian(now);
    
    // Location Logic
    return Consumer(
      builder: (context, ref, _) {
          final storage = ref.watch(storageServiceProvider);
          final isManual = storage.getIsManualLocation();
          final manualCity = storage.getManualCity();
          
          String locationName = AppLocalizations.of(context)!.currentLocation;
          if (isManual && manualCity != null) {
              locationName = manualCity;
          }

          return InkWell(
            onTap: () {
               // Quick access to location settings
               context.push('/settings/location');
            },
            borderRadius: AppTokens.borderRadiusMedium,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.spacing8),
              child: Row(
                children: [
                  Icon(
                    isManual ? Icons.location_city : Icons.location_on,
                    size: AppTokens.iconSmall,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppTokens.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                locationName, 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isManual) ...[
                               const SizedBox(width: 4),
                               Icon(Icons.edit, size: 14, color: Theme.of(context).textTheme.bodySmall?.color)
                            ]
                          ],
                        ),
                        Text(
                          '${DateFormat.MMMMEEEEd(locale).format(now)} â€¢ ${hijri.format(locale)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    );
  }

  Widget _buildNextPrayerCard(BuildContext context, WidgetRef ref) {
      final nextAsync = ref.watch(nextPrayerProvider);
      
      return nextAsync.when(
        data: (data) {
           final (prayer, time, remaining) = data;
           return NextPrayerCard(
             prayer: prayer,
             time: time,
             remainingTime: remaining,
           );
        },
        loading: () => const SizedBox(
            height: 150, 
            child: Center(child: CircularProgressIndicator())
        ),
        error: (_, __) => const SizedBox.shrink(),
      );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, WidgetRef ref) {
    final prayersAsync = ref.watch(dailyPrayerProvider);
    final nextAsync = ref.watch(nextPrayerProvider); // To highlight next prayer
    
    return prayersAsync.when(
      data: (prayersData) {
          return Column(
            children: prayersData.map((data) {
              final (prayer, time, isPassed) = data;
              
              // Determine if this is the next prayer
              bool isNext = false;
              if (nextAsync.hasValue) {
                 isNext = nextAsync.value!.$1 == prayer;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.spacing8),
                child: PrayerCard(
                  prayer: prayer,
                  time: time,
                  isPassed: isPassed,
                  isNext: isNext,
                  accentColor: _getPrayerColor(prayer),
                ),
              );
            }).toList(),
          );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading prayers')),
    );
  }

  Color _getPrayerColor(Prayer prayer) {
    final scheme = AppColors.prayerColorSchemes[prayer.name.toLowerCase()];
    return scheme?.primary ?? AppColors.primary;
  }
}
“A"(ad531abe872c7cf491ed881344a14c5a674c9d842ofile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/screens/home_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life