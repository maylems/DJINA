// src/home/presentation/providers/home_provider.dart

import 'package:flutter/foundation.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';

import '../pages/services/location_service.dart';
import '../pages/services/place_search_service.dart';

class HomeProvider extends ChangeNotifier {
  final LocationService    _locationService = LocationService();
  final PlaceSearchService _searchService   = PlaceSearchService();

  PlaceResult? _departurePlace;
  PlaceResult? _destinationPlace;
  String  _selectedService  = 'taxi_voiture';
  bool    _isLoading        = false;
  bool    _isLocating       = false;

  // Position GPS de l'utilisateur
  double? _userLat;
  double? _userLng;

  // ✅ Clé incrémentée pour forcer RecentTrips à se recharger
  int _tripsRefreshKey = 0;

  HomeProvider() {
    _initLocation();
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  PlaceResult? get departurePlace   => _departurePlace;
  PlaceResult? get destinationPlace => _destinationPlace;
  String       get selectedService  => _selectedService;
  bool         get isLoading        => _isLoading;
  bool         get isLocating       => _isLocating;
  double?      get userLat          => _userLat;
  double?      get userLng          => _userLng;

  /// RecentTrips écoute cette valeur pour se recharger
  int get tripsRefreshKey => _tripsRefreshKey;

  bool get canSearch =>
      _departurePlace != null && _destinationPlace != null;

  // ── GPS ──────────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    _isLocating = true;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        _userLat = pos.latitude;
        _userLng = pos.longitude;

        final place =
            await _searchService.reverse(pos.latitude, pos.longitude);
        if (place != null) _departurePlace = place;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Location init error: $e');
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  // ── Recherche de lieux ────────────────────────────────────────────────────

  Future<List<PlaceResult>> searchPlaces(String query) {
    return _searchService.search(
      query,
      userLat: _userLat,
      userLng: _userLng,
    );
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  void setDeparturePlace(PlaceResult place) {
    _departurePlace = place;
    notifyListeners();
  }

  void setDestinationPlace(PlaceResult place) {
    _destinationPlace = place;
    notifyListeners();
  }

  void selectService(String serviceType) {
    _selectedService = serviceType;
    notifyListeners();
  }

  Future<void> searchRide() async {
    if (!canSearch) return;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Incrémente la clé → RecentTrips se recharge automatiquement
  void refreshRecentTrips() {
    _tripsRefreshKey++;
    notifyListeners();
  }

  void clearSearch() {
    _departurePlace   = null;
    _destinationPlace = null;
    notifyListeners();
  }
}