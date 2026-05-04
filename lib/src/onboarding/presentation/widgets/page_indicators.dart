import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages; // ← dynamique au lieu d'être hardcodé
  final Animation<double> fadeAnimation;
  final ValueChanged<int> onIndicatorTap;

  const PageIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.fadeAnimation,
    required this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final isActive = index == currentPage;
            return GestureDetector(
              onTap: () => onIndicatorTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                // Largeur élargie sur la slide active (effet pill)
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}