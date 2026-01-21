�Timport 'package:flutter/material.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';


class PrayerLearningScreen extends StatefulWidget {
  const PrayerLearningScreen({super.key});

  @override
  State<PrayerLearningScreen> createState() => _PrayerLearningScreenState();
}

class _PrayerLearningScreenState extends State<PrayerLearningScreen> {
  final List<PrayerPosition> _positions = [
    const PrayerPosition(
      id: 'niyyah',
      nameEn: 'Intention (Niyyah)',
      nameAr: 'النِّيَّة',
      description: 'Make the intention in your heart to pray. Stand facing the Qibla (direction of Kaaba in Mecca).',
      arabicDua: 'نَوَيْتُ أَنْ أُصَلِّيَ',
      transliteration: 'Nawaytu an usalliya...',
      translation: 'I intend to pray...',
      icon: Icons.favorite,
      order: 1,
    ),
    const PrayerPosition(
      id: 'takbir',
      nameEn: 'Takbiratul Ihram',
      nameAr: 'تَكْبِيرَة الإِحْرَام',
      description: 'Raise both hands to ear level and say "Allahu Akbar" (Allah is the Greatest). This begins the prayer.',
      arabicDua: 'اللّٰهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      icon: Icons.pan_tool,
      order: 2,
    ),
    const PrayerPosition(
      id: 'qiyam',
      nameEn: 'Standing (Qiyam)',
      nameAr: 'القِيَام',
      description: 'Place right hand over left on chest. Recite Al-Fatiha and another Surah.',
      arabicDua: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ\nاَلْحَمْدُ لِلّٰهِ رَبِّ الْعَالَمِينَ',
      transliteration: 'Bismillahir Rahmanir Rahim\nAlhamdu lillahi Rabbil Aalameen...',
      translation: 'In the name of Allah, the Most Gracious, the Most Merciful.\nPraise be to Allah, Lord of all the worlds...',
      icon: Icons.accessibility_new,
      order: 3,
    ),
    const PrayerPosition(
      id: 'ruku',
      nameEn: 'Bowing (Ruku)',
      nameAr: 'الرُّكُوع',
      description: 'Say "Allahu Akbar" and bow down with hands on knees, back straight. Say "Subhana Rabbiyal Azeem" 3 times.',
      arabicDua: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      transliteration: 'Subhana Rabbiyal Azeem',
      translation: 'Glory be to my Lord, the Most Great',
      icon: Icons.airline_seat_legroom_reduced,
      order: 4,
    ),
    const PrayerPosition(
      id: 'itidal',
      nameEn: 'Rising from Ruku',
      nameAr: 'الاِعْتِدَال',
      description: 'Stand up straight saying "Sami Allahu liman hamidah" then "Rabbana lakal hamd".',
      arabicDua: 'سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ\nرَبَّنَا وَلَكَ الْحَمْدُ',
      transliteration: 'Sami Allahu liman hamidah\nRabbana wa lakal hamd',
      translation: 'Allah hears those who praise Him\nOur Lord, praise be to You',
      icon: Icons.accessibility_new,
      order: 5,
    ),
    const PrayerPosition(
      id: 'sujud1',
      nameEn: 'Prostration (Sujud)',
      nameAr: 'السُّجُود',
      description: 'Say "Allahu Akbar" and prostrate with forehead, nose, palms, knees, and toes touching the ground. Say "Subhana Rabbiyal Aala" 3 times.',
      arabicDua: 'سُبْحَانَ رَبِّيَ الأَعْلَى',
      transliteration: 'Subhana Rabbiyal Aala',
      translation: 'Glory be to my Lord, the Most High',
      icon: Icons.brightness_low,
      order: 6,
    ),
    const PrayerPosition(
      id: 'jalsa',
      nameEn: 'Sitting (Jalsa)',
      nameAr: 'الجَلْسَة',
      description: 'Say "Allahu Akbar" and sit up. Say "Rabbighfir li" (O Lord, forgive me).',
      arabicDua: 'رَبِّ اغْفِرْ لِي',
      transliteration: 'Rabbighfir li',
      translation: 'O my Lord, forgive me',
      icon: Icons.event_seat,
      order: 7,
    ),
    const PrayerPosition(
      id: 'sujud2',
      nameEn: 'Second Prostration',
      nameAr: 'السُّجُود الثَّانِي',
      description: 'Say "Allahu Akbar" and prostrate again. Say "Subhana Rabbiyal Aala" 3 times.',
      arabicDua: 'سُبْحَانَ رَبِّيَ الأَعْلَى',
      transliteration: 'Subhana Rabbiyal Aala',
      translation: 'Glory be to my Lord, the Most High',
      icon: Icons.brightness_low,
      order: 8,
    ),
    const PrayerPosition(
      id: 'tashahhud',
      nameEn: 'Tashahhud (Sitting)',
      nameAr: 'التَّشَهُّد',
      description: 'In the last sitting, recite At-Tahiyyat, Salawat, and supplications.',
      arabicDua: 'التَّحِيَّاتُ لِلّٰهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ',
      transliteration: 'At-tahiyyatu lillahi was-salawatu wat-tayyibat...',
      translation: 'All greetings, prayers and good things are for Allah...',
      icon: Icons.event_seat,
      order: 9,
    ),
    const PrayerPosition(
      id: 'salam',
      nameEn: 'Salam (Ending)',
      nameAr: 'السَّلَام',
      description: 'Turn your head to the right saying "Assalamu alaikum wa rahmatullah", then to the left with the same words.',
      arabicDua: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللّٰهِ',
      transliteration: 'Assalamu alaikum wa rahmatullah',
      translation: 'Peace and mercy of Allah be upon you',
      icon: Icons.waving_hand,
      order: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn to Pray'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppTokens.spacing16),
        itemCount: _positions.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppTokens.spacing16),
        itemBuilder: (context, index) {
          final position = _positions[index];
          return _PrayerStepCard(position: position);
        },
      ),
    );
  }
}

class _PrayerStepCard extends StatelessWidget {
  final PrayerPosition position;

  const _PrayerStepCard({required this.position});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTokens.spacing8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(position.icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppTokens.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.nameEn,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        position.nameAr,
                        style: AppTypography.arabicTitle.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    'Step ${position.order}',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing12),
            Text(
              position.description,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppTokens.spacing12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.spacing12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(
                    position.arabicDua,
                    style: AppTypography.arabicBody.copyWith(
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spacing8),
                  Text(
                    position.transliteration,
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 16),
                  Text(
                    position.translation,
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerPosition {
  final String id;
  final String nameEn;
  final String nameAr;
  final String description;
  final String arabicDua;
  final String transliteration;
  final String translation;
  final IconData icon;
  final int order;

  const PrayerPosition({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.arabicDua,
    required this.transliteration,
    required this.translation,
    required this.icon,
    required this.order,
  });
}
�T*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842~file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/prayer_learning_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life