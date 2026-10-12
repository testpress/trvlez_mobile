import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/verification/data/verification_data_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/presentation/state/verification_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';

export 'package:trvlez_mobile/core/auth/auth_notifier.dart'
    show isKycVerifiedProvider, travelerVerificationStateProvider;
export 'package:trvlez_mobile/features/verification/data/verification_data_providers.dart'
    show verificationRepositoryProvider;
export 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';
export 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';
export 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';
export 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
export 'package:trvlez_mobile/features/verification/presentation/state/verification_state.dart';
export 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';

/// Notifier provider managing multi-step verification state machine.
final verificationNotifierProvider =
    NotifierProvider<VerificationNotifier, VerificationState>(() {
      return VerificationNotifier();
    });

/// Future provider fetching current verification status when in submitted step.
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
