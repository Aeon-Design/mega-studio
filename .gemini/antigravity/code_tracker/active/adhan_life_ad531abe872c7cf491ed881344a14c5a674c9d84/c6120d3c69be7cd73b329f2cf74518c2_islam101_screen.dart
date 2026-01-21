ÑWimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/repositories/content_repository.dart';
import 'package:adhan_life/features/learning/presentation/screens/islam101_lessons_screen.dart';

/// Islam 101 Course Screen
class Islam101Screen extends ConsumerWidget {
  const Islam101Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(islam101Provider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: modulesAsync.when(
        data: (modules) => CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    // Only show title when collapsed
                    final isCollapsed = constraints.biggest.height <= 100;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: const Text(
                        'Islam 101',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 56,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your Journey to Understanding Islam',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 40), // Space for title
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Progress overview
            SliverToBoxAdapter(
              child: _buildProgressCard(),
            ),

            // Modules list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = modules[index];
                  // All modules with content are unlocked
                  final isUnlocked = true; 

                  return _ModuleCard(
                    module: module,
                    index: index,
                    isUnlocked: isUnlocked,
                    languageCode: locale,
                  );
                },
                childCount: modules.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.primary),
                  const SizedBox(width: AppTokens.spacing8),
                  Text(
                    'Your Progress',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '9/9 Completed',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spacing12),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppTokens.spacing8),
              Text(
                'All modules available!',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Islam101Module module;
  final int index;
  final bool isUnlocked;
  final String languageCode;

  const _ModuleCard({
    required this.module,
    required this.index,
    required this.isUnlocked,
    required this.languageCode,
  });



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing16,
        vertical: AppTokens.spacing4,
      ),
      child: Card(
        color: !isUnlocked
            ? (isDark ? AppColors.surfaceVariantDark : Colors.grey.shade200)
            : null,
        child: InkWell(
          onTap: isUnlocked
              ? () {
                  // Navigate to lessons screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Islam101LessonsScreen(module: module),
                    ),
                  );
                }
              : null,
          borderRadius: AppTokens.borderRadiusMedium,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacing16),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.primary : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.spacing16),

                // Module info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.getTitle(languageCode),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: !isUnlocked ? AppColors.textTertiary : null,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spacing4),
                      Text(
                        module.getDescription(languageCode),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTokens.spacing8),
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${module.lessonsCount} lessons',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: AppTokens.spacing12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.duration,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow or lock
                Icon(
                  isUnlocked ? Icons.chevron_right : Icons.lock_outline,
                  color: isUnlocked ? AppColors.textSecondary : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
⁄ ⁄º*cascade08
ºÁ Á∏*cascade08
∏« «Õ*cascade08
Õˇ ˇÖ*cascade08
Öò òõ*cascade08
õØ Ø≤*cascade08
≤– –÷*cascade08
÷ã ãë*cascade08
ëï ï›*cascade08
›å åê *cascade08
êë ëó*cascade08
óò òô*cascade08
ôö ö£*cascade08
£• •®*cascade08
®ÿ ÿ€*cascade08
€Ò" Ò"Ù"*cascade08
Ù"Å+ Å+Ç+*cascade08
Ç+É+ É+Ñ+*cascade08
Ñ+“- “-’-*cascade08
’-’/ ’/÷/*cascade08
÷/‡/ ‡/Í/*cascade08
Í/à8 à8í8*cascade08
í8ñ8 ñ8õ8*cascade08
õ8ù8 ù8û8*cascade08
û8°8 °8¢8*cascade08
¢8∂8 ∂8∑8*cascade08
∑8∏8 ∏8∫8*cascade08
∫8ª8 ª8æ8*cascade08
æ8¿8 ¿8¬8*cascade08
¬8€8 €8›8*cascade08
›8ﬁ8 ﬁ8„8*cascade08
„8˘8 ˘8˙8*cascade08
˙8˝8 ˝8˛8*cascade08
˛8ˇ8 ˇ8Ä9*cascade08
Ä9Å9 Å9Ç9*cascade08
Ç9Ö9 Ö9Ü9*cascade08
Ü9á9 á9â9*cascade08
â9ä9 ä9ã9*cascade08
ã9£9 £9§9*cascade08
§9¶9 ¶9™9*cascade08
™9¨9 ¨9≠9*cascade08
≠9∞9 ∞9≥9*cascade08
≥9¥9 ¥9µ9*cascade08
µ9∂9 ∂9º9*cascade08
º9Ω9 Ω9≈9*cascade08
≈9»9 »9…9*cascade08
…9 9  9Õ9*cascade08
Õ9Œ9 Œ9—9*cascade08
—9“9 “9’9*cascade08
’9◊9 ◊9›9*cascade08
›9ÑW "(ad531abe872c7cf491ed881344a14c5a674c9d842wfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/islam101_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life