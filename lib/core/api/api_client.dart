import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/token_storage.dart';
import 'api_endpoints.dart';

/// Client HTTP centralisé avec intercepteurs pour les tokens JWT
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour ajouter automatiquement le token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          if (kDebugMode) {
            print('🌐 REQUEST[${options.method}] => ${options.uri}');
            print('📤 DATA: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
            print('📥 DATA: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
            print('📛 MESSAGE: ${error.message}');
            print('📛 DATA: ${error.response?.data}');
          }

          // Gestion du token expiré (401)
          if (error.response?.statusCode == 401) {
            // Tentative de refresh du token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry la requête originale
              return handler.resolve(await _retry(error.requestOptions));
            } else {
              // Déconnexion forcée
              await _tokenStorage.clearTokens();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Rafraîchir le token d'accès
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access'];
        await _tokenStorage.saveAccessToken(accessToken);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Token refresh failed: $e');
    }
    return false;
  }

  /// Retry une requête après refresh du token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}