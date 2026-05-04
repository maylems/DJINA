import 'package:flutter/material.dart';
import 'package:djina_debug/config/route_pages.dart';

// Pages d'onboarding
import 'package:djina_debug/src/onboarding/presentation/pages/main_page.dart';
import 'package:djina_debug/src/onboarding/presentation/pages/welcome_page.dart';
import 'package:djina_debug/src/onboarding/presentation/pages/onboarding_screens.dart';
import 'package:djina_debug/src/onboarding/presentation/pages/location_permission_page.dart';

// Pages d'authentification
import 'package:djina_debug/src/auth/presentation/pages/login_page.dart';
import 'package:djina_debug/src/auth/presentation/pages/signup_page.dart';
import 'package:djina_debug/src/auth/presentation/pages/otp_signup.dart';
import 'package:djina_debug/src/onboarding/presentation/pages/join-login_page.dart';

// Page d'accueil
import 'package:djina_debug/src/home/presentation/pages/home_page.dart';

// Pages courses (suivi, appel, notation)
import 'package:djina_debug/src/home/presentation/pages/ride/ongoing_call_page.dart';
import 'package:djina_debug/src/home/presentation/pages/ride/ride_tracking_page.dart';
import 'package:djina_debug/src/home/presentation/pages/ride/rating_page.dart';

/// Service de navigation centralisé
/// Simplifie la navigation pour les développeurs juniors
class AppNavigation {
  /// Configuration des routes de l'application
  static Map<String, WidgetBuilder> get routes => {
    RoutePages.splash: (context) => const MainPage(),
    RoutePages.welcome: (context) => const WelcomePage(),
    RoutePages.onboarding: (context) => const OnboardingScreens(),
    RoutePages.locationPermission: (context) => const LocationPermissionPage(),
    RoutePages.login: (context) => const LoginPage(),
    RoutePages.signup: (context) => const SignupPage(),
    RoutePages.otpSignup: (context) => const OtpSignupPage(),
    RoutePages.joinLogin: (context) => const JoinLoginPage(),
    RoutePages.homepage: (context) => const HomePage(),
    RoutePages.ongoingCall: (context) => const OngoingCallPage(),
    RoutePages.rideTracking: (context) => const RideTrackingPage(),
    RoutePages.rate: (context) => const RatingPage(),
  };

  /// Navigation simple vers une page
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Navigation avec remplacement (pas de retour possible)
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navigation avec animation personnalisée
  static void navigateWithAnimation(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  /// Retour à la page précédente
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
