import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomDrawerHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre A PROPOS
                    const Text(
                      'A PROPOS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.taxi_alert,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'DJINA',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Description
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 8),
                    const Text(
                      'DJINA est une application de transport et de livraison qui connecte les passagers avec des chauffeurs professionnels. Notre mission est de rendre vos déplacements sûrs, rapides et abordables.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Infos légales
                    _buildSectionTitle('Informations légales'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Société', 'DJINA Technologies'),
                    _buildInfoRow('SIRET', '123 456 789 00012'),
                    _buildInfoRow('Adresse', 'Dakar, Sénégal'),
                    _buildInfoRow('Email', 'contact@djina.sn'),
                    _buildInfoRow('Téléphone', '+33 1 23 45 67 89'),

                    const SizedBox(height: 30),

                    // Conditions
                    _buildSectionTitle('Conditions d\'utilisation'),
                    const SizedBox(height: 12),
                    _buildLinkItem('Conditions générales', () {
                      // TODO: navigate to terms
                    }),
                    _buildLinkItem('Politique de confidentialité', () {
                      // TODO: navigate to privacy
                    }),
                    _buildLinkItem('Conditions de livraison', () {
                      // TODO: navigate to delivery terms
                    }),

                    const SizedBox(height: 30),

                    // Copyright
                    Center(
                      child: Text(
                        '© 2025 DJINA. Tous droits réservés.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
