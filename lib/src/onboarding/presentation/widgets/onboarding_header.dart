import 'package:djina_debug/src/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Pour gerer l'onboarding avec le logo DJINA
class OnboardingHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const OnboardingHeader({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DJINA',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 1,
                fontSize: 16,
              ),
            ),
            // Bouton Passer (nouveau — discret)
            Builder(builder: (context) {
              return GestureDetector(
                onTap: () {
                  final provider =
                      context.findAncestorWidgetOfExactType<
                          ChangeNotifierProvider<OnboardingProvider>>();
                  // On passe via nextPage répété jusqu'à la fin
                  // En pratique on navigue via le controller
                },
                child: Text(
                  'Passer',
                  style: TextStyle(
                    color: AppTheme.primaryColor.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}