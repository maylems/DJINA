// src/home/domain/models/course_model.dart

class VehicleOption {
  final String id;
  final String label;
  final int price;
  final int etaMinutes;
  final String imagePath;

  const VehicleOption({
    required this.id,
    required this.label,
    required this.price,
    required this.etaMinutes,
    required this.imagePath,
  });
}

/// Options Taxi Voiture Djina
class TaxiVoitureOptions {
  static const List<VehicleOption> options = [
    VehicleOption(
      id: 'economy',
      label: 'Economy',
      price: 2000,
      etaMinutes: 3,
      imagePath: 'assets/images/car_economy.png',
    ),
    VehicleOption(
      id: 'confort',
      label: 'Confort',
      price: 3000,
      etaMinutes: 2,
      imagePath: 'assets/images/car_confort.png',
    ),
    VehicleOption(
      id: 'confort_plus',
      label: 'Confort +',
      price: 5000,
      etaMinutes: 3,
      imagePath: 'assets/images/car_confort_plus.png',
    ),
  ];
}