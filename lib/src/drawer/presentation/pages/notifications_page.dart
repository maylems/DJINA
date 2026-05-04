import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:djina_debug/src/drawer/presentation/widgets/drawer_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
                    // Titre NOTIFICATIONS
                    const Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Liste notifications (statique pour l'instant)
                    _buildNotificationItem(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      title: 'Course terminée',
                      message: 'Votre course de 2 500 FCFA a été payée avec succès.',
                      time: 'Il y a 5 min',
                      isRead: false,
                    ),
                    _buildNotificationItem(
                      icon: Icons.discount,
                      color: Colors.orange,
                      title: 'Promotion !',
                      message: '20% de réduction sur votre prochaine course.',
                      time: 'Il y a 1 heure',
                      isRead: false,
                    ),
                    _buildNotificationItem(
                      icon: Icons.info,
                      color: Colors.blue,
                      title: 'Nouvelle fonctionnalité',
                      message: 'Découvrez la livraison de colis.',
                      time: 'Hier',
                      isRead: true,
                    ),
                    _buildNotificationItem(
                      icon: Icons.security_update_good,
                      color: Colors.purple,
                      title: 'Sécurité',
                      message: 'Votre compte est sécurisé. Connexion depuis Paris.',
                      time: '2 jours',
                      isRead: true,
                    ),

                    const SizedBox(height: 20),

                    // Paramètres notifications
                    const Text(
                      'PARAMÈTRES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildToggleTile(
                      title: 'Notifications push',
                      subtitle: 'Recevoir des alertes en temps réel',
                      value: true,
                      onChanged: (val) {},
                    ),
                    _buildToggleTile(
                      title: 'Promotions',
                      subtitle: 'Offres spéciales et réductions',
                      value: true,
                      onChanged: (val) {},
                    ),
                    _buildToggleTile(
                      title: 'Sécurité du compte',
                      subtitle: 'Alertes de connexion, changements',
                      value: true,
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
