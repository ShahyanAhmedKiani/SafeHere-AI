import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for JWT persistence (Keychain on iOS, Keystore on Android).
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<String?> get accessToken => _storage.read(key: _accessKey);
  static Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
