final List<Map<String, dynamic>> services = [
  {
    'type': 'taxi_moto',           // ✅ correspond à ServiceNavigation
    'title': 'Taxi moto',
    'subtitle': 'Djina',
    'icon': 'assets/images/motorcycle-front.png',
    'available': false,            // ✅ champ manquant ajouté
  },
  {
    'type': 'taxi_voiture',        // ✅ correspond à ServiceNavigation
    'title': 'Taxi Voiture',
    'subtitle': 'Djina',
    'icon': 'assets/images/car-rear.png',
    'available': true,             // ✅ seul service actif
  },
  {
    'type': 'livraison_moto',
    'title': 'Livraison Moto',
    'subtitle': '2 ROUES',
    'icon': 'assets/images/vector.png',
    'available': false,
  },
  {
    'type': 'livraison_voiture',
    'title': 'Livraison Voiture',
    'subtitle': 'Cargot',
    'icon': 'assets/images/van-front.png',
    'available': false,
  },
];