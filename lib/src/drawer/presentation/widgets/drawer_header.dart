import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomDrawerHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onBackPressed;

  const CustomDrawerHeader({super.key, this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppTheme.primaryColor, // Retour au fond d'origine (noir dans ton thème)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'DJINA',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
