// Provider pour l'état de la course en cours (ongoing ride)
// Gère l'appel, le suivi du chauffeur, et la progression
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:djina_debug/src/home/domain/models/ride/ride_model.dart';
import 'package:djina_debug/src/home/domain/models/ride/driver_location_model.dart';

class RideProvider extends ChangeNotifier {
  Ride? _currentRide;
  DriverLocation? _lastKnownLocation;
  bool _isCalling = false;
  bool _isRideActive = false;

  // Getters
  Ride? get currentRide => _currentRide;
  DriverLocation? get lastKnownLocation => _lastKnownLocation;
  bool get isCalling => _isCalling;
  bool get isRideActive => _isRideActive;
  bool get hasActiveRide => _currentRide != null;

  // Statut de l'appel
  bool get isCallConnected => _isCalling && _currentRide != null;

  // Distance formatée
  String get formattedDistanceToPickup {
    if (_currentRide == null) return '--';
    final dist = _currentRide!.distanceToPickup;
    if (dist < 1000) return '${dist.toStringAsFixed(0)} m';
    return '${(dist / 1000).toStringAsFixed(1)} km';
  }

  // Temps formaté
  String get formattedDurationToPickup {
    if (_currentRide == null) return '--';
    final mins = (_currentRide!.durationToPickup / 60).round();
    if (mins < 60) return '$mins min';
    final hrs = (mins / 60).floor();
    final rem = mins % 60;
    return '$hrs h $rem min';
  }

  // Initialiser une nouvelle course (appel chauffeur)
  Future<void> initiateRide({
    required String driverId,
    required String driverName,
    required String driverPhoto,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    double? destinationLat,
    String? destinationAddress,
  }) async {
    _isCalling = true;
    _currentRide = Ride(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      driverId: driverId,
      driverName: driverName,
      driverPhoto: driverPhoto,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      vehicleColor: vehicleColor,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupAddress: pickupAddress,
      destinationLat: destinationLat,
      destinationAddress: destinationAddress,
      status: RideStatus.searching,
      startTime: DateTime.now(),
      currentLat: pickupLat,
      currentLng: pickupLng,
      distanceToPickup: 0,
      durationToPickup: 0,
    );
    notifyListeners();

    // Simuler recherche chauffeur (API call)
    await Future.delayed(const Duration(seconds: 3));

    // Chauffeur trouvé
    _currentRide = _currentRide!.copyWith(
      status: RideStatus.driverFound,
      distanceToPickup: 1500, // m
      durationToPickup: 180,  // 3 min
    );
    _isCalling = false;
    _isRideActive = true;
    notifyListeners();
  }

  // Mettre à jour la position du chauffeur (stream GPS)
  void updateDriverLocation(DriverLocation location) {
    _lastKnownLocation = location;
    if (_currentRide != null) {
      final dist = _calculateDistance(
        _currentRide!.pickupLat,
        _currentRide!.pickupLng,
        location.latitude,
        location.longitude,
      );
      _currentRide = _currentRide!.copyWith(
        currentLat: location.latitude,
        currentLng: location.longitude,
        distanceToPickup: dist,
      );
      // Si le chauffeur est à <50m, il est arrivé
      if (dist < 50 && _currentRide!.status != RideStatus.driverArrived) {
        _currentRide = _currentRide!.copyWith(status: RideStatus.driverArrived);
      }
      notifyListeners();
    }
  }

  // Confirmer que le passager est monté
  void startRide() {
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: RideStatus.started);
      notifyListeners();
    }
  }

  // Terminer la course
  void completeRide({double? finalFare}) {
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(
        status: RideStatus.completed,
        fare: finalFare ?? _currentRide!.fare,
      );
      _isRideActive = false;
      notifyListeners();
    }
  }

  // Annuler la course
  void cancelRide() {
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: RideStatus.cancelled);
      _isRideActive = false;
      notifyListeners();
    }
  }

  // Réinitialiser
  void reset() {
    _currentRide = null;
    _lastKnownLocation = null;
    _isCalling = false;
    _isRideActive = false;
    notifyListeners();
  }

  // Helper: distance Haversine (mètres)
  double _calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3; // mètres
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi/2) * sin(deltaPhi/2) +
              cos(phi1) * cos(phi2) *
              sin(deltaLambda/2) * sin(deltaLambda/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));

    return R * c;
  }
}
