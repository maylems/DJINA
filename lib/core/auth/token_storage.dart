import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé des tokens JWT
class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  TokenStorage._internal();

  static const String _accessTokenKey  = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey     = 'user_type';
  static const String _phoneKey        = 'user_phone';
  static const String _emailKey        = 'user_email'; // ← nouveau

  /// Sauvegarder les tokens après connexion
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userType,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (userType != null) {
      await _storage.write(key: _userTypeKey, value: userType);
    }
  }

  /// Sauvegarder uniquement l'access token (après refresh)
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken()  async => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserType()     async => _storage.read(key: _userTypeKey);

  /// Sauvegarder le numéro de téléphone (pour OTP)
  Future<void> savePhone(String phone) async =>
      _storage.write(key: _phoneKey, value: phone);
  Future<String?> getPhone() async => _storage.read(key: _phoneKey);

  /// Sauvegarder l'email (utilisé comme identifiant de connexion)
  Future<void> saveEmail(String email) async =>
      _storage.write(key: _emailKey, value: email);
  Future<String?> getEmail() async => _storage.read(key: _emailKey);

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userTypeKey);
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _emailKey);
  }

  Future<void> clearAll() async => _storage.deleteAll();
}