import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

/// State management for the registration screen.
///
/// Manages the signup API call lifecycle and exposes
/// observable state for the UI to react to.
class RegistrationController extends ChangeNotifier {
  final AuthRepository repository;

  RegistrationController({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  /// Attempts to create a new traveler account.
  ///
  /// Sets [isLoading] during the API call, [errorMessage] on failure,
  /// and [isSuccess] when the account is created.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      await repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

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
