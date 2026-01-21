�%import 'package:flutter/material.dart';

class AppColors {
  // Sunrise Serenity Ana Paleti
  static const Color primary = Color(0xFFE07A5F); // Soft Terracotta (Vurgu rengi)
  static const Color primaryDark = Color(0xFFC9654D);
  static const Color primaryLight = Color(0xFFF2CC8F); // Sun yellow/orange
  static const Color primaryContainer = primaryLight; 
  
  static const Color secondary = Color(0xFF3D405B); // Deep Teal (Metin ve ikonlar için)
  static const Color background = Color(0xFFF4F1DE); // Sandy Beige (Arka plan)
  
  // Kartlar ve Yüzeyler
  static const Color surface = Colors.white;
  static const Color surfaceTeal = Color(0xFF3D405B); // Günün Ayeti gibi özel kartlar için
  static const Color surfaceVariant = Color(0xFFF4F1DE);
  static const Color surfaceVariantDark = Color(0xFF3D405B);

  // Namaz Vakitleri Durum Renkleri
  static const Color indicatorPassed = Color(0xFFBDBDBD); // Geçmiş vakitler için gri
  static const Color indicatorActive = Color(0xFFE07A5F); // Aktif vakit için Terracotta
  static const Color indicatorFuture = Color(0xFF81B29A); // Gelecek vakitler için yumuşak yeşil/adaçayı
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF3D405B); // Koyu Teal
  static const Color textSecondary = Color(0xFF5F797B); // Yardımcı metinler
  static const Color textTertiary = Color(0xFF9E9E9E);

  static const Color textOnDark = Colors.white;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDarkSecondary = Color(0xFFBDBDBD);

  // Gradyanlar
  static const Gradient sunriseGradient = LinearGradient(
    colors: [Color(0xFFF2CC8F), Color(0xFFE07A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient primaryGradient = sunriseGradient;

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Functional Colors
  static const Color error = Color(0xFFE63946); // Red
  static const Color success = Color(0xFF81B29A); // Soft Green
  static const Color warning = Color(0xFFF2CC8F); 

  static const Color divider = Color(0xFFEAEAEA);
  static const Color dividerDark = Color(0xFF424242);
  
  // Scaffold Backgrounds
  static const Color scaffoldBackground = background;
  static const Color scaffoldBackgroundDark = Color(0xFF1E1E1E); // Dark Grey for Dark Mode

  // Compatibility / Legacy Support
  static const Color charcoal = secondary;
  static const Color backgroundLight = background;
  static const Color backgroundDark = secondary; // Restored for compatibility
  static const Color surfaceLight = surface;
  static const Color surfaceDark = secondary; // Restored for compatibility
  static const Color gold = Color(0xFFF2CC8F);
  static const Color info = Color(0xFF3D405B); 
  static const Color skyBlue = Color(0xFF81B29A);

  // Legacy Aliases for Compatibility
  static const Color deepBlue = secondary; 
  static const Color goldLight = primaryLight; 
  static const Color goldDark = primaryDark;
  
  static const Color turquoise = Color(0xFF81B29A); // Mapped to indicatorFuture
  static const Color amber = primaryLight; // Mapped to Sun Yellow
  static const Color successLight = success;
  static const Color warningLight = warning;

  // Prayer Times Colors (Mapped to Primary/Sunrise for consistency)
  static const Map<String, ColorScheme> prayerColorSchemes = {
    'fajr': ColorScheme.light(primary: primary, secondary: primaryLight),
    'sunrise': ColorScheme.light(primary: primary, secondary: primaryLight),
    'dhuhr': ColorScheme.light(primary: primary, secondary: primaryLight),
    'asr': ColorScheme.light(primary: primary, secondary: primaryLight),
    'maghrib': ColorScheme.light(primary: primary, secondary: primaryLight),
    'isha': ColorScheme.light(primary: primary, secondary: primaryLight),
  };
  
  // Prayer Colors (Static for legacy support)
  static const Color fajr = primary;
  static const Color sunrise = primary;
  static const Color dhuhr = primary;
  static const Color asr = primary;
  static const Color maghrib = primary;
  static const Color isha = primary;

  // Specific UI Elements
  static const Color compassBorder = Color(0x1A3D405B); // teal/10
  static const Color compassBorderDark = Color(0x1AFFFFFF); // white/10
  static const Color compassText = Color(0x663D405B); // teal/40
  static const Color compassTextDark = Color(0x66FFFFFF); // white/40

  static Color getPrayerTextColor(String prayerName, Brightness brightness) {
      return brightness == Brightness.dark ? textOnDark : textPrimary;
  }

  static Gradient getPrayerGradient(String prayerName) {
      return sunriseGradient;
  }
}
� ��*cascade08
��% "(ad531abe872c7cf491ed881344a14c5a674c9d842Vfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/theme/app_colors.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life