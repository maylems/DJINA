import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/auth_navigation.dart';
import '../pages/otp_signup.dart';
import '../providers/auth_provider.dart';

class AuthController {
  /// Navigue vers la page d'accueil
  static void gotoHomepage(BuildContext context) {
    AuthNavigation.completeAuthentication(context);
  }

  /// Gère la connexion utilisateur
  static Future<void> login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(context);
  }

  /// Gère l'inscription utilisateur.
  /// Le provider est global → pas besoin de ChangeNotifierProvider.value.
  /// OtpSignupPage le trouve directement dans l'arbre.
  static Future<void> signup(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signup(
      context,
      onSuccess: (phone) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OtpSignupPage(),
              // ↑ Plus besoin de ChangeNotifierProvider.value :
              //   AuthProvider est accessible depuis le MultiProvider racine
            ),
          );
        }
      },
    );
  }

  /// Bascule la visibilité du mot de passe
  static void togglePasswordVisibility(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false)
        .togglePasswordVisibility();
  }

  /// Bascule l'acceptation des conditions
  static void toggleTermsAcceptance(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).toggleTermsAcceptance();
  }

  /// Efface les erreurs
  static void clearError(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).clearError();
  }
}