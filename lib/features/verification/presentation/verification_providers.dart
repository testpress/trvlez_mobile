import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';

final verificationNotifierProvider =
    NotifierProvider<VerificationNotifier, VerificationState>(() {
      return VerificationNotifier();
    });

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VerificationRepository(dio: dio);
});

final verificationStatusProvider =
    FutureProvider.autoDispose<VerificationStatus?>((ref) async {
      final profileState = ref.watch(currentProfileProvider);
      final profile = profileState.value;

      if (profile?.verificationState == TravelerVerificationState.submitted) {
        try {
          final repository = ref.read(verificationRepositoryProvider);
          return await repository.getVerificationStatus();
        } catch (_) {
          return null;
        }
      }
      return null;
    });

/// Computes the active traveler verification state.
///
/// Combines the profile's onboarding step with the verification session status
/// so that a submitted session marked as failed in the verification service
/// transitions the state to [TravelerVerificationState.failed].
final travelerVerificationStateProvider =
    Provider<TravelerVerificationState>((ref) {
  final profileState = ref.watch(currentProfileProvider);
  final profile = profileState.value;
  final verificationStatus = ref.watch(verificationStatusProvider).value;

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

