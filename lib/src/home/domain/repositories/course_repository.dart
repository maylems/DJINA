// src/home/data/repositories/course_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:djina_debug/core/api/api_client.dart';

class CourseRepository {
  final ApiClient _apiClient = ApiClient();

  // ── POST /api/courses/ ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> createCourse({
    required double departureLat,
    required double departureLng,
    required String startingLandmark,
    required double destinationLat,
    required double destinationLng,
    required String arrivalLandmark,
    required int    initialPrice,
  }) async {
    final payload = {
      'departure_latitude':    departureLat,
      'departure_longitude':   departureLng,
      'starting_landmark':     startingLandmark,
      'destination_latitude':  destinationLat,
      'destination_longitude': destinationLng,
      'arrival_landmark':      arrivalLandmark,
      'initial_price':         initialPrice,
    };

    if (kDebugMode) debugPrint('📦 createCourse: $payload');

    try {
      final response =
          await _apiClient.dio.post('/api/courses/', data: payload);

      if (kDebugMode) {
        debugPrint('✅ ${response.statusCode}: ${response.data}');
      }

      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {
        'success': false,
        'message': 'Erreur serveur (${response.statusCode})'
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── POST /api/courses/{id}/cancel/ ─────────────────────────────────────
  Future<Map<String, dynamic>> cancelCourse(String courseId) async {
    try {
      final response =
          await _apiClient.dio.post('/api/courses/$courseId/cancel/');
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Impossible d\'annuler'};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ── GET /api/courses/ — 5 dernières completed ──────────────────────────
  Future<List<Map<String, dynamic>>> getCompletedCourses() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/courses/',
        queryParameters: {'status': 'completed'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;

        if (data is Map && data.containsKey('results')) {
          list = data['results'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else {
          return [];
        }

        final courses = list
            .cast<Map<String, dynamic>>()
            .where((c) => c['status'] == 'completed')
            .toList()
          ..sort((a, b) {
            final dateA = DateTime.tryParse(
                    a['completed_at'] as String? ?? '') ??
                DateTime(0);
            final dateB = DateTime.tryParse(
                    b['completed_at'] as String? ?? '') ??
                DateTime(0);
            return dateB.compareTo(dateA);
          });

        return courses.take(5).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (kDebugMode) {
      debugPrint(
          '❌ DioException ${e.response?.statusCode}: ${e.response?.data}');
    }

    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final buffer = StringBuffer();
        data.forEach((k, v) {
          buffer.write('$k: ${v is List ? v.join(', ') : v}  ');
        });
        final msg = buffer.toString().trim();
        if (msg.isNotEmpty) return {'success': false, 'message': msg};
      }
      if (data is String && data.isNotEmpty) {
        return {'success': false, 'message': data};
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout =>
        {'success': false, 'message': 'Impossible de joindre le serveur'},
      DioExceptionType.receiveTimeout =>
        {'success': false, 'message': 'Le serveur ne répond pas'},
      _ => {
          'success': false,
          'message': 'Erreur (${e.response?.statusCode ?? 'réseau'})'
        },
    };
  }
}