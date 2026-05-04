import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/core/utils/constants.dart';
import 'package:djina_debug/src/auth/presentation/pages/signup_page.dart';
import 'package:djina_debug/src/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';

class JoinLoginPage extends StatefulWidget {
  const JoinLoginPage({super.key});

  @override
  State<JoinLoginPage> createState() => _JoinLoginPageState();
}

class _JoinLoginPageState extends State<JoinLoginPage> {
  // Pour aller à la page de connexion
  void _handleLogin() {
    OnboardingController.gotoLoginPage(context);
  }

  // Pour aller à la page d'inscription
  void _handleSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Stack(
        children: [
          // Image en arrière-plan en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(AppImages.onboarding3, fit: BoxFit.contain),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton Joindre (Inscription)
                GestureDetector(
                  onTap: _handleSignup,
                  child: Container(
                    width: 220,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: const Center(
                      child: Text(
                        "Joindre",
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton Se connecter
                Container(
                  width: 220,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.40,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "DJINA",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}