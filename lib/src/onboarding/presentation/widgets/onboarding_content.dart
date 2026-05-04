import 'package:djina_debug/src/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/core/theme/app_theme.dart';

///le contenu principal de l'onboarding
class OnboardingContent extends StatelessWidget {
  final PageController pageController;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final ValueChanged<int> onPageChanged;

  /// Slides dynamiques injectées depuis OnboardingProvider
  final List<OnboardingSlide> slides;

  const OnboardingContent({
    super.key,
    required this.pageController,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onPageChanged,
    required this.slides,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _OnboardingPage(slide: slide);
            },
          ),
        ),
      ),
    );
  }
}

// Page individuelle — même structure visuelle qu'avant
class _OnboardingPage extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset(
              slide.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Titre avec AnimatedSwitcher pour transition fluide entre slides
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            slide.title,
            key: ValueKey(slide.title),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}