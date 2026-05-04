// presentation/providers/onboarding_provider.dart
import 'package:djina_debug/core/utils/constants.dart';
import 'package:djina_debug/src/onboarding/domain/repositories/location_repository.dart';
import 'package:djina_debug/src/onboarding/domain/repositories/location_repository_impl.dart';
import 'package:djina_debug/src/onboarding/domain/repositories/preferences_repositories.dart';
import 'package:djina_debug/src/onboarding/domain/repositories/preferences_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/onboarding/presentation/controllers/onboarding_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modèle d'une slide d'onboarding
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingSlide {
  final String title;
  final String imagePath;

  const OnboardingSlide({required this.title, required this.imagePath});
}

// ─────────────────────────────────────────────────────────────────────────────
// Données des slides — modifiables sans toucher aux widgets
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingData {
  static const List<OnboardingSlide> pages = [
    OnboardingSlide(
      title: 'Bienvenue sur DJINA',
      imagePath: AppImages.onboarding1,
    ),
    OnboardingSlide(
      title: 'Réservez en quelques secondes',
      imagePath: AppImages.onboarding2,
    ),
    OnboardingSlide(
      title: 'Arrivez à destination',
      imagePath: AppImages.onboarding3,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingProvider extends ChangeNotifier {
  final PreferencesRepository _prefsRepo;
  final LocationRepository _locationRepo;

  OnboardingProvider({
    PreferencesRepository? prefsRepo,
    LocationRepository? locationRepo,
  })  : _prefsRepo = prefsRepo ?? PreferencesRepositoryImpl(),
        _locationRepo = locationRepo ?? LocationRepositoryImpl();

  int _currentPage = 0;
  bool _isAnimating = false;
  bool _isRequestingLocation = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PageController _pageController = PageController();

  // ── Getters ────────────────────────────────────────────────────────────────
  int get currentPage => _currentPage;
  bool get isAnimating => _isAnimating;
  bool get isLastPage => _currentPage >= OnboardingData.pages.length - 1;
  bool get isRequestingLocation => _isRequestingLocation;
  PageController get pageController => _pageController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  List<OnboardingSlide> get slides => OnboardingData.pages;

  // ── Animations ─────────────────────────────────────────────────────────────
  void initializeAnimations(TickerProvider vsync) {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _startEntryAnimations();
  }

  void _startEntryAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  void _restartAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  // ── Navigation slides ──────────────────────────────────────────────────────
  void onPageChanged(int page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
      _restartAnimations();
    }
  }

  void nextPage(BuildContext context) {
    if (_isAnimating) return;

    if (!isLastPage) {
      _isAnimating = true;
      notifyListeners();

      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          )
          .then((_) {
            _isAnimating = false;
            notifyListeners();
          });
    } else {
      OnboardingController.requestLocationPermission(context);
    }
  }

  void goToPage(int page) {
    if (_isAnimating || page == _currentPage) return;
    _isAnimating = true;
    notifyListeners();

    _pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isAnimating = false;
          notifyListeners();
        });
  }

  // ── Localisation + complétion ──────────────────────────────────────────────

  Future<void> requestLocationAndComplete(BuildContext context) async {
    _isRequestingLocation = true;
    notifyListeners();

    try {
      await _locationRepo.enableLocation();
    } catch (_) {}

    await _prefsRepo.saveOnboardingComplete();

    _isRequestingLocation = false;
    notifyListeners();

    if (context.mounted) {
      OnboardingController.gotoJoinLoginPage(context);
    }
  }

  Future<void> skipLocationAndComplete(BuildContext context) async {
    await _prefsRepo.saveOnboardingComplete();
    if (context.mounted) {
      OnboardingController.gotoJoinLoginPage(context);
    }
  }

  // ── Vérifie si onboarding déjà vu ─────────────────────────────────────────
  Future<bool> shouldSkipOnboarding() async {
    return _prefsRepo.isOnboardingComplete();
  }

  void disposeAnimations() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
  }
}