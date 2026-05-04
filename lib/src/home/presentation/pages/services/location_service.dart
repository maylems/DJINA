// src/home/pages/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Demande la permission et retourne la position GPS.
  /// Retourne null si permission refusée ou GPS indisponible.
  Future<Position?> getCurrentPosition() async {
    // Vérifie si le service GPS est activé
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Vérifie/demande la permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Fallback : dernière position connue
      return await Geolocator.getLastKnownPosition();
    }
  }
}