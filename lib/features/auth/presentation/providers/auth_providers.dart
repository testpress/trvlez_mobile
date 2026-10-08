import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';

export 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart'
    show authRepositoryProvider;
export 'package:trvlez_mobile/features/auth/domain/entities/signup_result.dart';
export 'package:trvlez_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Provider for the login async notifier.
final loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginNotifier, void>(
      () => LoginNotifier(),
    );

/// Alias for [loginControllerProvider].
final loginNotifierProvider = loginControllerProvider;

/// State management for the login screen.
class LoginNotifier extends AutoDisposeAsyncNotifier<void> {
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

  /// Clears the current error state.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for the registration async notifier.
final registrationControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegistrationNotifier, void>(
      () => RegistrationNotifier(),
    );

/// Alias for [registrationControllerProvider].
final registrationNotifierProvider = registrationControllerProvider;

/// State management for the registration screen.
class RegistrationNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Attempts to create a new traveler account.
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(email: email, password: password);
    });
  }

  /// Clears the current error state.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}
