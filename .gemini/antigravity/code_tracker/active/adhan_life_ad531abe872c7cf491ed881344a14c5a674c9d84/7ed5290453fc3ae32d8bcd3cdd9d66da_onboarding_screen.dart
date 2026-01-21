¸_import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';
import 'package:adhan_life/core/services/permission_service.dart';
import 'package:adhan_life/app/providers.dart';
import 'package:permission_handler/permission_handler.dart';

/// Onboarding Screen - Welcome flow for new users
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final PermissionService _permissionService = PermissionService();

  // Permission states
  bool _notificationGranted = false;
  bool _locationGranted = false;
  bool _exactAlarmGranted = false;

  List<_OnboardingPage> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // Welcome Page
      _OnboardingPage(
        icon: Icons.mosque,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        color: AppColors.primary,
        pageType: _PageType.welcome,
      ),
      // Location Permission Page
      _OnboardingPage(
        icon: Icons.location_on,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        color: AppColors.turquoise,
        pageType: _PageType.locationPermission,
      ),
      // Notification Permission Page (Android 13+)
      _OnboardingPage(
        icon: Icons.notifications_active,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        color: AppColors.amber,
        pageType: _PageType.notificationPermission,
      ),
      // Exact Alarm Permission Page (Android 12+)
      _OnboardingPage(
        icon: Icons.alarm,
        title: l10n.onboardingExactAlarmTitle,
        description: l10n.onboardingExactAlarmDesc,
        color: AppColors.primaryLight,
        pageType: _PageType.exactAlarmPermission,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    final pages = _getPages(context);
    final currentPageType = pages[_currentPage].pageType;

    // Handle permission pages
    if (currentPageType == _PageType.notificationPermission) {
      await _requestNotificationPermission();
    } else if (currentPageType == _PageType.locationPermission) {
      await _requestLocationPermission();
    } else if (currentPageType == _PageType.exactAlarmPermission) {
      await _requestExactAlarmPermission();
    }

    // Navigate to next page or complete
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: AppTokens.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await _permissionService.requestNotificationPermission();
    setState(() {
      _notificationGranted = status == PermissionStatus.granted;
    });

    if (status == PermissionStatus.permanentlyDenied && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final shouldOpenSettings = await _permissionService.showPermissionRationale(
        context,
        title: l10n.permissionNotificationTitle,
        message: l10n.permissionNotificationMessage,
        positiveButton: l10n.btnOpenSettings,
        negativeButton: l10n.btnSkipPermission,
      );

      if (shouldOpenSettings == true) {
        await _permissionService.openAppSettings();
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await _permissionService.requestLocationPermission();
    setState(() {
      _locationGranted = status == PermissionStatus.granted;
    });

    if (status == PermissionStatus.permanentlyDenied && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final shouldOpenSettings = await _permissionService.showPermissionRationale(
        context,
        title: l10n.permissionLocationTitle,
        message: l10n.permissionLocationMessage,
        positiveButton: l10n.btnOpenSettings,
        negativeButton: l10n.btnSkipPermission,
      );

      if (shouldOpenSettings == true) {
        await _permissionService.openAppSettings();
      }
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    final isGranted = await _permissionService.requestExactAlarmPermission();
    setState(() {
      _exactAlarmGranted = isGranted;
    });

    if (!isGranted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final shouldOpenSettings = await _permissionService.showPermissionRationale(
        context,
        title: l10n.permissionExactAlarmTitle,
        message: l10n.permissionExactAlarmMessage,
        positiveButton: l10n.btnOpenSettings,
        negativeButton: l10n.btnSkipPermission,
      );

      if (shouldOpenSettings == true) {
        await _permissionService.openAppSettings();
      }
    }
  }

  void _completeOnboarding() {
    // Save onboarding completed state
    ref.read(storageServiceProvider).setOnboardingCompleted(true);
    // Navigate to home using GoRouter
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.spacing16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    l10n.btnSkip,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return _buildPage(page);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.spacing24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  return AnimatedContainer(
                    duration: AppTokens.animFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: AppTokens.borderRadiusFull,
                    ),
                  );
                }),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(AppTokens.spacing24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == pages.length - 1 ? l10n.btnGetStarted : l10n.btnNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: AppTokens.spacing48),

          // Title
          Text(
            page.title,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spacing16),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Permission Status Indicator
          if (page.pageType != _PageType.welcome) ...[
            const SizedBox(height: AppTokens.spacing24),
            _buildPermissionStatus(page.pageType),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionStatus(_PageType pageType) {
    final l10n = AppLocalizations.of(context)!;
    bool isGranted = false;
    String statusText = l10n.permissionNotGranted;

    switch (pageType) {
      case _PageType.notificationPermission:
        isGranted = _notificationGranted;
        statusText = _notificationGranted ? l10n.permissionGranted : l10n.permissionNotGranted;
        break;
      case _PageType.locationPermission:
        isGranted = _locationGranted;
        statusText = _locationGranted ? l10n.permissionGranted : l10n.permissionNotGranted;
        break;
      case _PageType.exactAlarmPermission:
        isGranted = _exactAlarmGranted;
        statusText = _exactAlarmGranted ? l10n.permissionGranted : l10n.permissionNotGranted;
        break;
      case _PageType.welcome:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing16,
        vertical: AppTokens.spacing8,
      ),
      decoration: BoxDecoration(
        color: isGranted
            ? AppColors.successLight
            : AppColors.warningLight,
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.info_outline,
            size: 18,
            color: isGranted ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: AppTypography.labelMedium.copyWith(
              color: isGranted ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PageType {
  welcome,
  locationPermission,
  notificationPermission,
  exactAlarmPermission,
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final _PageType pageType;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.pageType,
  });
}
¸_"(ad531abe872c7cf491ed881344a14c5a674c9d842{file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/onboarding/presentation/screens/onboarding_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life