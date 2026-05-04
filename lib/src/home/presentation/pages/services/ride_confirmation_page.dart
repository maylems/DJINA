// src/home/presentation/pages/services/ride_confirmation_page.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/domain/models/course_model.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';
import 'package:djina_debug/src/home/domain/repositories/course_repository.dart';
import 'package:djina_debug/src/home/domain/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RideConfirmationPage extends StatefulWidget {
  final PlaceResult   departure;
  final PlaceResult   destination;
  final VehicleOption vehicle;
  final String?       courseId;
  // ✅ Reçoit l'itinéraire calculé depuis TaxiVoiturePage (pas de double requête)
  final List<LatLng>  routePoints;
  final RouteResult?  routeResult;

  const RideConfirmationPage({
    super.key,
    required this.departure,
    required this.destination,
    required this.vehicle,
    required this.routePoints,
    this.courseId,
    this.routeResult,
  });

  @override
  State<RideConfirmationPage> createState() => _RideConfirmationPageState();
}

class _RideConfirmationPageState extends State<RideConfirmationPage> {
  final CourseRepository _repo = CourseRepository();
  final MapController _mapController = MapController();

  bool _isCancelling = false;
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = 5 * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  LatLng get _depLatLng  =>
      LatLng(widget.departure.latitude,   widget.departure.longitude);
  LatLng get _destLatLng =>
      LatLng(widget.destination.latitude, widget.destination.longitude);
  LatLng get _center => LatLng(
    (widget.departure.latitude  + widget.destination.latitude)  / 2,
    (widget.departure.longitude + widget.destination.longitude) / 2,
  );

  void _fitRoute() {
    final points = widget.routePoints.isNotEmpty
        ? widget.routePoints
        : [_depLatLng, _destLatLng];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
      ),
    );
  }

  Future<void> _cancelCourse() async {
    if (_isCancelling) return;
    setState(() => _isCancelling = true);

    if (widget.courseId != null) {
      final result = await _repo.cancelCourse(widget.courseId!);
      if (!mounted) return;

      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur d\'annulation'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isCancelling = false);
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == '/home');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final routePoints = widget.routePoints.isNotEmpty
        ? widget.routePoints
        : [_depLatLng, _destLatLng];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Carte ─────────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom:   13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                             InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.djina.app',
                    ),
                    // Ombre route
                    PolylineLayer(polylines: [
                      Polyline(
                        points:      routePoints,
                        strokeWidth: 8,
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ]),
                    // Route principale
                    PolylineLayer(polylines: [
                      Polyline(
                        points:           routePoints,
                        strokeWidth:      5,
                        color:            AppTheme.cardColor,
                        borderColor:      Colors.orange.shade700,
                        borderStrokeWidth: 1.5,
                      ),
                    ]),
                    MarkerLayer(markers: [
                      // Départ
                      Marker(
                        point:  _depLatLng,
                        width:  48,
                        height: 48,
                        child:  _DepartureMarker(),
                      ),
                      // Destination
                      Marker(
                        point:  _destLatLng,
                        width:  40,
                        height: 56,
                        child:  _DestinationMarker(),
                      ),
                    ]),
                  ],
                ),

                // Bouton retour
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

                // Countdown
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
                                blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.orange),
                            const SizedBox(width: 5),
                            Text(_formattedTime,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panneau bas ───────────────────────────────────────────
          Expanded(
            flex: 5,
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
                    EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
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

                    // Résumé adresses
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cardColor,
                                border: Border.all(
                                    color: Colors.orange.shade700,
                                    width: 1.5),
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 22,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.cardColor,
                                    Colors.black87
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.black87),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.departure.shortName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Divider(
                                    color: Colors.grey[200],
                                    height: 1,
                                    thickness: 1),
                              ),
                              Text(widget.destination.shortName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Infos véhicule
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.vehicle.label,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text('F ${widget.vehicle.price}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.routeResult != null
                                    ? '${widget.routeResult!.distanceLabel}  ·  ${widget.routeResult!.durationLabel}'
                                    : 'Arrivée estimée : ${widget.vehicle.etaMinutes} min',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          height: 70,
                          child: Image.asset(
                            widget.vehicle.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.directions_car_rounded,
                                size: 60,
                                color: Colors.grey[300]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Bouton Annuler
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isCancelling ? null : _cancelCourse,
                        child: _isCancelling
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Annuler la course',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
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
// Marqueurs identiques à TaxiVoiturePage
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
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
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