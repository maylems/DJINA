import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/custom_button.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

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
                    // Titre SUPPORT
                    const Text(
                      'SUPPORT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Text(
                      'Besoin d\'aide ? Notre équipe est disponible 7j/7.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Contact direct
                    _buildContactCard(
                      icon: Icons.phone,
                      title: 'Appeler le service client',
                      subtitle: '+33 1 23 45 67 89',
                      color: Colors.green,
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _buildContactCard(
                      icon: Icons.email,
                      title: 'Envoyer un email',
                      subtitle: 'support@djina.sn',
                      color: Colors.blue,
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _buildContactCard(
                      icon: Icons.chat,
                      title: 'Chat en direct',
                      subtitle: 'Réponse en moins de 5 min',
                      color: Colors.orange,
                      onTap: () {},
                    ),

                    const SizedBox(height: 30),

                    // FAQ
                    _buildSectionTitle('Questions fréquentes'),
                    const SizedBox(height: 12),

                    _buildFaqItem(
                      question: 'Comment annuler une course ?',
                      answer: 'Vous pouvez annuler une course depuis la page de suivi en appuyant sur le bouton "Annuler". Des frais peuvent s\'appliquer.',
                    ),
                    _buildFaqItem(
                      question: 'Comment modifier mon mode de paiement ?',
                      answer: 'Allez dans Profil > Sécurité > Méthodes de paiement pour ajouter ou modifier votre carte.',
                    ),
                    _buildFaqItem(
                      question: 'Que faire en cas de problème avec un chauffeur ?',
                      answer: 'Signalez-le via l\'application dans Historique > Signaler un problème. Notre équipe examine chaque signalement.',
                    ),

                    const SizedBox(height: 30),

                    // Lien vers FAQ complète
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Voir toutes les FAQ',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.help_outline,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
