// src/home/presentation/pages/services/taxi_voiture_page.dart

import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/domain/models/course_model.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';
import 'package:djina_debug/src/home/domain/repositories/course_repository.dart';
import 'package:djina_debug/src/home/domain/services/routing_service.dart';
import 'package:djina_debug/src/home/presentation/pages/services/ride_confirmation_page.dart';
import 'package:djina_debug/src/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class TaxiVoiturePage extends StatefulWidget {
  final PlaceResult departure;
  final PlaceResult destination;

  const TaxiVoiturePage({
    super.key,
    required this.departure,
    required this.destination,
  });

  @override
  State<TaxiVoiturePage> createState() => _TaxiVoiturePageState();
}

class _TaxiVoiturePageState extends State<TaxiVoiturePage> {
  final CourseRepository _repo    = CourseRepository();
  final RoutingService   _routing = RoutingService();
  final MapController    _mapController = MapController();

  int  _selectedIndex = 0;
  bool _isConfirming  = false;

  // Itinéraire OSRM
  List<LatLng> _routePoints = [];
  RouteResult? _routeResult;
  bool _isLoadingRoute = true;

  final List<VehicleOption> _vehicles = TaxiVoitureOptions.options;

  LatLng get _depLatLng  =>
      LatLng(widget.departure.latitude,   widget.departure.longitude);
  LatLng get _destLatLng =>
      LatLng(widget.destination.latitude, widget.destination.longitude);
  LatLng get _center => LatLng(
    (widget.departure.latitude  + widget.destination.latitude)  / 2,
    (widget.departure.longitude + widget.destination.longitude) / 2,
  );

  double get _fallbackZoom {
    final dist = const Distance().call(_depLatLng, _destLatLng);
    if (dist < 1000)  return 15.0;
    if (dist < 5000)  return 13.5;
    if (dist < 15000) return 12.0;
    if (dist < 40000) return 10.5;
    return 9.0;
  }

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoadingRoute = true);

    final result = await _routing.getRoute(_depLatLng, _destLatLng);

    if (!mounted) return;
    setState(() {
      _routeResult  = result;
      _routePoints  = result?.points ?? [_depLatLng, _destLatLng];
      _isLoadingRoute = false;
    });

    // Ajuste le zoom pour englober tout l'itinéraire
    if (result != null && result.points.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
    }
  }

  void _fitRoute() {
    if (_routePoints.isEmpty) return;

    double minLat = _routePoints.first.latitude;
    double maxLat = _routePoints.first.latitude;
    double minLng = _routePoints.first.longitude;
    double maxLng = _routePoints.first.longitude;

    for (final p in _routePoints) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    final vehicle = _vehicles[_selectedIndex];

    final result = await _repo.createCourse(
      departureLat:     widget.departure.latitude,
      departureLng:     widget.departure.longitude,
      startingLandmark: widget.departure.shortName,
      destinationLat:   widget.destination.latitude,
      destinationLng:   widget.destination.longitude,
      arrivalLandmark:  widget.destination.shortName,
      initialPrice:     vehicle.price,
    );

    if (!mounted) return;
    setState(() => _isConfirming = false);

    if (result['success'] == true) {
      final courseId =
          (result['data'] as Map<String, dynamic>)['id']?.toString();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RideConfirmationPage(
            departure:    widget.departure,
            destination:  widget.destination,
            vehicle:      vehicle,
            courseId:     courseId,
            routePoints:  _routePoints,
            routeResult:  _routeResult,
          ),
        ),
      );

      if (context.mounted) {
        context.read<HomeProvider>().refreshRecentTrips();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de la commande'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Carte ──────────────────────────────────────────────────
          Expanded(
            flex: 55,
            child: Stack(
              children: [
                // Carte OSM
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom:   _fallbackZoom,
                    minZoom: 5,
                    maxZoom: 19,
                  ),
                  children: [
                    // Tuiles OSM style clair
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.djina.app',
                      maxZoom: 19,
                    ),

                    // ✅ Ombre portée de la route (épaisseur +4, opacité 20%)
                    if (_routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points:      _routePoints,
                            strokeWidth: 8,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                      ),

                    // ✅ Route principale orange
                    if (_routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points:      _routePoints,
                            strokeWidth: 5,
                            color:       AppTheme.cardColor,
                            borderColor: Colors.orange.shade700,
                            borderStrokeWidth: 1.5,
                          ),
                        ],
                      ),

                    // ── Marqueurs ──────────────────────────────────
                    MarkerLayer(
                      markers: [
                        // Départ — cercle orange pulsé
                        Marker(
                          point:  _depLatLng,
                          width:  48,
                          height: 48,
                          child:  _DepartureMarker(),
                        ),
                        // Destination — pin noir
                        Marker(
                          point:  _destLatLng,
                          width:  40,
                          height: 56,
                          child:  _DestinationMarker(),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Bouton retour ─────────────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: Colors.black87),
                      ),
                    ),
                  ),
                ),

                // ── Infos route (distance + durée) ────────────────
                if (_routeResult != null)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.route,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 5),
                              Text(
                                '${_routeResult!.distanceLabel}  ·  ${_routeResult!.durationLabel}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Spinner chargement route ──────────────────────
                if (_isLoadingRoute)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.orange),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Panneau bas ────────────────────────────────────────────
          Expanded(
            flex: 45,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -3)),
                ],
              ),
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Résumé trajet
                    _TripSummary(
                      departure:   widget.departure.shortName,
                      destination: widget.destination.shortName,
                    ),

                    const SizedBox(height: 20),

                    // Onglets
                    const _ServiceTabs(),

                    const SizedBox(height: 16),

                    // Cartes véhicule
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _vehicles.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, i) => _VehicleCard(
                          option:     _vehicles[i],
                          isSelected: _selectedIndex == i,
                          onTap: () =>
                              setState(() => _selectedIndex = i),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton Confirmer
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isConfirming ? null : _confirm,
                        child: _isConfirming
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text('Confirmer',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Marqueur départ — cercle orange avec anneau
// ─────────────────────────────────────────────────────────────────────────────
class _DepartureMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardColor.withOpacity(0.2),
        border: Border.all(color: AppTheme.cardColor, width: 2),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Marqueur destination — pin noir
// ─────────────────────────────────────────────────────────────────────────────
class _DestinationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black87,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.location_on,
              color: Colors.white, size: 20),
        ),
        // Petite pointe
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;

    final path = ui.Path(); // 👈 important

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Résumé trajet
// ─────────────────────────────────────────────────────────────────────────────
class _TripSummary extends StatelessWidget {
  final String departure;
  final String destination;
  const _TripSummary({required this.departure, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicateur visuel
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardColor,
                border: Border.all(color: Colors.orange.shade700, width: 1.5),
              ),
            ),
            Container(
              width: 2,
              height: 28,
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.cardColor, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const Icon(Icons.location_on, size: 16, color: Colors.black87),
          ],
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(departure,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                    color: Colors.grey[200], height: 1, thickness: 1),
              ),
              Text(destination,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),

        // Bouton + ajouter arrêt
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onglets
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceTabs extends StatelessWidget {
  const _ServiceTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Taxi-Voiture',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Container(
                height: 2.5,
                width: 90,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(2),
                )),
          ],
        ),
        const SizedBox(width: 24),
        const Opacity(
          opacity: 0.35,
          child: Text('Taxi-Moto',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte véhicule
// ─────────────────────────────────────────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final VehicleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
      required this.option,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.cardColor
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.cardColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Image.asset(
                option.imagePath,
                width: 60,
                height: 38,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_rounded,
                  size: 38,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : Colors.black87)),
                Text('F ${_fmt(option.price)}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black54)),
                Text('${option.etaMinutes} min',
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[400])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int p) => p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}