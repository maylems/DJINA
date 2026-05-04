// Page de Suivi de Course (m-followup)
// Affiché pendant la course: carte en direct, étapes, infos chauffeur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/ride_provider.dart';
import 'package:djina_debug/config/route_pages.dart';
import 'package:djina_debug/src/home/domain/models/ride/ride_model.dart';

class RideTrackingPage extends StatelessWidget {
  const RideTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final ride = rideProvider.currentRide;
        if (ride == null) {
          return const Scaffold(
            body: Center(child: Text('Aucune course active')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Course en cours'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () => _callDriver(context, ride),
              ),
            ],
          ),
          body: Column(
            children: [
              // Carte de suivi (placeholder)
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.directions_car, size: 100, color: Colors.grey),
                      ),
                    ),
                    // Marker chauffeur (placeholder)
                    Positioned(
                      top: 100,
                      left: 150,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Panneau inférieur: étapes + infos
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Photo chauffeur + statut
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(ride.driverPhoto),
                          onBackgroundImageError: (_, __) {},
                          child: ride.driverPhoto.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.driverName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _getStatusText(ride.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Étape actuelle
                        _buildStepIndicator(ride.status),
                      ],
                    ),

                    const Divider(height: 30),

                    // Détails parcours
                    _buildStepRow(
                      'Prise en charge',
                      ride.pickupAddress,
                      isActive: ride.status == RideStatus.driverArrived ||
                                ride.status == RideStatus.started,
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow(
                      'Destination',
                      ride.destinationAddress ?? 'Non définie',
                      isActive: ride.status == RideStatus.started,
                    ),

                    const SizedBox(height: 20),

                    // Boutons d'action
                    if (ride.status == RideStatus.driverArrived)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => rideProvider.startRide(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Monter dans le véhicule',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else if (ride.status == RideStatus.started)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _completeRide(context, rideProvider),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Je suis arrivé',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(RideStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case RideStatus.searching:
        color = Colors.orange;
        icon = Icons.search;
        break;
      case RideStatus.driverFound:
        color = Colors.blue;
        icon = Icons.directions_car;
        break;
      case RideStatus.driverArrived:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case RideStatus.started:
        color = Colors.purple;
        icon = Icons.play_arrow;
        break;
      case RideStatus.completed:
        color = Colors.grey;
        icon = Icons.check;
        break;
      case RideStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ],
    );
  }

  Widget _buildStepRow(String title, String subtitle, {bool isActive = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.searching:
        return 'Recherche d\'un chauffeur...';
      case RideStatus.driverFound:
        return 'Chauffeur en route vers vous';
      case RideStatus.driverArrived:
        return 'Chauffeur arrivé';
      case RideStatus.started:
        return 'Course en cours';
      case RideStatus.completed:
        return 'Course terminée';
      case RideStatus.cancelled:
        return 'Course annulée';
    }
  }

  Future<void> _callDriver(BuildContext context, Ride ride) async {
    // TODO: appel téléphone
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appeler ${ride.driverName}')),
    );
  }

  Future<void> _completeRide(BuildContext context, RideProvider provider) async {
    provider.completeRide();
    if (context.mounted) {
      await Navigator.pushNamed(context, RoutePages.rate);
    }
  }
}
