ÅCimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/repositories/content_repository.dart';
import 'package:adhan_life/data/models/dua.dart';

/// Duas Screen - Collection of Islamic supplications
class DuasScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  
  const DuasScreen({super.key, this.initialCategory});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  DuaCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    // Set initial category from parameter
    if (widget.initialCategory != null) {
      _selectedCategory = DuaCategory.values.where(
        (c) => c.name.toLowerCase() == widget.initialCategory!.toLowerCase()
      ).firstOrNull;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duas & Supplications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Show favorites filter (simple toggle for now)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Favorites filter coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),

          // Duas list
          Expanded(
            child: _buildDuasList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing12),
        children: [
          _buildCategoryChip(null, 'All'),
          ...DuaCategory.values.map((category) {
            return _buildCategoryChip(category, category.displayName);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(DuaCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDuasList() {
    final duasAsync = ref.watch(duasProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return duasAsync.when(
      data: (allDuas) {
        final filteredDuas = _selectedCategory == null
            ? allDuas
            : allDuas.where((d) => d.category == _selectedCategory?.name).toList(); // Changed logic as API might return String category

        if (filteredDuas.isEmpty) {
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
                  'No duas in this category',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTokens.spacing16),
          itemCount: filteredDuas.length,
          itemBuilder: (context, index) {
            final dua = filteredDuas[index];
            return _DuaCard(dua: dua, locale: locale); // Pass locale
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

}

class _DuaCard extends StatelessWidget {
  final DuaModel dua;
  final String locale;

  const _DuaCard({required this.dua, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacing8,
                    vertical: AppTokens.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: Text(
                    dua.category.toUpperCase(), // Display category name directly
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: AppColors.textSecondary),
                  iconSize: 20,
                  onPressed: () {
                    // Favorites feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to favorites!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  iconSize: 20,
                  color: AppColors.textSecondary,
                  onPressed: () {
                    // Audio playback feedback (requires audio assets)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Audio playback requires audio assets'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing12),

            // Arabic text
            Text(
              dua.arabic,
              style: AppTypography.arabicLarge.copyWith(
                color: isDark ? AppColors.gold : AppColors.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppTokens.spacing12),

            // Transliteration
            Text(
              dua.transliteration,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spacing12),

            // Translation
            Text(
              dua.getTranslation(locale),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spacing8),

            // Reference
            Text(
              dua.reference,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
˚ ˚°*cascade08
°ª ª—*cascade08
—ä ä≈*cascade08
≈ÅC "(ad531abe872c7cf491ed881344a14c5a674c9d842sfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/duas_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life