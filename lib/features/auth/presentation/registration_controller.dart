import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/auth/data/auth_repository.dart';

/// Provider for the [RegistrationController].
final registrationControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegistrationController, void>(
  () => RegistrationController(),
);

/// State management for the registration screen.
///
/// Manages the signup API call lifecycle and exposes
/// observable state for the UI to react to.
class RegistrationController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Attempts to create a new traveler account.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(
        email: email,
        password: password,
      );
    });
  }

  /// Clears the current error message.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}
