// Repository pour gérer les opérations liées aux courses actives
// - Initier une course (appel chauffeur)
// - Suivre la position du chauffeur
// - Terminer une course
// - Soumettre une notation
// - Récupérer l'historique
import 'package:dio/dio.dart';
import 'package:djina_debug/core/api/api_client.dart';
import 'package:djina_debug/core/api/api_endpoints.dart';
import 'package:djina_debug/src/home/domain/models/ride/ride_model.dart';
import 'package:djina_debug/src/home/domain/models/ride/rating_model.dart';
import 'package:djina_debug/src/home/domain/models/ride/driver_location_model.dart';

abstract class RideRepository {
  Future<Ride> initiateRide({
    required String pickupLat,
    required String pickupLng,
    required String pickupAddress,
    String? destinationLat,
    String? destinationAddress,
    String serviceType,
  });

  Stream<DriverLocation> streamDriverLocation(String rideId);

  Future<void> startRide(String rideId);

  Future<void> completeRide(String rideId, {double? fare});

  Future<void> cancelRide(String rideId);

  Future<bool> submitRating(String rideId, Rating rating);

  Future<Ride?> getActiveRide(String userId);
}

class RideRepositoryImpl implements RideRepository {
  final ApiClient _apiClient;

  RideRepositoryImpl(this._apiClient);

  @override
  Future<Ride> initiateRide({
    required String pickupLat,
    required String pickupLng,
    required String pickupAddress,
    String? destinationLat,
    String? destinationAddress,
    String serviceType = 'taxi',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.initiateRide,
        data: {
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'pickup_address': pickupAddress,
          'destination_lat': destinationLat,
          'destination_address': destinationAddress,
          'service_type': serviceType,
        },
      );

      // Parse response to Ride model (adjust based on actual API response)
      final data = response.data as Map<String, dynamic>;
      return Ride.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to initiate ride: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse ride data: $e');
    }
  }

  @override
  Stream<DriverLocation> streamDriverLocation(String rideId) {
    // WebSocket or polling for live driver location
    // Return a stream that emits location updates
    // TODO: Implement real WebSocket or polling mechanism
    return const Stream.empty();
  }

  @override
  Future<void> startRide(String rideId) async {
    await _apiClient.dio.post(ApiEndpoints.startRide(rideId));
  }

  @override
  Future<void> completeRide(String rideId, {double? fare}) async {
    await _apiClient.dio.post(
      ApiEndpoints.completeRide(rideId),
      data: fare != null ? {'final_fare': fare} : null,
    );
  }

  @override
  Future<void> cancelRide(String rideId) async {
    await _apiClient.dio.post(ApiEndpoints.cancelRide(rideId));
  }

  @override
  Future<bool> submitRating(String rideId, Rating rating) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.submitRating,
        data: {
          'ride_id': rideId,
          'stars': rating.stars,
          'comment': rating.comment,
          'tags': rating.tags,
          'is_payment_issue': rating.isPaymentIssue,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Ride?> getActiveRide(String userId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.getActiveRide(userId));
      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;
      return Ride.fromJson(data);
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }
}
