// Modèle pour le suivi de position du chauffeur pendant la course
class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final double bearing;        // Direction en degrés (0-360)
  final double speed;          // m/s
  final DateTime timestamp;

  const DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.bearing,
    required this.speed,
    required this.timestamp,
  });

  // Est-ce que la position est récente (moins de 30s) ?
  bool get isFresh => DateTime.now().difference(timestamp).inSeconds < 30;
}

// Étape de la course pour le suivi (timeline)
enum RideStep {
  driverAssigned,   // Chauffeur assigné
  driverEnRoute,    // Chauffeur en route vers prise
  driverArrived,    // Chauffeur arrivé
  passengerPickedUp, // Passager pris en charge
  enRouteToDestination, // En route vers destination
  arrivedAtDestination, // Arrivé à destination
  rateCompleted,    // Notation terminée
}
