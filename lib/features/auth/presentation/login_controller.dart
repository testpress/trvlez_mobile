import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

/// State management for the login screen.
///
/// Manages the login API call lifecycle and exposes
/// observable state for the UI to react to.
class LoginController extends ChangeNotifier {
  final AuthRepository repository;
  final AuthNotifier authNotifier;

  LoginController({required this.repository, required this.authNotifier});

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  /// Attempts to log in an existing traveler.
  ///
  /// Sets [isLoading] during the API call, [errorMessage] on failure,
  /// and [isSuccess] when the login is successful.
  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      await repository.login(email: email, password: password);

      await authNotifier.checkAuthStatus();
      isSuccess = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current error message.
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
