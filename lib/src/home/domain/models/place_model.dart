// src/home/domain/models/place_model.dart

class PlaceResult {
  final String displayName;
  final String shortName;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.displayName,
    required this.shortName,
    required this.latitude,
    required this.longitude,
  });

  // ── Photon (GeoJSON feature) ─────────────────────────────────────────────
  factory PlaceResult.fromPhoton(Map<String, dynamic> feature) {
    final props    = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry']   as Map<String, dynamic>? ?? {};
    final coords   = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    // GeoJSON : [longitude, latitude]
    final double lng = _r6((coords[0] as num).toDouble());
    final double lat = _r6((coords[1] as num).toDouble());

    final name     = props['name']     as String? ?? '';
    final district = props['district'] as String? ?? '';
    final city     = props['city']     as String?
        ?? props['town']    as String?
        ?? props['village'] as String? ?? '';
    final street   = props['street']   as String? ?? '';

    final List<String> parts = [];
    if (name.isNotEmpty)        parts.add(name);
    else if (street.isNotEmpty) parts.add(street);
    if (district.isNotEmpty && district != name)  parts.add(district);
    else if (city.isNotEmpty && city != name)      parts.add(city);

    final shortName =
        parts.isNotEmpty ? parts.take(2).join(', ') : 'Lieu inconnu';

    final fullParts = [
      if (name.isNotEmpty)                     name,
      if (street.isNotEmpty && street != name)  street,
      if (district.isNotEmpty)                  district,
      if (city.isNotEmpty)                      city,
      props['state']   as String? ?? '',
      props['country'] as String? ?? '',
    ].where((s) => s.isNotEmpty).toList();

    return PlaceResult(
      displayName: fullParts.join(', '),
      shortName:   shortName,
      latitude:    lat,
      longitude:   lng,
    );
  }

  // ── Nominatim (rétrocompatibilité) ───────────────────────────────────────
  factory PlaceResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};

    final parts = <String>[
      address['road']   as String? ?? '',
      address['suburb'] as String?
          ?? address['neighbourhood'] as String? ?? '',
      address['city']   as String?
          ?? address['town']    as String?
          ?? address['village'] as String? ?? '',
    ].where((s) => s.isNotEmpty).toList();

    final shortName = parts.isNotEmpty
        ? parts.take(2).join(', ')
        : (json['display_name'] as String).split(',').first;

    return PlaceResult(
      displayName: json['display_name'] as String,
      shortName:   shortName,
      latitude:    _r6(double.parse(json['lat'] as String)),
      longitude:   _r6(double.parse(json['lon'] as String)),
    );
  }

  /// Arrondit à 6 décimales max (contrainte API Django)
  static double _r6(double v) => double.parse(v.toStringAsFixed(6));

  @override
  String toString() => shortName;
}