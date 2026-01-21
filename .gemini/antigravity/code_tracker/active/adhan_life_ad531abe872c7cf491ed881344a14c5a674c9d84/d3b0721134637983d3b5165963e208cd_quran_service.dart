�Rimport 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran_lib;
import '../../data/models/surah.dart';
import '../../features/quran/data/datasources/quran_local_data_source.dart';
import '../../features/quran/data/datasources/quran_search_index.dart';
import '../../app/providers.dart';

/// Available Quran translations
const availableTranslations = {
  'en': QuranTranslation(code: 'en', name: 'English', author: 'Sahih International', language: 'English'),
  'de': QuranTranslation(code: 'de', name: 'German', author: 'Abu Rida Muhammad', language: 'Deutsch'),
  'fr': QuranTranslation(code: 'fr', name: 'French', author: 'Muhammad Hamidullah', language: 'Français'),
  'es': QuranTranslation(code: 'es', name: 'Spanish', author: 'Julio Cortes', language: 'Español'),
  'nl': QuranTranslation(code: 'nl', name: 'Dutch', author: 'Fred Leemhuis', language: 'Nederlands'),
  'sv': QuranTranslation(code: 'sv', name: 'Swedish', author: 'Knut Bernström', language: 'Svenska'),
  'no': QuranTranslation(code: 'no', name: 'Norwegian', author: 'Einar Berg', language: 'Norsk'),
  'da': QuranTranslation(code: 'da', name: 'Danish', author: 'Hadi Abdollahian', language: 'Dansk'),
  'pt': QuranTranslation(code: 'pt', name: 'Portuguese', author: 'Samir El-Hayek', language: 'Português'),
  'it': QuranTranslation(code: 'it', name: 'Italian', author: 'Hamza Piccardo', language: 'Italiano'),
  'pl': QuranTranslation(code: 'pl', name: 'Polish', author: 'Józef Bielawski', language: 'Polski'),
  'fi': QuranTranslation(code: 'fi', name: 'Finnish', author: 'Finnish Translation', language: 'Suomi'),
  'ru': QuranTranslation(code: 'ru', name: 'Russian', author: 'Elmir Kuliev', language: 'Русский'),
  'tr': QuranTranslation(code: 'tr', name: 'Turkish', author: 'Diyanet İşleri', language: 'Türkçe'),
};

/// Quran Service for loading and managing Quran data
class QuranService {
  List<SurahInfo>? _surahList;
  final QuranLocalDataSource _dataSource;
  final QuranSearchIndex _searchIndex = QuranSearchIndex();

  QuranService(this._dataSource);

  /// Load surah list from metadata file
  Future<List<SurahInfo>> getSurahList() async {
    if (_surahList != null) return _surahList!;

    try {
      final jsonString = await rootBundle.loadString('assets/quran/surahs.json');
      final data = json.decode(jsonString);
      
      // Handle AlQuran API structure {"data": [...]}
      final List<dynamic> jsonList = data is Map && data.containsKey('data') 
          ? data['data'] 
          : data; // Fallback if direct list

      _surahList = jsonList.map((json) {
        return SurahInfo(
          id: json['number'] as int,
          name: json['name'] as String,
          transliteration: json['englishName'] as String,
          translation: json['englishNameTranslation'] as String,
          type: json['revelationType'] as String,
          totalVerses: json['numberOfAyahs'] as int,
        );
      }).toList();

      return _surahList!;
    } catch (e) {
      print('Failed to load surah list: $e');
      throw Exception('Failed to load surah list'); // Basic error handling
    }
  }

  /// Load a specific surah with verses
  Future<Surah> getSurah(int surahId, {String translationCode = 'en'}) async {
    try {
      final surahList = await getSurahList();
      final info = surahList.firstWhere(
        (s) => s.id == surahId,
        orElse: () => throw Exception('Surah $surahId not found'),
      );
      
      final verses = await _dataSource.getVersesForSurah(surahId, translationCode);
      
      return Surah(
        id: info.id,
        name: info.name,
        transliteration: info.transliteration,
        translation: info.translation,
        type: info.type,
        totalVerses: info.totalVerses,
        verses: verses,
      );
    } catch (e) {
      print('Failed to load surah $surahId: $e');
      throw Exception('Failed to load surah');
    }
  }

  /// Search verses by text
  Future<List<Verse>> searchVerses(String query, {String? translationCode}) async {
    if (query.trim().isEmpty) return [];

    // Build index if not already built
    if (!_searchIndex.isIndexed) {
      await _buildSearchIndex(translationCode ?? 'en');
    }

    // Perform search
    final matches = _searchIndex.searchCombined(query);

    // Convert SearchMatch to Verse objects
    return matches.map((match) {
      return Verse(
        id: match.verseId,
        text: match.arabicText,
        translation: match.translation,
        surahId: match.surahId,
      );
    }).toList();
  }

  /// Build search index for all verses
  Future<void> _buildSearchIndex(String translationCode) async {
    try {
      // Load all verses from all surahs
      final surahList = await getSurahList();
      final allVerses = <Verse>[];
      final surahNames = <int, String>{};

      // Load verses from all 114 surahs
      for (final surahInfo in surahList) {
        final verses = await _dataSource.getVersesForSurah(
          surahInfo.id,
          translationCode,
        );
        allVerses.addAll(verses);
        surahNames[surahInfo.id] = surahInfo.transliteration;
      }

      // Build the index
      await _searchIndex.buildIndex(allVerses, surahNames);
    } catch (e) {
      print('Failed to build search index: $e');
    }
  }

  /// Clear search index (useful for language change or memory management)
  void clearSearchIndex() {
    _searchIndex.clearIndex();
  }

  /// Get search index statistics
  Map<String, dynamic> getSearchIndexStats() {
    return _searchIndex.getIndexStats();
  }

  /// Get Juz content as a (fake) Surah object
  Future<Surah> getJuz(int juzNumber, {String translationCode = 'en'}) async {
    try {
      final Map<int, List<int>> surahAndVerses = quran_lib.getSurahAndVersesFromJuz(juzNumber);
      final List<Verse> allVerses = [];

      for (final entry in surahAndVerses.entries) {
        final surahId = entry.key;
        final range = entry.value; // [start, end]
        final start = range[0];
        final end = range[1];

        final verses = await _dataSource.getVersesRange(surahId, start, end, translationCode);
        allVerses.addAll(verses);
      }

      return Surah(
        id: -juzNumber, // Negative ID marks it as a Juz
        name: 'Juz $juzNumber',
        transliteration: 'Juz $juzNumber', 
        translation: '',
        type: '', // Meccan/Medinan not applicable
        totalVerses: allVerses.length,
        verses: allVerses,
      );
    } catch (e) {
      print('Failed to load juz $juzNumber: $e');
      throw Exception('Failed to load juz');
    }
  }
  /// Get a random verse for the "Daily Verse" feature.
  /// Uses a seed based on the current date so it stays constant for the day.
  Future<DailyVerse> getDailyVerse({String translationCode = 'en'}) async {
    try {
      final surahList = await getSurahList();
      if (surahList.isEmpty) throw Exception('Surah list empty');

      // Use current time with microseconds for unique verse on each refresh
      final now = DateTime.now();
      final seed = now.microsecondsSinceEpoch;
      
      // Random Surah (1-114) and verse
      // Find which surah this absolute index belongs to
      // (This is an approximation, or we can just pick a random surah based on day)
      // Let's pick a random Surah based on day, then random verse within it.
      
      final surahId = (seed % 114) + 1;
      final targetSurah = surahList.firstWhere((s) => s.id == surahId);
      
      // Random verse in this surah
      final verseNum = (seed % targetSurah.totalVerses) + 1;
      
      final surah = await getSurah(surahId, translationCode: translationCode);
      final verse = surah.verses.firstWhere((v) => v.id == verseNum);
      
      return DailyVerse(
        surahName: targetSurah.transliteration,
        surahNumber: targetSurah.id,
        verseNumber: verse.id,
        text: verse.text,
        translation: verse.translation ?? '',
      );
    } catch (e) {
      print('Failed to get daily verse: $e');
      // Fallback
      return DailyVerse(
        surahName: 'Ash-Sharh',
        surahNumber: 94,
        verseNumber: 6,
        text: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        translation: 'Indeed, with hardship comes ease.',
      );
    }
  }
}

class DailyVerse {
  final String surahName;
  final int surahNumber;
  final int verseNumber;
  final String text;
  final String translation;

  DailyVerse({
    required this.surahName,
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
    required this.translation,
  });
}

/// Provider for QuranService
final quranServiceProvider = Provider<QuranService>((ref) {
  final dataSource = ref.watch(quranDataSourceProvider);
  return QuranService(dataSource);
});

/// Provider for surah list
final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final service = ref.watch(quranServiceProvider);
  return await service.getSurahList();
});

/// Quran translation code notifier
class QuranTranslationCodeNotifier extends Notifier<String> {
  @override
  String build() {
    final locale = ref.watch(localeProvider);
    return locale?.languageCode ?? 'en';
  }

  void setCode(String code) => state = code;
}

/// Provider for current translation code
final quranTranslationCodeProvider = NotifierProvider<QuranTranslationCodeNotifier, String>(
  QuranTranslationCodeNotifier.new,
);

/// Provider for a specific surah or juz (negative ID)
final surahProvider = FutureProvider.family<Surah, int>((ref, id) async {
  final service = ref.watch(quranServiceProvider);
  final translationCode = ref.watch(quranTranslationCodeProvider);
  
  if (id > 0) {
    return await service.getSurah(id, translationCode: translationCode);
  } else {
    // Handle Juz: id = -JuzNumber (e.g. -1 for Juz 1)
    return await service.getJuz(-id, translationCode: translationCode);
  }
});

/// Provider for daily verse
final dailyVerseProvider = FutureProvider<DailyVerse>((ref) async {
  final service = ref.watch(quranServiceProvider);
  final translationCode = ref.watch(quranTranslationCodeProvider);
  return await service.getDailyVerse(translationCode: translationCode);
});
�R*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842\file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/services/quran_service.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life