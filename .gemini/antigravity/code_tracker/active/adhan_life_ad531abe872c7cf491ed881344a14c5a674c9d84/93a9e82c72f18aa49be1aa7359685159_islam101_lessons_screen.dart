ü1import 'package:flutter/material.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/core/repositories/content_repository.dart';

/// Islam 101 Lessons Screen - Shows lessons within a module
class Islam101LessonsScreen extends StatefulWidget {
  final Islam101Module module;

  const Islam101LessonsScreen({super.key, required this.module});

  @override
  State<Islam101LessonsScreen> createState() => _Islam101LessonsScreenState();
}

class _Islam101LessonsScreenState extends State<Islam101LessonsScreen> {
  int _currentLessonIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final lessons = widget.module.lessons;

    if (lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.module.getTitle(locale)),
        ),
        body: const Center(
          child: Text('No lessons available for this module.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.getTitle(locale)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentLessonIndex + 1}/${lessons.length}',
                style: AppTypography.titleSmall,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: ((_currentLessonIndex + 1) / lessons.length),
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Lesson content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: lessons.length,
              onPageChanged: (index) {
                setState(() {
                  _currentLessonIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return _LessonContent(
                  lesson: lesson,
                  languageCode: locale,
                );
              },
            ),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacing16),
              child: Row(
                children: [
                  if (_currentLessonIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: AppTokens.spacing16),
                  Expanded(
                    child: _currentLessonIndex < lessons.length - 1
                        ? FilledButton.icon(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          )
                        : FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Completed: ${widget.module.getTitle(locale)}'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Complete'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonContent extends StatelessWidget {
  final Islam101Lesson lesson;
  final String languageCode;

  const _LessonContent({
    required this.lesson,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson title
          Text(
            lesson.getTitle(languageCode),
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppTokens.spacing16),
          
          // Divider
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTokens.spacing24),

          // Lesson content
          Text(
            lesson.getContent(languageCode),
            style: AppTypography.bodyLarge.copyWith(
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppTokens.spacing32),
        ],
      ),
    );
  }
}
ü1*cascade08"(ad531abe872c7cf491ed881344a14c5a674c9d842file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/islam101_lessons_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life