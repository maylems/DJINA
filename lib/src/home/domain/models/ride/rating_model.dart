// Modèle pour la notation (rating) après une course
class Rating {
  final String rideId;
  final String driverId;
  final int stars;           // 1-5
  final String? comment;     // Commentaire optionnel
  final List<String> tags;   // Tags positifs/négatifs (propre, ponctuel, etc.)
  final bool isPaymentIssue; // Problème de paiement signalé
  final DateTime timestamp;

  const Rating({
    required this.rideId,
    required this.driverId,
    required this.stars,
    this.comment,
    this.tags = const [],
    this.isPaymentIssue = false,
    required this.timestamp,
  });

  // Validation : note entre 1 et 5
  bool get isValid => stars >= 1 && stars <= 5;

  // Rating négatif (1-2 étoiles)
  bool get isNegative => stars <= 2;

  // Rating positif (4-5 étoiles)
  bool get isPositive => stars >= 4;
}

// Énumération des tags de notation prédéfinis
enum RatingTag {
  punctual,     // Ponctuel
  clean,        // Propre
  safe,         // Conduite sûre
  friendly,     // Aimable
  professional, // Professionnel
  badRoute,     // Mauvais itinéraire
  late,         // En retard
  rude,         // Impoli
  dirty,        // Sale
  aggressive,   // Conduite agressive
}
