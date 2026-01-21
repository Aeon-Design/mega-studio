 himport 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_life/app/providers.dart';
import '../l10n/app_localizations.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/quran/presentation/screens/quran_screen.dart';
import '../features/quran/presentation/screens/surah_reader_screen.dart';
import '../features/quran/presentation/screens/bookmarks_screen.dart';
import '../features/learning/presentation/screens/learning_screen.dart';
import '../features/learning/presentation/screens/duas_screen.dart';
import '../features/learning/presentation/screens/names_screen.dart';
import '../features/learning/presentation/screens/islam101_screen.dart';
import '../features/learning/presentation/screens/ayatul_kursi_screen.dart';
import '../features/learning/presentation/screens/hadith_screen.dart';
import '../features/learning/presentation/screens/quiz_screen.dart';
import '../features/learning/presentation/screens/prayer_learning_screen.dart';
import '../features/learning/presentation/screens/wudu_learning_screen.dart';
import '../features/learning/presentation/screens/tayammum_learning_screen.dart';
import '../features/learning/presentation/screens/first_30_days_screen.dart';
import '../features/learning/presentation/screens/arabic_alphabet_screen.dart';
import '../features/learning/presentation/screens/tasbih_screen.dart';
import '../features/learning/presentation/screens/hijri_calendar_screen.dart';
import '../features/learning/presentation/screens/zakat_calculator_screen.dart';
import '../features/prayer_times/presentation/screens/prayer_tracker_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../features/settings/presentation/screens/location_selection_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/settings/presentation/screens/language_screen.dart';
import '../features/settings/presentation/screens/quran_settings_screen.dart';


/// Router provider for navigation
final routerProvider = Provider<GoRouter>((ref) {
  // Watch locale to rebuild router when language changes
  ref.watch(localeProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Premium
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(child: child);
        },
        routes: [
          // Home / Prayer Times
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Qibla
          GoRoute(
            path: '/qibla',
            name: 'qibla',
            builder: (context, state) => const QiblaScreen(),
          ),

          // Quran
          GoRoute(
            path: '/quran',
            name: 'quran',
            builder: (context, state) => const QuranScreen(),
            routes: [
              GoRoute(
                path: 'surah/:id',
                name: 'surah',
                builder: (context, state) {
                  final surahId = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                  return SurahReaderScreen(surahId: surahId);
                },
              ),
              GoRoute(
                path: 'juz/:id',
                name: 'juz',
                builder: (context, state) {
                  final juzId = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                  return SurahReaderScreen(surahId: -juzId);
                },
              ),
              GoRoute(
                path: 'bookmarks',
                name: 'bookmarks',
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),

          // Learning
          GoRoute(
            path: '/learning',
            name: 'learning',
            builder: (context, state) => const LearningScreen(),
            routes: [
              GoRoute(
                path: 'duas',
                name: 'duas',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return DuasScreen(initialCategory: category);
                },
              ),
              GoRoute(
                path: 'names',
                name: 'names',
                builder: (context, state) => const NamesScreen(),
              ),
              GoRoute(
                path: 'islam101',
                name: 'islam101',
                builder: (context, state) => const Islam101Screen(),
              ),
              GoRoute(
                path: 'ayatul-kursi',
                name: 'ayatul-kursi',
                builder: (context, state) => const AyatulKursiScreen(),
              ),
              GoRoute(
                path: 'hadith',
                name: 'hadith',
                builder: (context, state) => const HadithScreen(),
              ),
              GoRoute(
                path: 'quiz',
                name: 'quiz',
                builder: (context, state) => const QuizScreen(),
              ),
              GoRoute(
                path: 'prayer-learning',
                name: 'prayer-learning',
                builder: (context, state) => const PrayerLearningScreen(),
              ),
              GoRoute(
                path: 'wudu-learning',
                name: 'wudu-learning',
                builder: (context, state) => const WuduLearningScreen(),
              ),
              GoRoute(
                path: 'tayammum-learning',
                name: 'tayammum-learning',
                builder: (context, state) => const TayammumLearningScreen(),
              ),
              GoRoute(
                path: 'first-30-days',
                name: 'first-30-days',
                builder: (context, state) => const First30DaysScreen(),
              ),
              GoRoute(
                path: 'arabic-alphabet',
                name: 'arabic-alphabet',
                builder: (context, state) => const ArabicAlphabetScreen(),
              ),
              GoRoute(
                path: 'tasbih',
                name: 'tasbih',
                builder: (context, state) => const TasbihScreen(),
              ),
              GoRoute(
                path: 'hijri-calendar',
                name: 'hijri-calendar',
                builder: (context, state) => const HijriCalendarScreen(),
              ),
              GoRoute(
                path: 'zakat-calculator',
                name: 'zakat-calculator',
                builder: (context, state) => const ZakatCalculatorScreen(),
              ),
            ],
          ),
          
          // Prayer Tracker
          GoRoute(
            path: '/prayer-tracker',
            name: 'prayer-tracker',
            builder: (context, state) => const PrayerTrackerScreen(),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'location',
                name: 'location-selection', // Used to be city-search
                builder: (context, state) => const LocationSelectionScreen(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'notification-settings',
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
              GoRoute(
                path: 'language',
                name: 'language',
                builder: (context, state) => const LanguageScreen(),
              ),
              GoRoute(
                path: 'quran',
                name: 'quran-settings',
                builder: (context, state) => const QuranSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Main shell with bottom navigation bar - Modern Material 3 Design
class _MainShell extends StatefulWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allow body to extend behind the navbar for glass effect
      body: widget.child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 1), // Space for border
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Stronger blur
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.black.withValues(alpha: 0.8) // High opacity to hide text behind
                    : Colors.white.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _calculateSelectedIndex(context),
                onDestinationSelected: (index) => _onItemTapped(index, context),
                elevation: 0,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Colors.transparent, // Minimalist: No big pill, maybe just icon color change?
                // The design shows "Active Nav" has font weight change.
                // NavigationBar enforces a pill usually.
                // Let's keep indicator transparent and use icon color
                
                height: 80,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                   _buildNavDestination(context, Icons.home_outlined, Icons.home, AppLocalizations.of(context)!.navHome),
                   _buildNavDestination(context, Icons.explore_outlined, Icons.explore, AppLocalizations.of(context)!.navQibla),
                   _buildNavDestination(context, Icons.menu_book_outlined, Icons.menu_book, AppLocalizations.of(context)!.navQuran),
                   _buildNavDestination(context, Icons.school_outlined, Icons.school, AppLocalizations.of(context)!.navLearn),
                   _buildNavDestination(context, Icons.settings_outlined, Icons.settings, AppLocalizations.of(context)!.navSettings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(BuildContext context, IconData icon, IconData selectedIcon, String label) {
      return NavigationDestination(
         icon: Icon(icon, size: 24),
         selectedIcon: Icon(selectedIcon), // Let Theme handle the color (White in Dark Mode)
         label: label,
      );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/qibla')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/learning')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/qibla');
        break;
      case 2:
        context.go('/quran');
        break;
      case 3:
        context.go('/learning');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
÷ ÷Å
Å¦& ¦&Ê&
Ê&Ì& Ì&ç&*cascade08
ç&è& è&ì&*cascade08
ì&í& í&ˆ'
ˆ'‰' ‰'Œ'*cascade08
Œ'˜' ˜'±'*cascade08
±'²' ²'Æ'
Æ'í* í*®,*cascade08
®,ÊP ÊPËP
ËPÌP ÌPÐP
ÐPÑP ÑPØP
ØP©Q ©QªQ
ªQ«Q «Q¯Q
¯Q°Q °Q·Q
·Q¸R ¸R¹R
¹RºR ºR¾R
¾R¿R ¿RÆR
ÆRÞR ÞRßR
ßRàR àRäR
äRåR åRìR
ìR h "(ad531abe872c7cf491ed881344a14c5a674c9d842Kfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/app/router.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life