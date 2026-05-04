// src/home/data/services/routing_service.dart
//
// Utilise OSRM (demo.project-osrm.org) — routage routier réel,
// gratuit, sans clé API, basé sur OpenStreetMap.
// Retourne la liste de points (LatLng) du trajet réel.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  static const Map<String, String> _headers = {
    'User-Agent': 'DjinaApp/1.0',
  };

  /// Retourne la liste de points du trajet routier entre [origin] et [destination].
  /// Retourne une ligne droite en cas d'échec réseau.
  Future<RouteResult?> getRoute(LatLng origin, LatLng destination) async {
    final url =
        '$_baseUrl/${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&steps=false';

    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route     = routes.first as Map<String, dynamic>;
      final geometry  = route['geometry'] as Map<String, dynamic>;
      final coords    = geometry['coordinates'] as List<dynamic>;
      final distance  = (route['distance'] as num).toDouble(); // mètres
      final duration  = (route['duration'] as num).toDouble(); // secondes

      final points = coords.map((c) {
        final pair = c as List<dynamic>;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points:   points,
        distance: distance,
        duration: duration,
      );
    } catch (_) {
      return null;
    }
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distance; // mètres
  final double duration; // secondes

  const RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
  });

  /// Distance formatée ex: "3.2 km"
  String get distanceLabel {
    if (distance < 1000) return '${distance.toStringAsFixed(0)} m';
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  /// Durée formatée ex: "12 min"
  String get durationLabel {
    final minutes = (duration / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}