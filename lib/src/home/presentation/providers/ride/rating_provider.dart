// Provider pour la notation après course (rating)
import 'package:flutter/foundation.dart';
import 'package:djina_debug/src/home/domain/models/ride/rating_model.dart';

class RatingProvider extends ChangeNotifier {
  int _selectedStars = 0;
  String? _comment;
  final List<RatingTag> _selectedTags = [];
  bool _isSubmitting = false;
  bool _isCompleted = false;

  // Getters
  int get selectedStars => _selectedStars;
  String? get comment => _comment;
  List<RatingTag> get selectedTags => _selectedTags;
  bool get isSubmitting => _isSubmitting;
  bool get isCompleted => _isCompleted;
  bool get canSubmit => _selectedStars > 0 && !_isSubmitting;

  // Définir les étoiles
  void setStars(int stars) {
    _selectedStars = stars;
    notifyListeners();
  }

  // Ajouter/supprimer commentaire
  void setComment(String? comment) {
    _comment = comment;
    notifyListeners();
  }

  // Toggle tag
  void toggleTag(RatingTag tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  // Soumettre la notation
  Future<bool> submitRating({
    required String rideId,
    required String driverId,
  }) async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      // Simuler appel API
      await Future.delayed(const Duration(seconds: 2));

      final rating = Rating(
        rideId: rideId,
        driverId: driverId,
        stars: _selectedStars,
        comment: _comment,
        tags: _selectedTags.map((t) => t.name).toList(),
        timestamp: DateTime.now(),
      );

      // TODO: envoyer rating à l'API
      if (kDebugMode) {
        print('Rating submitted: ${rating.stars} stars for ride $rideId');
      }

      _isCompleted = true;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Reset pour nouvelle notation
  void reset() {
    _selectedStars = 0;
    _comment = null;
    _selectedTags.clear();
    _isSubmitting = false;
    _isCompleted = false;
    notifyListeners();
  }
}
