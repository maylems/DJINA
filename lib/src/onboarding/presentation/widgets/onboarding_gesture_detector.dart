import 'package:flutter/material.dart';

/// Widget pour gérer les gestes de l'onboarding
class OnboardingGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const OnboardingGestureDetector({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}