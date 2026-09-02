import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores and retrieves authentication tokens.
class TokenStorage {
  final FlutterSecureStorage storage;
  String? _cachedToken;

  static const String accessTokenKey = 'access_token';

  TokenStorage({FlutterSecureStorage? storage, String? initialToken})
    : storage = storage ?? const FlutterSecureStorage(),
      _cachedToken = initialToken;

  /// Saves the access token to secure storage.
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await storage.write(key: accessTokenKey, value: token);
  }

  /// Retrieves the access token from secure storage.
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await storage.read(key: accessTokenKey);
    return _cachedToken;
  }

  /// Deletes the access token from secure storage.
  Future<void> deleteToken() async {
    _cachedToken = null;
    await storage.delete(key: accessTokenKey);
  }
}
