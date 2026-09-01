import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/data/verification_storage.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_state_machine.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';

/// Provides the durable [VerificationStorage] instance.
final verificationStorageProvider = Provider<VerificationStorage>((ref) {
  return const VerificationStorage();
});

/// Provides the pure Dart [VerificationStateMachine] instance.
final verificationStateMachineProvider = Provider<VerificationStateMachine>((
  ref,
) {
  return const VerificationStateMachine();
});

/// Provides the [VerificationRepository] instance.
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VerificationRepository(dio: dio);
});

/// Primary Riverpod controller provider exposing the current [VerificationWorkflowState].
final verificationNotifierProvider =
    NotifierProvider<VerificationNotifier, VerificationWorkflowState>(() {
      return VerificationNotifier();
    });

/// Auto-disposing provider for verification status query.
final verificationStatusProvider =
    FutureProvider.autoDispose<VerificationStatus?>((ref) async {
      final profileState = ref.watch(currentProfileProvider);
      final profile = profileState.value;

      if (profile?.verificationState == TravelerVerificationState.submitted ||
          profile?.verificationState == TravelerVerificationState.failed) {
        try {
          final repository = ref.read(verificationRepositoryProvider);
          return await repository.getVerificationStatus();
        } catch (_) {
          return null;
        }
      }
      return null;
    });
