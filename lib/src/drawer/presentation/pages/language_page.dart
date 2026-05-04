import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomDrawerHeader(),

            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre LANGUE
                    const Text(
                      'LANGUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Choisissez votre langue préférée',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Liste des langues
                    _buildLanguageTile(
                      flag: '🇫🇷',
                      name: 'Français',
                      nativeName: 'Français',
                      isSelected: true,
                      onTap: () {},
                    ),
                    _buildLanguageTile(
                      flag: '🇬🇧',
                      name: 'English',
                      nativeName: 'English',
                      isSelected: false,
                      onTap: () {},
                    ),
                    _buildLanguageTile(
                      flag: '🇪🇸',
                      name: 'Español',
                      nativeName: 'Español',
                      isSelected: false,
                      onTap: () {},
                    ),
                    _buildLanguageTile(
                      flag: '🇩🇯',
                      name: 'Lingua',
                      nativeName: 'Lingua',
                      isSelected: false,
                      onTap: () {},
                    ),
                    _buildLanguageTile(
                      flag: '🇲🇦',
                      name: 'Arabe',
                      nativeName: 'العربية',
                      isSelected: false,
                      onTap: () {},
                    ),

                    const SizedBox(height: 30),

                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'La langue sera appliquée après redémarrage de l\'application',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String flag,
    required String name,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          nativeName,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.radio_button_checked, color: AppTheme.primaryColor)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
