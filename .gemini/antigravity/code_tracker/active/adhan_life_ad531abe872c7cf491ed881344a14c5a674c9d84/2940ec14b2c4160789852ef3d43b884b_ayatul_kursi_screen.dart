�Pimport 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';

/// Ayatul Kursi Screen - Displays only verse 2:255
class AyatulKursiScreen extends StatelessWidget {
  const AyatulKursiScreen({super.key});

  // Ayatul Kursi - Surah Al-Baqarah, Verse 255
  static const String _arabic = '''اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ''';

  static const String _transliteration = '''Allaahu laaa 'ilaaha 'illaa Huwal-Hayyul-Qayyuum. Laa ta'khuzuhuu sinatunw-wa laa nawm. Lahuu maa fis-samaawaati wa maa fil-'ard. Man zal-lazii yashfa'u 'indahuuu 'illaa bi'iznih. Ya'lamu maa bayna 'aydiihim wa maa khalfahum. Wa laa yuhiituuna bishay'im-min 'ilmihiii 'illaa bimaa shaaa'. Wasi'a Kursiyyuhus-samaawaati wal-'ard. Wa laa ya'uuduhuu hifzuhumaa. Wa Huwal-'Aliyyul-'Aziim.''';

  static const String _translationEn = '''Allah! There is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareAyatulKursi(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Ayatul Kursi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The Throne Verse',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Surah Al-Baqarah (2:255)',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacing20),
                      child: Text(
                        _arabic,
                        style: AppTypography.arabicDisplay.copyWith(
                          fontSize: 28,
                          height: 2.0,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing16),

                  // Transliteration
                  Card(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transliteration',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTokens.spacing8),
                          Text(
                            _transliteration,
                            style: AppTypography.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing16),

                  // Translation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Translation',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTokens.spacing8),
                          Text(
                            _translationEn,
                            style: AppTypography.bodyMedium.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing24),

                  // Virtue
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, 
                                color: AppColors.gold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Virtue',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.spacing8),
                          Text(
                            'The Prophet ﷺ said: "Whoever recites Ayatul Kursi after every obligatory prayer, nothing will prevent him from entering Paradise except death."',
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '— Sunan An-Nasai',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareAyatulKursi() {
    Share.share(
      'Ayatul Kursi (2:255)\n\n$_arabic\n\n$_translationEn\n\n— Shared via AdhanLife',
    );
  }
}
�P*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842{file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/ayatul_kursi_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life