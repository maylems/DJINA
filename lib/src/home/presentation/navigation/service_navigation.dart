import 'package:flutter/material.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';
import 'package:djina_debug/src/home/presentation/pages/services/taxi_moto_page.dart';
import 'package:djina_debug/src/home/presentation/pages/services/taxi_voiture_page.dart';
import 'package:djina_debug/src/home/presentation/pages/services/livraison_moto_page.dart';
import 'package:djina_debug/src/home/presentation/pages/services/livraison_voiture_page.dart';

/// Navigation dédiée aux services
class ServiceNavigation {

  /// Navigue vers la page du service selon le type.
  /// [departure] et [destination] sont des PlaceResult (avec coordonnées).
  static void navigateToService(
    BuildContext context,
    String serviceType, {
    PlaceResult? departure,
    PlaceResult? destination,
  }) {
    switch (serviceType) {
      case 'taxi_moto':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaxiMotoPage()),
        );
        break;

      case 'taxi_voiture':
        if (departure == null || destination == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner un départ et une destination'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaxiVoiturePage(
              departure: departure,
              destination: destination,
            ),
          ),
        );
        break;

      case 'livraison_moto':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LivraisonMotoPage()),
        );
        break;

      case 'livraison_voiture':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LivraisonVoiturePage()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service "$serviceType" non disponible'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ── Méthodes directes ────────────────────────────────────────────────────

  static void navigateToTaxiMoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaxiMotoPage()),
    );
  }

  static void navigateToTaxiVoiture(
    BuildContext context, {
    required PlaceResult departure,
    required PlaceResult destination,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaxiVoiturePage(
          departure: departure,
          destination: destination,
        ),
      ),
    );
  }

  static void navigateToLivraisonMoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LivraisonMotoPage()),
    );
  }

  static void navigateToLivraisonVoiture(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LivraisonVoiturePage()),
    );
  }

  static void goBack(BuildContext context) => Navigator.pop(context);
}