import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

export 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
export 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart'
    show currentProfileProvider, profileRepositoryProvider;

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

    return AuthState(
      isAuthenticated: isAuthenticated,
      verificationState: TravelerVerificationState.profilePending,
    );
  }

  /// Refreshes just the verification state from the backend.
  Future<void> refreshVerificationState() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isAuthenticated) return;

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final profile = await profileRepository.getProfile();
      state = AsyncData(
        currentState.copyWith(verificationState: profile.verificationState),
      );
    } catch (_) {
      // Silently fail — existing state remains valid
    }
  }

  /// Logs the user out by deleting the token and invalidating state.
  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.deleteToken();

    state = const AsyncData(
      AuthState(
        isAuthenticated: false,
        verificationState: TravelerVerificationState.profilePending,
      ),
    );

    // Reset verification state first (stops polling, clears in-memory data)
    ref.read(verificationNotifierProvider.notifier).reset();

    // Invalidate feature providers to clear sensitive data
    ref.invalidate(propertiesProvider);
    ref.invalidate(reservationListProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(verificationStatusProvider);
    ref.invalidate(verificationNotifierProvider);
  }
}

/// Computes the active traveler verification state.
///
/// Combines the profile's onboarding step with the verification session status
/// so that a submitted session marked as failed in the verification service
/// transitions the state to [TravelerVerificationState.failed].
final travelerVerificationStateProvider = Provider<TravelerVerificationState>((
  ref,
) {
  final profileState = ref.watch(currentProfileProvider);
  final profile = profileState.valueOrNull;
  final verificationStatus = ref.watch(verificationStatusProvider).valueOrNull;

  TravelerVerificationState state =
      profile?.verificationState ?? TravelerVerificationState.profilePending;
  if (state == TravelerVerificationState.submitted &&
      verificationStatus?.isFailed == true) {
    state = TravelerVerificationState.failed;
  }
  return state;
});

/// Indicates whether the traveler has completed KYC verification and is approved.
final isKycVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(travelerVerificationStateProvider).isVerified;
});
