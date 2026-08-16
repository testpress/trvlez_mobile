import 'package:flutter/foundation.dart';

import 'package:trvlez_mobile/core/storage/token_storage.dart';import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
/// Manages global authentication state for the application.
///
/// Also caches the traveler's [verificationState] so the router can make
/// synchronous redirect decisions without an extra async fetch.
class AuthNotifier extends ChangeNotifier {
  final TokenStorage tokenStorage;
  final ProfileRepository? profileRepository;
  final VoidCallback? onLogout;

  bool isAuthenticated = false;

  /// Cached verification state — loaded during [checkAuthStatus].
  /// Defaults to [TravelerVerificationState.profilePending] until the
  /// profile is successfully fetched.
  TravelerVerificationState verificationState =
      TravelerVerificationState.profilePending;

  AuthNotifier({
    required this.tokenStorage,
    this.profileRepository,
    this.onLogout,
  });

  /// Checks secure storage for an existing token and updates state.
  ///
  /// If a token exists and a [ProfileRepository] is available, also fetches
  /// the profile to cache the current [verificationState].
  Future<void> checkAuthStatus() async {
    final token = await tokenStorage.getToken();
    isAuthenticated = token != null;

    if (isAuthenticated && profileRepository != null) {
      try {
        final profile = await profileRepository!.getProfile();
        verificationState = profile.verificationState;
      } catch (_) {
        // If profile fetch fails, keep default — router will send to onboarding
        // which will attempt its own profile load.
      }
    }

    notifyListeners();
  }

  /// Refreshes just the verification state from the backend.
  ///
  /// Used after onboarding steps to update the router's redirect target
  /// without a full auth re-check.
  Future<void> refreshVerificationState() async {
    if (!isAuthenticated || profileRepository == null) return;

    try {
      final profile = await profileRepository!.getProfile();
      verificationState = profile.verificationState;
      notifyListeners();
    } catch (_) {
      // Silently fail — existing state remains valid
    }
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
    verificationState = TravelerVerificationState.profilePending;
    onLogout?.call();
    notifyListeners();
  }
}
