ÉIimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/services/quran_service.dart';
import 'package:adhan_life/data/models/surah.dart';
import '../widgets/surah_list_tile.dart';

/// Quran Screen - List of surahs
class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahListAsync = ref.watch(surahListProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 180,
              title: const Text('Quran'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () => context.pushNamed('bookmarks'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 56), // Space for title
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.spacing16,
                          vertical: AppTokens.spacing8,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search surah...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),
                      // Tabs
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Surah'),
                          Tab(text: 'Juz'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Surah list
            surahListAsync.when(
              data: (surahList) => _buildSurahList(surahList),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => _buildError(error.toString()),
            ),

            // Juz list (placeholder)
            _buildJuzList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList(List<SurahInfo> surahList) {
    final filteredList = _searchQuery.isEmpty
        ? surahList
        : surahList.where((surah) {
            final query = _searchQuery.toLowerCase();
            return surah.name.toLowerCase().contains(query) ||
                surah.transliteration.toLowerCase().contains(query) ||
                surah.translation.toLowerCase().contains(query) ||
                surah.id.toString().contains(query);
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppTokens.spacing16),
            Text(
              'No surah found',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.spacing8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final surah = filteredList[index];
        return SurahListTile(
          surah: surah,
          onTap: () {
            context.push('/quran/surah/${surah.id}');
          },
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTokens.spacing16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return Card(
          margin: const EdgeInsets.only(bottom: AppTokens.spacing8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$juzNumber',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            title: Text('Juz $juzNumber'),
            subtitle: Text(_getJuzName(juzNumber)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to juz using negative ID convention
              context.push('/quran/surah/${-juzNumber}');
            },
          ),
        );
      },
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
                ref.invalidate(surahListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _getJuzName(int juz) {
    const juzNames = [
      'Alif Lam Mim',
      'Sayaqul',
      'Tilka r-Rusul',
      'Lan Tana Lu',
      "Wal Muhsanat",
      "La Yuhibbullah",
      "Wa Idha Sami'u",
      "Wa Lau Annana",
      "Qalal Mala'u",
      "Wa'lamu",
      "Ya'tadhirun",
      "Wa Ma Min Dabbah",
      "Wa Ma Ubarri'u",
      "Rubama",
      "Subhan Alladhi",
      "Qal Alam",
      "Iqtaraba",
      "Qad Aflaha",
      "Wa Qalal Ladhina",
      "Amman Khalaqa",
      "Utlu Ma Uhiya",
      "Wa Man Yaqnut",
      "Wa Mali",
      "Faman Azhlamu",
      "Ilayhi Yuraddu",
      "Ha Mim",
      "Qala Fama Khatbukum",
      "Qad Sami'a",
      "Tabaraka Alladhi",
      "Amma Yatasa'alun",
    ];
    return juz <= juzNames.length ? juzNames[juz - 1] : '';
  }
}
s sü
ü“ “’*cascade08
’Ô ÔÛ*cascade08
Ûã ãé*cascade08
é± ±≤*cascade08
≤ﬁ ﬁº*cascade08
ºø ø¡*cascade08
¡¬ ¬∆*cascade08
∆ﬁ ﬁÂ*cascade08
Âú úü*cascade08
üØ Ø¥*cascade08
¥√ √ *cascade08
 ‹ ‹›*cascade08
›Ñ Ñå*cascade08
åü ü¢*cascade08
¢≤ ≤∑*cascade08
∑∏ ∏î *cascade08
î Û/ Û/˘/*cascade08
˘/±9 ±9â:*cascade08
â:ÉI "(ad531abe872c7cf491ed881344a14c5a674c9d842qfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/quran/presentation/screens/quran_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life