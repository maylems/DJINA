// Page de Notation après course (m-rate)
// Interface étoiles 1-5, commentaire, tags, soumission
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/rating_provider.dart';
import 'package:djina_debug/src/home/presentation/providers/ride/ride_provider.dart';
import 'package:djina_debug/src/home/domain/models/ride/rating_model.dart';
import 'package:djina_debug/config/route_pages.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Noter votre course'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Message remerciement
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Merci !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Votre avis nous aide à améliorer le service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // Étoiles notation
                Text(
                  'Comment s\'est passée la course ?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isSelected = ratingProvider.selectedStars >= starValue;
                    return GestureDetector(
                      onTap: () => ratingProvider.setStars(starValue),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 50,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),
                Text(
                  _getRatingLabel(ratingProvider.selectedStars),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 30),

                // Tags optionnels
                if (ratingProvider.selectedStars > 0) ...[
                  const Text(
                    'Points forts (optionnel)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: RatingTag.values.map((tag) {
                      final isSelected = ratingProvider.selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(_tagLabel(tag)),
                        selected: isSelected,
                        onSelected: (_) => ratingProvider.toggleTag(tag),
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Champ commentaire
                const Text(
                  'Commentaires (optionnel)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Dites-nous ce que vous avez pensé de la course...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) => ratingProvider.setComment(value),
                ),

                const SizedBox(height: 40),

                // Bouton soumettre
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ratingProvider.canSubmit
                        ? () => _submitRating(context, ratingProvider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: ratingProvider.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Soumettre',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Skip
                TextButton(
                  onPressed: () => _skipRating(context),
                  child: const Text('Passer plus tard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRatingLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Moyen';
      case 4:
        return 'Bon';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  String _tagLabel(RatingTag tag) {
    switch (tag) {
      case RatingTag.punctual:
        return 'Ponctuel';
      case RatingTag.clean:
        return 'Propre';
      case RatingTag.safe:
        return 'Conduite sûre';
      case RatingTag.friendly:
        return 'Aimable';
      case RatingTag.professional:
        return 'Professionnel';
      case RatingTag.badRoute:
        return 'Mauvais itinéraire';
      case RatingTag.late:
        return 'En retard';
      case RatingTag.rude:
        return 'Impoli';
      case RatingTag.dirty:
        return 'Sale';
      case RatingTag.aggressive:
        return 'Conduite agressive';
    }
  }

  Future<void> _submitRating(BuildContext context, RatingProvider ratingProvider) async {
    // Get ride info from RideProvider
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final ride = rideProvider.currentRide;

    if (ride == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: aucune course trouvée'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ratingProvider.submitRating(
      rideId: ride.id,
      driverId: ride.driverId,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci pour votre notation !'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset providers and return to home
        ratingProvider.reset();
        rideProvider.reset();
        // Retour à l'accueil
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutePages.homepage,
              (route) => false,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _skipRating(BuildContext context) async {
    // Reset and go back to home
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    ratingProvider.reset();
    rideProvider.reset();
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutePages.homepage,
      (route) => false,
    );
  }
}
