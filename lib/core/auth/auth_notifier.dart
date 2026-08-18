import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

class AuthState {
  final bool isAuthenticated;
  final TravelerVerificationState verificationState;

  const AuthState({
    required this.isAuthenticated,
    required this.verificationState,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    TravelerVerificationState? verificationState,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      verificationState: verificationState ?? this.verificationState,
    );
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getToken();
    final isAuthenticated = token != null;

    TravelerVerificationState verificationState = TravelerVerificationState.profilePending;

    if (isAuthenticated) {
      try {
        final profileRepository = ref.read(profileRepositoryProvider);
        final profile = await profileRepository.getProfile();
        verificationState = profile.verificationState;
      } catch (_) {
        // If profile fetch fails, keep default — router will send to onboarding
      }
    }

    return AuthState(
      isAuthenticated: isAuthenticated,
      verificationState: verificationState,
    );
  }

  /// Refreshes just the verification state from the backend.
  Future<void> refreshVerificationState() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isAuthenticated) return;

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final profile = await profileRepository.getProfile();
      state = AsyncData(currentState.copyWith(
        verificationState: profile.verificationState,
      ));
    } catch (_) {
      // Silently fail — existing state remains valid
    }
  }

  /// Logs the user out by deleting the token and invalidating state.
  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.deleteToken();
    
    state = const AsyncData(AuthState(
      isAuthenticated: false,
      verificationState: TravelerVerificationState.profilePending,
    ));

    // Invalidate feature providers to clear sensitive data
    ref.invalidate(propertiesProvider);
    ref.invalidate(reservationListProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(verificationStatusProvider);
    // Note: We don't have verificationNotifierProvider yet.
  }
}
