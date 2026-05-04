// Modèle représentant une course en cours (ongoing ride)
// Utilisé pendant l'appel, le suivi et la notation
class Ride {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhoto;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double? destinationLat;
  final String? destinationAddress;
  final RideStatus status;
  final DateTime startTime;
  final DateTime? estimatedArrival;
  final double currentLat;      // Position actuelle du chauffeur
  final double currentLng;
  final double distanceToPickup; // mètres
  final int durationToPickup;   // secondes
  final double? fare;
  final String? paymentMethod;

  const Ride({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhoto,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    this.destinationLat,
    this.destinationAddress,
    required this.status,
    required this.startTime,
    this.estimatedArrival,
    required this.currentLat,
    required this.currentLng,
    required this.distanceToPickup,
    required this.durationToPickup,
    this.fare,
    this.paymentMethod,
  });

  // Calcul si le chauffeur est arrivé au point de prise
  bool get isDriverArrived => status == RideStatus.driverArrived;

  // Calcul si la course a commencé
  bool get isRideStarted => status == RideStatus.started;

  // Calcul si la course est terminée
  bool get isRideCompleted => status == RideStatus.completed;

  // Temps écoulé depuis le début
  Duration get elapsedTime => DateTime.now().difference(startTime);

  // Créer une copie modifiée
  Ride copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverPhoto,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? destinationLat,
    String? destinationAddress,
    RideStatus? status,
    DateTime? startTime,
    DateTime? estimatedArrival,
    double? currentLat,
    double? currentLng,
    double? distanceToPickup,
    int? durationToPickup,
    double? fare,
    String? paymentMethod,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      distanceToPickup: distanceToPickup ?? this.distanceToPickup,
      durationToPickup: durationToPickup ?? this.durationToPickup,
      fare: fare ?? this.fare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  // Factory constructor from JSON (API response)
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      driverName: json['driver_name'] as String? ?? '',
      driverPhoto: json['driver_photo'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      vehiclePlate: json['vehicle_plate'] as String? ?? '',
      vehicleColor: json['vehicle_color'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0.0,
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationAddress: json['destination_address'] as String?,
      status: RideStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => RideStatus.searching,
      ),
      startTime: DateTime.tryParse(json['start_time'] as String? ?? '') ?? DateTime.now(),
      estimatedArrival: DateTime.tryParse(json['estimated_arrival'] as String? ?? ''),
      currentLat: (json['current_lat'] as num?)?.toDouble() ?? 0.0,
      currentLng: (json['current_lng'] as num?)?.toDouble() ?? 0.0,
      distanceToPickup: (json['distance_to_pickup'] as num?)?.toDouble() ?? 0.0,
      durationToPickup: (json['duration_to_pickup'] as num?)?.toInt() ?? 0,
      fare: (json['fare'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
    );
  }
}

enum RideStatus {
  searching,      // Recherche de chauffeur
  driverFound,    // Chauffeur trouvé, en route vers vous
  driverArrived,  // Chauffeur arrivé au point de prise
  started,        // Course démarrée
  completed,      // Course terminée
  cancelled,      // Course annulée
}
