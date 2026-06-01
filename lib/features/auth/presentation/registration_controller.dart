import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';

/// State management for the registration screen.
///
/// Manages the signup API call lifecycle and exposes
/// observable state for the UI to react to.
class RegistrationController extends ChangeNotifier {
  final AuthRepository _repository;

  RegistrationController({required this._repository});

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Attempts to create a new traveler account.
  ///
  /// Sets [isLoading] during the API call, [errorMessage] on failure,
  /// and [isSuccess] when the account is created.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      _isSuccess = true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
