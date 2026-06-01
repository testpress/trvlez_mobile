import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores and retrieves authentication tokens.
class TokenStorage {
  final FlutterSecureStorage storage;
  
  static const String accessTokenKey = 'access_token';

  const TokenStorage({FlutterSecureStorage? storage}) 
      : storage = storage ?? const FlutterSecureStorage();

  /// Saves the access token to secure storage.
  Future<void> saveToken(String token) async {
    await storage.write(key: accessTokenKey, value: token);
  }

  /// Retrieves the access token from secure storage.
  Future<String?> getToken() async {
    return await storage.read(key: accessTokenKey);
  }

  /// Deletes the access token from secure storage.
  Future<void> deleteToken() async {
    await storage.delete(key: accessTokenKey);
  }
}
