˙ìimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:adhan_life/core/services/quran_service.dart';
import 'package:adhan_life/core/services/quran_audio_service.dart';
import 'package:adhan_life/data/models/surah.dart';
import 'package:adhan_life/core/services/bookmark_service.dart';
import '../widgets/verse_card.dart';

/// Surah Reader Screen - Displays surah content
class SurahReaderScreen extends ConsumerStatefulWidget {
  final int surahId;

  const SurahReaderScreen({
    super.key,
    required this.surahId,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showArabicOnly = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Get page range for a Juz (approximate Quran page numbers)
  String _getJuzPageRange(int juzNumber) {
    // Standard Quran page ranges for each Juz (Madina Mushaf)
    const juzPages = <int, List<int>>{
      1: [1, 21], 2: [22, 41], 3: [42, 61], 4: [62, 81], 5: [82, 101],
      6: [102, 121], 7: [122, 141], 8: [142, 161], 9: [162, 181], 10: [182, 201],
      11: [202, 221], 12: [222, 241], 13: [242, 261], 14: [262, 281], 15: [282, 301],
      16: [302, 321], 17: [322, 341], 18: [342, 361], 19: [362, 381], 20: [382, 401],
      21: [402, 421], 22: [422, 441], 23: [442, 461], 24: [462, 481], 25: [482, 501],
      26: [502, 521], 27: [522, 541], 28: [542, 561], 29: [562, 581], 30: [582, 604],
    };
    final range = juzPages[juzNumber] ?? [1, 20];
    return 'Pages ${range[0]} - ${range[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahProvider(widget.surahId));
    final translationCode = ref.watch(quranTranslationCodeProvider);

    return Scaffold(
      body: surahAsync.when(
        data: (surah) => _buildContent(surah, translationCode),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(Surah surah, String translationCode) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 16),
            title: LayoutBuilder(
              builder: (context, constraints) {
                // Only show title when collapsed (constraints.biggest.height is small)
                final isCollapsed = constraints.biggest.height <= 120;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Text(
                    surah.id < 0
                        ? AppLocalizations.of(context)!.juzTitle(-surah.id)
                        : surah.transliteration,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              },
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: surah.id > 0 ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppTokens.spacing16),
                        Text(
                          surah.name,
                          style: AppTypography.arabicDisplay.copyWith(
                            color: Colors.white,
                            fontSize: 40,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spacing12),
                        Text(
                          surah.transliteration,
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spacing8),
                        Text(
                          '${surah.translation} ‚Ä¢ ${surah.totalVerses} ${AppLocalizations.of(context)?.verse ?? "verses"}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ) : Column(
                      // Juz header info
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppTokens.spacing16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spacing12),
                        Text(
                          'Juz ${-surah.id}',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spacing8),
                        Text(
                          _getJuzPageRange(-surah.id),
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spacing4),
                        Text(
                          '${surah.totalVerses} ${AppLocalizations.of(context)?.verse ?? "verses"}',
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
          ),
          actions: [
            // Toggle Arabic only
            _buildHeaderIconButton(
              icon: _showArabicOnly ? Icons.translate : Icons.text_fields,
              onPressed: () {
                setState(() => _showArabicOnly = !_showArabicOnly);
              },
              tooltip: _showArabicOnly
                  ? AppLocalizations.of(context)!.showTranslation
                  : AppLocalizations.of(context)!.arabicOnly,
            ),
            const SizedBox(width: 4),
            // Translation picker
            _buildHeaderIconButton(
              icon: Icons.language,
              onPressed: _showTranslationPicker,
              tooltip: 'Translation',
            ),
            const SizedBox(width: 4),
            // More options
            _buildHeaderIconButton(
              icon: Icons.more_vert,
              onPressed: _showMoreOptions,
              tooltip: 'More',
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Bismillah (except for Surah 9)
        if (widget.surahId != 9)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppTokens.spacing24,
              ),
              child: Center(
                child: Text(
                  'ÿ®Ÿêÿ≥ŸíŸÖŸê ÿßŸÑŸÑŸéŸëŸáŸê ÿßŸÑÿ±ŸéŸëÿ≠ŸíŸÖŸéŸ∞ŸÜŸê ÿßŸÑÿ±ŸéŸëÿ≠ŸêŸäŸÖŸê',
                  style: AppTypography.arabicLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

        // Verses
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final verse = surah.verses[index];
              return Consumer(
                builder: (context, ref, _) {
                  final isBookmarked = ref.watch(isBookmarkedProvider((widget.surahId, verse.id)));
                  return VerseCard(
                    verse: verse,
                    showTranslation: !_showArabicOnly,
                    isBookmarked: isBookmarked,
                    onBookmark: () => _toggleBookmark(verse, surah),
                    onShare: () => _shareVerse(verse, surah),
                    onPlay: () => _playVerse(verse),
                  );
                },
              );
            },
            childCount: surah.verses.length,
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppTokens.spacing48),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppTokens.spacing16),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spacing24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(surahProvider(widget.surahId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(Verse verse, Surah surah) async {
    final service = ref.read(bookmarkServiceProvider);
    
    final bookmark = QuranBookmark(
      surahId: surah.id,
      verseId: verse.id,
      surahName: surah.transliteration, // Using transliteration as name (e.g. Al-Fatiha)
      verseText: verse.text,
      translation: verse.translation,
      createdAt: DateTime.now(),
    );

    await service.toggleBookmark(bookmark);
  }


  void _shareSurah(Surah surah) {
    final text = 'üìñ ${surah.transliteration} (${surah.name})\n'
        '${surah.verses.length} verses ‚Ä¢ ${surah.translation}\n\n'
        '‚Äî Shared via AdhanLife';
    Share.share(text, subject: 'Surah ${surah.transliteration}');
  }

  void _openSettings() {
    // TODO: Open reader settings
  }
  
  // This method is redundant but kept to avoid breaking other calls if any (like _showMoreOptions)
  void _bookmarkSurah(Surah surah) {
    // TODO: Implement whole surah bookmark logic or remove
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${surah.transliteration} bookmarked')),
    );
  }


  void _bookmarkVerse(Verse verse) {
     // Deprecated - replaced by _toggleBookmark
  }

  void _shareVerse(Verse verse, Surah surah) {
    final text = 'Ô¥æ ${verse.text} Ô¥ø\n\n'
        '${verse.translation}\n\n'
        '‚Äî ${surah.transliteration} (${surah.id}:${verse.id})\n'
        '‚Äî Shared via AdhanLife';
    Share.share(text, subject: '${surah.transliteration} ${verse.id}');
  }

  void _playVerse(Verse verse) {
    // Play verse audio using QuranAudioService
    final audioService = ref.read(quranAudioServiceProvider);
    audioService.playAyah(widget.surahId, verse.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing Ayah ${verse.id}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _showTranslationPicker() {
    final translationCode = ref.read(quranTranslationCodeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppTokens.spacing12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppTokens.borderRadiusFull,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing16),
                child: Text(
                  AppLocalizations.of(context)!.selectTranslation,
                  style: AppTypography.titleLarge,
                ),
              ),
              const SizedBox(height: AppTokens.spacing16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: availableTranslations.entries.map((entry) {
                    final isSelected = entry.key == translationCode;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        child: Text(
                          entry.value.language.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(entry.value.language),
                      subtitle: Text(entry.value.author),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(quranTranslationCodeProvider.notifier).setCode(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    final surahAsync = ref.read(surahProvider(widget.surahId));
    surahAsync.whenData((surah) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(AppTokens.spacing16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppTokens.spacing16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppTokens.borderRadiusFull,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Bookmark'),
                onTap: () {
                  Navigator.pop(context);
                  _bookmarkSurah(surah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareSurah(surah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                },
              ),
              const SizedBox(height: AppTokens.spacing16),
            ],
          ),
        ),
      );
    });
  }
}
Ê	 Ê	£*cascade08
£ò+ ò+ù+*cascade08
ù+û+ û+ª+
ª+º+ º+Í+
Í+Î+ Î+˝+*cascade08
˝+˛+ ˛+ô:*cascade08
ô:∞i ∞i±i*cascade08
±i≤i ≤i∂i*cascade08
∂i∑i ∑iæi*cascade08
æi•j •j¶j*cascade08
¶jßj ßj´j*cascade08
´j¨j ¨j≥j*cascade08≥j˙ì "(ad531abe872c7cf491ed881344a14c5a674c9d842xfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/quran/presentation/screens/surah_reader_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life