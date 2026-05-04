// src/home/presentation/widgets/search_section.dart

import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';
import 'package:djina_debug/src/home/presentation/pages/services/taxi_voiture_page.dart';
import 'package:djina_debug/src/home/presentation/providers/home_provider.dart';
import 'package:djina_debug/src/home/presentation/widgets/place_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  void _navigateToService(BuildContext context, HomeProvider provider) {
    switch (provider.selectedService) {
      case 'taxi_voiture':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaxiVoiturePage(
              departure:   provider.departurePlace!,
              destination: provider.destinationPlace!,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce service est indisponible pour le moment'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final bool buttonActive = provider.canSearch && !provider.isLoading;

        return SafeArea(
          child: Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu, size: 28),
                    ),
                    const Text(
                      'DJINA',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Champ départ ─────────────────────────────────────
                // ✅ Spinner pendant la géoloc, champ pré-rempli ensuite
                provider.isLocating
                    ? _LocatingPlaceholder(hintText: 'Localisation en cours...')
                    : PlaceAutocompleteField(
                        hintText:       'Localisation / Point de départ',
                        prefixIcon:     Icons.location_on,
                        prefixIconColor: Colors.orange,
                        initialValue:   provider.departurePlace,
                        searchFn:       provider.searchPlaces,
                        onPlaceSelected: (PlaceResult place) {
                          provider.setDeparturePlace(place);
                        },
                      ),

                const SizedBox(height: 12),

                // ── Champ destination ────────────────────────────────
                PlaceAutocompleteField(
                  hintText:       'Où allez-vous ?',
                  prefixIcon:     Icons.location_on_outlined,
                  prefixIconColor: Colors.grey,
                  initialValue:   provider.destinationPlace,
                  showSuffix:     true,
                  searchFn:       provider.searchPlaces,
                  onPlaceSelected: (PlaceResult place) {
                    provider.setDestinationPlace(place);
                  },
                ),

                const SizedBox(height: 16),

                // ── Bouton Commandez ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonActive
                          ? AppTheme.cardColor
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: buttonActive
                        ? () async {
                            provider.searchRide();
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            if (context.mounted) {
                              _navigateToService(context, provider);
                            }
                          }
                        : null,
                    child: provider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Recherche...',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          )
                        : const Text('Commandez',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder affiché pendant la géolocalisation
class _LocatingPlaceholder extends StatelessWidget {
  final String hintText;
  const _LocatingPlaceholder({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(hintText,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}