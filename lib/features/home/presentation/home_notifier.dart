import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';
import '../../profile/domain/traveler_verification_state.dart';
import '../../verification/data/verification_repository.dart';
import '../../verification/domain/verification_status.dart';

/// Manages state for the home screen.
///
/// Loads the traveler's profile and verification session status to determine
/// the correct banner state. The verification session status is needed to
/// detect the `failed` state which only exists on [VerificationSessionStatus],
/// not on [TravelerOnboardingStep].
class HomeNotifier extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final VerificationRepository _verificationRepository;

  HomeNotifier({
    required ProfileRepository profileRepository,
    VerificationRepository? verificationRepository,
  })  : _profileRepository = profileRepository,
        _verificationRepository =
            verificationRepository ?? VerificationRepository();

  bool _isLoading = false;
  String? _errorMessage;
  Profile? _profile;
  VerificationStatus? _verificationStatus;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  /// The effective verification state, accounting for the session-level
  /// `failed` status that the onboarding step doesn't capture.
  ///
  /// When the onboarding step is `submitted`, we also check the
  /// verification session status — if it's `failed`, we override to
  /// [TravelerVerificationState.failed].
  TravelerVerificationState get verificationState {
    final profileState =
        _profile?.verificationState ?? TravelerVerificationState.profilePending;

    // The backend's TravelerOnboardingStep stays at "submitted" even when
    // VerificationSessionStatus transitions to "failed". Detect this case.
    if (profileState == TravelerVerificationState.submitted &&
        _verificationStatus != null &&
        _verificationStatus!.isFailed) {
      return TravelerVerificationState.failed;
    }

    return profileState;
  }

  /// Whether the verification banner should be displayed.
  bool get shouldShowBanner => verificationState.shouldShowBanner;

  /// Loads the traveler profile and verification session status.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile();

      // Fetch verification session status when the profile indicates
      // documents have been submitted (to detect failed state)
      if (_profile?.verificationState == TravelerVerificationState.submitted) {
        try {
          _verificationStatus =
              await _verificationRepository.getVerificationStatus();
        } catch (_) {
          // Non-critical — fall back to profile-based state
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
