import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/auth/data/auth_repository.dart';

/// Provider for the [LoginController].
final loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginController, void>(
      () => LoginController(),
    );

/// State management for the login screen.
///
/// Manages the login API call lifecycle and exposes
/// observable state for the UI to react to.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Attempts to log in an existing traveler.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email: email, password: password);
      ref.invalidate(authNotifierProvider);
    });
  }

  /// Clears the current error message.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}
