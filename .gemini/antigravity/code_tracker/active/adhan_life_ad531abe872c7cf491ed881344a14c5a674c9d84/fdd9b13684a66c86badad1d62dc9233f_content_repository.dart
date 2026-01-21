É9import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository for loading static content (Hadiths, Rules, Duas)
class ContentRepository {
  
  /// Load Hadiths
  Future<List<HadithModel>> loadHadiths() async {
    try {
      final String response = await rootBundle.loadString('assets/data/hadiths.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => HadithModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback or error handling
      return [];
    }
  }

  /// Load Islam 101 Modules
  Future<List<Islam101Module>> loadIslam101Modules() async {
    try {
      final String response = await rootBundle.loadString('assets/data/islam101.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Islam101Module.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  /// Load 99 Names of Allah
  Future<List<AllahName>> loadNames() async {
    try {
      final String response = await rootBundle.loadString('assets/data/names.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => AllahName.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Load Duas
  Future<List<DuaModel>> loadDuas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/duas.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => DuaModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Models

class AllahName {
  final int id;
  final String arabic;
  final String transliteration;
  final Map<String, String> meanings;
  final String? description;

  AllahName({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meanings,
    this.description,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    // Handle both old 'meaning' (String) and new 'meanings' (Map) formats
    Map<String, String> parsedMeanings = {};
    if (json['meanings'] != null) {
      parsedMeanings = Map<String, String>.from(json['meanings']);
    } else if (json['meaning'] != null) {
      parsedMeanings = {'en': json['meaning']};
    }

    return AllahName(
      id: json['id'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      meanings: parsedMeanings,
      description: json['description'], // Can be null
    );
  }

  String getMeaning(String languageCode) {
    return meanings[languageCode] ?? meanings['en'] ?? meanings.values.firstOrNull ?? '';
  }
}

class DuaModel {
  final int id;
  final String category;
  final String arabic;
  final String transliteration;
  final Map<String, String> translations;
  final String reference;

  DuaModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translations,
    required this.reference,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'],
      category: json['category'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translations: Map<String, String>.from(json['translations']),
      reference: json['reference'],
    );
  }

  String getTranslation(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? translations.values.first;
  }
}

class HadithModel {
  final int id;
  final String arabic;
  final Map<String, String> translations;
  final String narrator;
  final String source;
  final int number;
  final String grade;

  HadithModel({
    required this.id,
    required this.arabic,
    required this.translations,
    required this.narrator,
    required this.source,
    required this.number,
    required this.grade,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'],
      arabic: json['arabic'],
      translations: Map<String, String>.from(json['translations']),
      narrator: json['narrator'],
      source: json['source'],
      number: json['number'],
      grade: json['grade'],
    );
  }

  String getTranslation(String languageCode) {
    // Try specific language, fallback to English, then first available
    return translations[languageCode] ?? translations['en'] ?? translations.values.first;
  }
}

class Islam101Module {
  final String id;
  final String iconName;
  final int lessonsCount;
  final String duration;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<Islam101Lesson> lessons;

  Islam101Module({
    required this.id,
    required this.iconName,
    required this.lessonsCount,
    required this.duration,
    required this.title,
    required this.description,
    required this.lessons,
  });

  factory Islam101Module.fromJson(Map<String, dynamic> json) {
    final lessonsList = (json['lessons'] as List<dynamic>?)
        ?.map((l) => Islam101Lesson.fromJson(l))
        .toList() ?? [];
    
    return Islam101Module(
      id: json['id'],
      iconName: json['icon'],
      lessonsCount: json['lessons_count'],
      duration: json['duration'],
      title: Map<String, String>.from(json['title']),
      description: Map<String, String>.from(json['description']),
      lessons: lessonsList,
    );
  }

  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? '';
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['en'] ?? '';
  }
}

/// Lesson within an Islam101 module
class Islam101Lesson {
  final String id;
  final Map<String, String> title;
  final Map<String, String> content;

  Islam101Lesson({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Islam101Lesson.fromJson(Map<String, dynamic> json) {
    return Islam101Lesson(
      id: json['id'],
      title: Map<String, String>.from(json['title']),
      content: Map<String, String>.from(json['content']),
    );
  }

  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? '';
  }

  String getContent(String languageCode) {
    return content[languageCode] ?? content['en'] ?? '';
  }
}

/// Provider
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final hadithsProvider = FutureProvider<List<HadithModel>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadHadiths();
});

final islam101Provider = FutureProvider<List<Islam101Module>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadIslam101Modules();
});

final namesProvider = FutureProvider<List<AllahName>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadNames();
});

final duasProvider = FutureProvider<List<DuaModel>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.loadDuas();
});
É9*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842efile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/repositories/content_repository.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life