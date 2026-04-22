import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe/core/helpers/navigation/extensions.dart';
import 'package:vibe/core/helpers/navigation/router/app_router_path.dart';
import '../../../../../core/cache/vibe_cache.dart';
import '../../../../../core/theme/vibe_theme.dart';
import '../../../../core/global_widgets/vibe_widgets.dart';
import '../../data/models/onboarding_data_model.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = OnboardingPageData.pages;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await VibeCache.instance.markOnboardingDone();
    if (mounted) {
      context.pushReplacementNamed(AppRoutes.bottomNavBar);
    }
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _pages[_currentPage].accentColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Pages
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, index) => OnboardingPageWidget(
                data: _pages[index],
                isActive: index == _currentPage,
              ),
            ),
            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _OnboardingControls(
                accentColor: accentColor,
                currentPage: _currentPage,
                pageCount: _pages.length,
                isLastPage: _isLastPage,
                onNext: _next,
                onSkip: _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingControls extends StatelessWidget {
  const _OnboardingControls({
    required this.accentColor,
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
  });

  final Color accentColor;
  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: VibeSpacing.xl,
        right: VibeSpacing.xl,
        bottom: MediaQuery.of(context).padding.bottom + VibeSpacing.lg,
        top: VibeSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingDotIndicator(
            count: pageCount,
            currentIndex: currentPage,
            accentColor: accentColor,
          ),
          const SizedBox(height: VibeSpacing.lg),
          VibePrimaryButton(
            label: isLastPage ? 'ابدأ الآن' : 'التالي',
            onPressed: onNext,
            icon: isLastPage ? null : Icons.arrow_forward_ios_rounded,
          ),
          const SizedBox(height: VibeSpacing.md),
          if (!isLastPage)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'تخطي',
                style: VibeTypography.bodyMedium.copyWith(
                  color: VibeColors.textMuted,
                  decoration: TextDecoration.underline,
                  decorationColor: VibeColors.textMuted,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
