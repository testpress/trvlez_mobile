import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
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

    TravelerVerificationState initialState =
        TravelerVerificationState.profilePending;
    if (isAuthenticated) {
      try {
        final profile = await ref.read(profileRepositoryProvider).getProfile();
        initialState = profile.verificationState;
      } catch (_) {
        // Fallback to profilePending if profile cannot be fetched immediately
      }
    }

    return AuthState(
      isAuthenticated: isAuthenticated,
      verificationState: initialState,
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

  /// Sets authenticated state upon successful login.
  ///
  /// Atomically updates [state] to [AsyncData] with [AuthState.isAuthenticated]
  /// set to `true`, avoiding intermediate unauthenticated / loading flickers,
  /// and initiates an asynchronous refresh of verification state.
  Future<void> onLoginSuccess() async {
    state = const AsyncData(
      AuthState(
        isAuthenticated: true,
        verificationState: TravelerVerificationState.profilePending,
      ),
    );
    ref.invalidate(finderNotifierProvider);
    ref.invalidate(findrPortfolioProvider);
    unawaited(refreshVerificationState());
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

    // Reset Findr activation state in settings and providers
    try {
      await ref.read(settingsRepositoryProvider).setFindrActivated(false);
    } catch (_) {}
    ref.invalidate(finderNotifierProvider);
    ref.invalidate(findrPortfolioProvider);

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
/// and the verification flow notifier so that verified or failed transitions
/// are immediately reflected across the entire application.
final travelerVerificationStateProvider = Provider<TravelerVerificationState>((
  ref,
) {
  final profileState = ref.watch(currentProfileProvider);
  final profile = profileState.valueOrNull;
  final baseState =
      profile?.verificationState ?? TravelerVerificationState.profilePending;

  final verificationState = ref.watch(verificationNotifierProvider);
  final verificationStatus = ref.watch(verificationStatusProvider).valueOrNull;

  // Derive effective state from the verification flow notifier
  var state = verificationState.effectiveState(baseState);

  // If the server-side verification status endpoint reports status, respect it
  if (verificationStatus != null) {
    if (verificationStatus.isVerified) {
      state = TravelerVerificationState.verified;
    } else if (verificationStatus.isFailed &&
        baseState != TravelerVerificationState.verified) {
      state = TravelerVerificationState.failed;
    } else if (verificationStatus.isProcessing) {
      state = TravelerVerificationState.submitted;
    } else if (verificationStatus.isUploaded &&
        state == TravelerVerificationState.profilePending) {
      state = TravelerVerificationState.documentsUploaded;
    }
  }

  return state;
});

/// Indicates whether the traveler has completed KYC verification and is approved.
final isKycVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(travelerVerificationStateProvider).isVerified;
});
