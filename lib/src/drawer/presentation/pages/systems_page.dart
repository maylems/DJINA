import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/custom_button.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';

class SystemsPage extends StatelessWidget {
  const SystemsPage({super.key});

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
                    // Titre SYSTEMS
                    const Text(
                      'SYSTEMS',
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
                      'Informations techniques et statut des services',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Statut des services
                    _buildSectionTitle('Statut des services'),
                    const SizedBox(height: 12),

                    _buildStatusItem(
                      title: 'API Transport',
                      status: 'Opérationnel',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatusItem(
                      title: 'Paiements',
                      status: 'Opérationnel',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatusItem(
                      title: 'Notifications',
                      status: 'Opérationnel',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatusItem(
                      title: 'Cartes et maps',
                      status: 'Opérationnel',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 30),

                    // Version & Build
                    _buildSectionTitle('Version application'),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVersionRow('Nom du package', 'djina_debug'),
                          _buildVersionRow('Version', '1.0.0'),
                          _buildVersionRow('Build number', '1'),
                          _buildVersionRow('Canal', 'Production'),
                          _buildVersionRow('Flutter SDK', '3.24.0'),
                          _buildVersionRow('Dart', '3.5.0'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Informations techniques
                    _buildSectionTitle('Informations techniques'),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTechRow('Device model', 'Android Emulator'),
                          _buildTechRow('OS version', 'Android 14 (API 34)'),
                          _buildTechRow('Architecture', 'arm64-v8a'),
                          _buildTechRow('Locale', 'fr_FR'),
                          _buildTechRow('TimeZone', 'Africa/Dakar'),
                          _buildTechRow('Screen density', '2.0'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Actions techniques
                    _buildSectionTitle('Actions'),
                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Vérifier les mises à jour',
                      backgroundColor: AppTheme.primaryColor,
                      onPressed: () {
                        // TODO: check update
                      },
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Rapports de bug',
                      backgroundColor: AppTheme.cardColor,
                      onPressed: () {
                        // TODO: crash reports
                      },
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

  Widget _buildStatusItem({
    required String title,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
