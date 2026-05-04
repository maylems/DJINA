// presentation/pages/onboarding_screens.dart
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:djina_debug/src/onboarding/presentation/widgets/widgets.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens>
    with TickerProviderStateMixin {
  late OnboardingProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = OnboardingProvider();
    _provider.initializeAnimations(this);
  }

  @override
  void dispose() {
    _provider.disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryColor,
        body: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return OnboardingGestureDetector(
              onTap: () => provider.nextPage(context),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Header original ──────────────────────────────────
                    OnboardingHeader(fadeAnimation: provider.fadeAnimation),

                    // ── PageView dynamique (remplace les slides fixes) ───
                    OnboardingContent(
                      pageController: provider.pageController,
                      fadeAnimation: provider.fadeAnimation,
                      slideAnimation: provider.slideAnimation,
                      onPageChanged: provider.onPageChanged,
                      // slides injectées dynamiquement depuis OnboardingData
                      slides: provider.slides,
                    ),

                    // ── Indicateurs originaux ────────────────────────────
                    PageIndicators(
                      currentPage: provider.currentPage,
                      totalPages: provider.slides.length,
                      fadeAnimation: provider.fadeAnimation,
                      onIndicatorTap: provider.goToPage,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Conservé pour compatibilité avec les anciens imports
class OnboardingData {
  final String title;
  OnboardingData({required this.title});
}