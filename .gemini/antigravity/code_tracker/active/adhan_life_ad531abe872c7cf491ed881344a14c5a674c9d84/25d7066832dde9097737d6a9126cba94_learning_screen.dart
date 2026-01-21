úhimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:adhan_life/core/services/quran_service.dart';
import 'package:adhan_life/app/providers.dart';

/// Learning Screen - Islamic education hub
class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicitly watch locale to force rebuild on language change
    ref.watch(localeProvider); 
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(AppLocalizations.of(context)!.navLearn),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () {
                  // Navigate to bookmarks
                  context.pushNamed('bookmarks');
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spacing16, 
              AppTokens.spacing16, 
              AppTokens.spacing16, 
              100 // Bottom padding to clear NavigationBar
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Daily card
                _buildDailyCard(context, ref),
                const SizedBox(height: AppTokens.spacing24),

                // Categories
                _buildSectionTitle(context, AppLocalizations.of(context)!.categories),
                const SizedBox(height: AppTokens.spacing12),
                _buildCategoriesGrid(context),
                const SizedBox(height: AppTokens.spacing24),

                // Quick access
                _buildSectionTitle(context, AppLocalizations.of(context)!.quickAccess),
                const SizedBox(height: AppTokens.spacing12),
                _buildQuickAccessList(context),
                const SizedBox(height: AppTokens.spacing24),

                // Continue learning
                _buildSectionTitle(context, AppLocalizations.of(context)!.continueLearning),
                const SizedBox(height: AppTokens.spacing12),
                _buildContinueLearning(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(BuildContext context, WidgetRef ref) {
    final dailyVerseAsync = ref.watch(dailyVerseProvider);

    return dailyVerseAsync.when(
      data: (verse) => Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppTokens.borderRadiusLarge,
        ),
        padding: const EdgeInsets.all(AppTokens.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacing12,
                    vertical: AppTokens.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppTokens.borderRadiusFull,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.dailyVerse,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Random verse',
                  onPressed: () => ref.invalidate(dailyVerseProvider),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Share',
                  onPressed: () {
                    Share.share(
                      '"${verse.translation}"\n\n${verse.surahName} (${verse.surahNumber}:${verse.verseNumber})',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing16),
            Text(
              '"${verse.translation}"',
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTokens.spacing8),
            Text(
              '${verse.surahName} (${verse.surahNumber}:${verse.verseNumber})',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(), // Graceful fail
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

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      ('üïå', AppLocalizations.of(context)!.catPrayer, AppColors.primary, 'prayer-learning'),
      ('üìñ', AppLocalizations.of(context)!.catQuran, AppColors.gold, 'quran'),
      ('ü§≤', AppLocalizations.of(context)!.catDuas, AppColors.deepBlue, 'duas'),
      ('‚ú®', AppLocalizations.of(context)!.cat99Names, AppColors.primaryLight, 'names'),
      ('üìö', AppLocalizations.of(context)!.catHadith, AppColors.success, 'hadith'),
      ('üîñ', 'Bookmarks', AppColors.warning, 'bookmarks'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppTokens.spacing12,
        mainAxisSpacing: AppTokens.spacing12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final (emoji, title, color, routeName) = categories[index];
        return _CategoryCard(
          emoji: emoji,
          title: title,
          color: color,
          onTap: () {
            if (routeName.isNotEmpty) {
              if (routeName == 'quran') {
                context.go('/quran'); // Use go for top-level tab
              } else {
                context.pushNamed(routeName);
              }
            }
          },
        );
      },
    );
  }

  Widget _buildQuickAccessList(BuildContext context) {
    // Each item: (title, subtitle, icon, route, routeParams)
    final items = [
      (AppLocalizations.of(context)!.qaAyatulKursi, AppLocalizations.of(context)!.qaThroneVerse, Icons.star, 'ayatul-kursi'),
      (AppLocalizations.of(context)!.qaMorningAdhkar, AppLocalizations.of(context)!.qaMorningDesc, Icons.wb_sunny_outlined, 'morning-adhkar'),
      (AppLocalizations.of(context)!.qaEveningAdhkar, AppLocalizations.of(context)!.qaEveningDesc, Icons.nights_stay_outlined, 'evening-adhkar'),
      (AppLocalizations.of(context)!.qaBeforeSleep, AppLocalizations.of(context)!.qaSleepDesc, Icons.bedtime_outlined, 'sleep-duas'),
    ];

    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppTokens.spacing8),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Icon(
                item.$3,
                color: AppColors.primary,
              ),
            ),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final route = item.$4;
              if (route == 'ayatul-kursi') {
                // Navigate to dedicated Ayatul Kursi screen
                context.pushNamed('ayatul-kursi');
              } else if (route == 'morning-adhkar') {
                context.pushNamed('duas', queryParameters: {'category': 'morning'});
              } else if (route == 'evening-adhkar') {
                context.pushNamed('duas', queryParameters: {'category': 'evening'});
              } else if (route == 'sleep-duas') {
                context.pushNamed('duas', queryParameters: {'category': 'sleep'});
              } else {
                context.pushNamed('duas');
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueLearning(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: AppTokens.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Islam 101',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Module 1 of 9',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTokens.spacing8),
                ElevatedButton(
                  onPressed: () {
                     context.pushNamed('islam101');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(AppLocalizations.of(context)!.btnStart),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing16),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
            const SizedBox(height: AppTokens.spacing8),
            Text(
              '0% complete',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.borderRadiusMedium,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: AppTokens.spacing8),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

ı ı„!*cascade08
„!ì" ì"∏"*cascade08
∏"«" «"à$*cascade08
à$≠0 ≠0±0*cascade08
±0¥0 ¥0∂0*cascade08
∂0∏0 ∏0∫0*cascade08
∫0ª0 ª0Ω0*cascade08
Ω0æ0 æ0ø0*cascade08
ø0’0 ’0›0*cascade08
›0±C ±CáD*cascade08
áDñD ñDõD*cascade08õDúD *cascade08úDüD*cascade08üD£D *cascade08
£D§D §D¶D*cascade08
¶DßD ßD™D*cascade08
™D¨D ¨D≠D*cascade08≠DÆD*cascade08ÆDØD*cascade08ØD±D *cascade08±D≥D*cascade08
≥DµD µD∑D*cascade08
∑D—D —D÷D*cascade08
÷DÿD ÿD‡D*cascade08
‡D·D ·D‚D*cascade08
‚D„D „D‰D*cascade08
‰DÁD ÁDÌD*cascade08
ÌDÓD ÓDÄE*cascade08
ÄEÅE ÅEÇE*cascade08
ÇEÑE ÑEáE*cascade08
áEàE àEèE*cascade08
èEëE ëEíE*cascade08
íEìE ìEîE*cascade08
îEñE ñEòE*cascade08
òEôE ôEûE*cascade08
ûEÆE ÆE∞E*cascade08
∞E∏E ∏E∫E*cascade08
∫EºE ºEΩE*cascade08
ΩEæE æE›E*cascade08
›EﬂE ﬂE„E*cascade08
„E‰E ‰EÙE*cascade08
ÙEÑF ÑFÖF*cascade08
ÖFÜF ÜFäF*cascade08
äFãF ãFúF*cascade08
úFùF ùF°F*cascade08
°F¢F ¢F§F*cascade08
§FßF ßF´F*cascade08
´F¬F ¬F√F*cascade08
√FƒF ƒF÷F*cascade08
÷F◊F ◊F„F*cascade08
„F‰F ‰FÏF*cascade08
ÏFÌF ÌFÚF*cascade08
ÚFÛF ÛF¯F*cascade08
¯F˝F ˝F˛F*cascade08
˛FÄG ÄGÅG*cascade08
ÅGëG ëGíG*cascade08
íGìG ìGóG*cascade08
óGòG òGöG*cascade08
öGõG õG°G*cascade08
°G¢G ¢G¨G*cascade08
¨GØG ØG≈G*cascade08
≈G…G …G–G*cascade08
–G—G —GﬂG*cascade08
ﬂG‡G ‡G·G*cascade08
·G‚G ‚GÁG*cascade08
ÁGÈG ÈGÎG*cascade08
ÎGÏG ÏGÓG*cascade08
ÓGÔG ÔGˆG*cascade08
ˆG˜G ˜G¯G*cascade08
¯G˘G ˘G¸G*cascade08
¸G˛G ˛GÜH*cascade08
ÜHáH áHàH*cascade08
àHòH òHôH*cascade08
ôHöH öHûH*cascade08
ûHüH üH†H*cascade08
†H∞H ∞H H*cascade08
 HÃH ÃH›H*cascade08
›HÉU ÉUÑU*cascade08
ÑUàU àUâU*cascade08
âUï[ ï[ü[*cascade08
ü[†[ †[ß[*cascade08
ß[™[ ™[±[*cascade08
±[µ[ µ[ª[*cascade08ª[º[ *cascade08
º[Ω[ Ω[ø[*cascade08
ø[Ô\ Ô\\*cascade08
\Ò\ Ò\Ú\*cascade08
Ú\úh "(ad531abe872c7cf491ed881344a14c5a674c9d842wfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/learning_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life