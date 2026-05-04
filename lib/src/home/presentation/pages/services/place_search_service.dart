// src/home/data/services/place_search_service.dart
//
// Photon (photon.komoot.io) — gratuit, sans clé API.
// Le biais géographique est centré sur la position GPS réelle de l'utilisateur
// → fonctionne partout dans le monde.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/models/place_model.dart';

class PlaceSearchService {
  static const String _photonUrl  = 'https://photon.komoot.io/api/';
  static const String _reverseUrl = 'https://photon.komoot.io/reverse/';

  static const Map<String, String> _headers = {
    'User-Agent': 'DjinaApp/1.0',
  };

  /// Recherche des lieux à partir de 2 caractères.
  /// [userLat] / [userLng] : position GPS de l'utilisateur pour biaiser
  /// les résultats vers son pays/ville — si null, pas de biais.
  Future<List<PlaceResult>> search(
    String query, {
    double? userLat,
    double? userLng,
  }) async {
    if (query.trim().length < 2) return [];

    final params = <String, String>{
      'q':     query.trim(),
      'limit': '7',
      'lang':  'fr',
    };

    // ✅ Biais sur la position réelle de l'utilisateur
    if (userLat != null && userLng != null) {
      params['lat'] = userLat.toStringAsFixed(6);
      params['lon'] = userLng.toStringAsFixed(6);
    }

    final uri = Uri.parse(_photonUrl).replace(queryParameters: params);

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return [];

      final data     = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      return features
          .map((f) => PlaceResult.fromPhoton(f as Map<String, dynamic>))
          .where((p) => p.shortName.isNotEmpty && p.shortName != 'Lieu inconnu')
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Géocode inverse : retourne le nom d'un lieu depuis des coordonnées GPS.
  Future<PlaceResult?> reverse(double lat, double lng) async {
    final uri = Uri.parse(_reverseUrl).replace(
      queryParameters: {
        'lat': lat.toStringAsFixed(6),
        'lon': lng.toStringAsFixed(6),
      },
    );

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final data     = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (features.isEmpty) return null;

      return PlaceResult.fromPhoton(features.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}