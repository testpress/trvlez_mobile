import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';

/// Manages global authentication state for the application.
class AuthNotifier extends ChangeNotifier {
  final TokenStorage tokenStorage;
  
  bool isAuthenticated = false;

  AuthNotifier({required this.tokenStorage});

  /// Checks secure storage for an existing token and updates state.
  Future<void> checkAuthStatus() async {
    final token = await tokenStorage.getToken();
    isAuthenticated = token != null;
    notifyListeners();
  }

  /// Marks the user as logged in. Should be called after successful login.
  void setAuthenticated() {
    isAuthenticated = true;
    notifyListeners();
  }

  /// Logs the user out by deleting the token and updating state.
  Future<void> logout() async {
    await tokenStorage.deleteToken();
    isAuthenticated = false;
    notifyListeners();
  }
}
