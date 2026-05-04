// src/home/presentation/widgets/services_grid.dart

import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/presentation/widgets/service_type.dart';
import 'package:flutter/material.dart';

class ServicesGrid extends StatelessWidget {
  final String selectedService;
  final Function(String) onServiceSelected;

  const ServicesGrid({
    super.key,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Services',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Ligne 1 : Taxi moto + Taxi Voiture côte à côte
          Row(
            children: [
              Expanded(child: _buildServiceCard(context, services[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildServiceCard(context, services[1])),
            ],
          ),
          const SizedBox(height: 12),

          // Ligne 2 : Livraison Moto pleine largeur
          _buildServiceCard(context, services[2]),
          const SizedBox(height: 12),

          // Ligne 3 : Livraison Voiture pleine largeur
          _buildServiceCard(context, services[3]),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, Map<String, dynamic> service) {
    final isSelected = selectedService == service['type'];
    final bool available = service['available'] == true;

    return GestureDetector(
      onTap: () {
        if (!available) {
          // Service indisponible → snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${service['title']} est indisponible pour le moment'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        onServiceSelected(service['type'] as String);
      },
      child: Opacity(
        // Services indisponibles légèrement grisés
        opacity: available ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cardColor : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.cardColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 3,
                      width: 20,
                      color: AppTheme.cardColor,
                      margin: const EdgeInsets.only(bottom: 4),
                    ),
                    Text(
                      service['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      service['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                service['icon'] as String,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported,
                  size: 36,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}