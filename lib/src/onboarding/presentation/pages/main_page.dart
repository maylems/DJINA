// presentation/pages/main_page.dart
import 'package:djina_debug/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/auth/presentation/providers/auth_provider.dart';
import 'package:djina_debug/src/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:djina_debug/src/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:djina_debug/config/route_pages.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final OnboardingProvider _onboardingProvider = OnboardingProvider();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await _routeAfterSplash();
      }
    });

    _controller.forward();
  }

  Future<void> _routeAfterSplash() async {
    if (!mounted) return;

    // ── Étape 1 : onboarding déjà vu ? ──────────────────────────
    final alreadySeen = await _onboardingProvider.shouldSkipOnboarding();
    if (!mounted) return;

    if (!alreadySeen) {
      OnboardingController.startOnboarding(context);
      return;
    }

    // ── Étape 2 : token présent dans le storage ? ────────────────
    // On vérifie UNIQUEMENT la présence du token, sans appeler /me
    // (l'user sera chargé paresseusement depuis HomePage)
    final authProvider = context.read<AuthProvider>();
    final hasToken = await authProvider.hasActiveToken();
    if (!mounted) return;

    if (hasToken) {
      // Token trouvé → HomePage (le user se chargera en arrière-plan)
      Navigator.pushReplacementNamed(context, RoutePages.homepage);
    } else {
      OnboardingController.gotoJoinLoginPage(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _onboardingProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(AppImages.onboarding1, fit: BoxFit.contain),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'DJINA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 120,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _controller.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.black,
                        ),
                        minHeight: 5,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}