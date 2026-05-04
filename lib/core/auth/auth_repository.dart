import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';
import 'token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  // ============================================================
  // CONNEXION
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.tokenObtain,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;

        // ── Nouveau format standardisé ──────────────────────────
        if (body['success'] == true && body['data'] != null) {
          final tokenData = body['data'] as Map<String, dynamic>;
          await _tokenStorage.saveTokens(
            accessToken: tokenData['token'] ?? tokenData['access'] ?? '',
            refreshToken: tokenData['refresh'] ?? '',
            userType: tokenData['user']?['role'],
          );
          return {
            'success': true,
            'message': body['message'] ?? 'Connexion réussie',
            'user': tokenData['user'],
          };
        }

        // ── Ancien format SimpleJWT : { "access": "...", "refresh": "..." } ──
        if (body.containsKey('access')) {
          await _tokenStorage.saveTokens(
            accessToken: body['access'],
            refreshToken: body['refresh'] ?? '',
            userType: body['user_type'],
          );
          return {
            'success': true,
            'message': 'Connexion réussie',
            'user': null,
          };
        }

        return {'success': false, 'message': 'Format de réponse inattendu'};
      }

      return {'success': false, 'message': 'Erreur de connexion'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ============================================================
  // INSCRIPTION CLIENT
  // ============================================================

  Future<Map<String, dynamic>> registerCustomer({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    String? referralCode,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.registerCustomer,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );

      if (response.statusCode == 201) {
        await _tokenStorage.savePhone(phone);
        await _tokenStorage.saveEmail(email);
        final body = response.data as Map<String, dynamic>;
        return {
          'success': body['success'] == true,
          'message': body['message'] ?? 'Inscription réussie',
          'phone': phone,
          'email': email,
        };
      }

      return {'success': false, 'message': 'Erreur d\'inscription'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ============================================================
  // INSCRIPTION CHAUFFEUR
  // ============================================================

  Future<Map<String, dynamic>> registerDriver({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String? referralCode,
  }) async {
    try {
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _apiClient.dio.post(
        ApiEndpoints.registerDriver,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );

      if (response.statusCode == 201) {
        await _tokenStorage.savePhone(phone);
        await _tokenStorage.saveEmail(email);
        final body = response.data as Map<String, dynamic>;
        return {
          'success': body['success'] == true,
          'message': body['message'] ?? 'Inscription réussie',
          'phone': phone,
          'email': email,
        };
      }

      return {'success': false, 'message': 'Erreur d\'inscription'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ============================================================
  // OTP
  // ============================================================

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.otpRequest,
        data: {'phone': phone},
      );
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        await _tokenStorage.savePhone(phone);
        return {
          'success': body['success'] == true,
          'message': body['message'] ?? 'Code OTP envoyé',
        };
      }
      return {'success': false, 'message': 'Erreur d\'envoi OTP'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return {
          'success': false,
          'message': 'Veuillez patienter avant de renvoyer un code',
        };
      }
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.otpVerify,
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        return {
          'success': body['success'] == true,
          'message': body['message'] ?? 'Téléphone vérifié',
          // ✅ données dans body['data']
          'phone_verified': body['data']?['phone_verified'] ?? true,
        };
      }
      return {'success': false, 'message': 'Code invalide'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.otpLogin,
        data: {'phone': phone, 'code': code},
      );
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final tokenData = body['data'] as Map<String, dynamic>;
          await _tokenStorage.saveTokens(
            accessToken: tokenData['token'] ?? '',
            refreshToken: tokenData['refresh'] ?? '',
            userType: tokenData['user']?['role'],
          );
          return {
            'success': true,
            'message': body['message'] ?? 'Connexion réussie',
            'user': tokenData['user'],
          };
        }
        return {
          'success': false,
          'message': body['message'] ?? 'Format de réponse invalide',
        };
      }
      return {'success': false, 'message': 'Code invalide'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> resendOtp() async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.otpResend);
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        return {
          'success': body['success'] == true,
          'message': body['message'] ?? 'Code renvoyé',
        };
      }
      return {'success': false, 'message': 'Erreur de renvoi'};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ============================================================
  // UTILISATEUR CONNECTÉ
  // ✅ Fix principal : extraire body['data'] avant UserModel.fromJson
  // ============================================================

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.authMe);
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;

        // ✅ Nouveau format : { "success": true, "data": { ...user... } }
        if (body['success'] == true && body['data'] != null) {
          return UserModel.fromJson(body['data'] as Map<String, dynamic>);
        }

        // ✅ Fallback ancien format : réponse directe sans enveloppe
        return UserModel.fromJson(body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getSavedEmail() async => _tokenStorage.getEmail();
  Future<bool> isAuthenticated() async => _tokenStorage.isAuthenticated();
  Future<void> logout() async => _tokenStorage.clearTokens();

  // ============================================================
  // GESTION DES ERREURS
  // ============================================================

  String _translateError(String raw) {
    const map = {
      'No active account found with the given credentials':
          'Email ou mot de passe incorrect.',
      'This field may not be blank.': 'Ce champ est obligatoire.',
      'This field is required.': 'Ce champ est obligatoire.',
      'A user with that username already exists.': 'Ce compte existe déjà.',
      'Enter a valid email address.': 'Adresse email invalide.',
      'This password is too short.': 'Mot de passe trop court (8 caractères min).',
      'This password is too common.': 'Mot de passe trop simple.',
    };
    for (final entry in map.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }
    return raw;
  }

  Map<String, dynamic> _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        // ✅ Nouveau format : message dans 'message'
        for (final key in ['message', 'detail', 'error']) {
          if (data.containsKey(key) && data[key] != null) {
            return {
              'success': false,
              'message': _translateError(data[key].toString()),
            };
          }
        }
        if (data.keys.isNotEmpty) {
          final value = data[data.keys.first];
          final msg = value is List && value.isNotEmpty
              ? value.first.toString()
              : value.toString();
          return {'success': false, 'message': _translateError(msg)};
        }
      }
      return {'success': false, 'message': 'Une erreur est survenue'};
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return {'success': false, 'message': 'Délai de connexion dépassé'};
    }
    if (error.type == DioExceptionType.connectionError) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
    return {'success': false, 'message': 'Erreur inconnue'};
  }
}