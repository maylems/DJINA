// Page Écran d'Appel en Cours (m-Call)
// Affiché pendant que le chauffeur se dirige vers le point de prise
// Affiche: infos chauffeur, véhicule, ETA, bouton appel, annulation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/ride_provider.dart';
import 'package:djina_debug/src/home/domain/models/ride/ride_model.dart';
import 'package:djina_debug/config/route_pages.dart';

class OngoingCallPage extends StatelessWidget {
  const OngoingCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final ride = rideProvider.currentRide;
        if (ride == null) {
          return const Scaffold(
            body: Center(child: Text('Aucune course en cours')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Chauffeur en route'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _cancelRideDialog(context, rideProvider),
              ),
            ],
          ),
          body: Column(
            children: [
              // Carte du trajet (placeholder)
              Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.map, size: 80, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // Infos chauffeur + véhicule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Photo chauffeur
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(ride.driverPhoto),
                      onBackgroundImageError: (_, __) {},
                      child: ride.driverPhoto.isEmpty
                          ? const Icon(Icons.person, size: 35)
                          : null,
                    ),
                    const SizedBox(width: 15),

                    // Nom + note
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driverName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(' 4.8'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Type véhicule
                    Column(
                      children: [
                        Text(
                          ride.vehicleModel,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          ride.vehiclePlate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Détails pickup
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Point de prise',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            ride.pickupAddress,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          rideProvider.formattedDistanceToPickup,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rideProvider.formattedDurationToPickup,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton Appel + Annulation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(context, ride),
                        icon: const Icon(Icons.phone),
                        label: const Text('Appeler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelRideDialog(context, rideProvider),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Timer (optionnel)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'Recherche en cours...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(BuildContext context, Ride ride) async {
    // TODO: implémenter tel: url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appeler ${ride.driverName}')),
    );
  }

  Future<void> _cancelRideDialog(BuildContext context, RideProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la course ?'),
        content: const Text('Voulez-vous vraiment annuler cette course ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      provider.cancelRide();
      // Naviguer vers home
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutePages.homepage);
      }
    }
  }
}
