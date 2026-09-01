import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/data/verification_storage.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_actors.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_state_machine.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Primary Riverpod controller for identity verification.
///
/// Bridges the UI, [VerificationStateMachine], [VerificationActors], and [VerificationStorage].
/// State updates are computed by the pure state machine, while asynchronous
/// side effects are executed by dedicated async actors.
class VerificationNotifier extends Notifier<VerificationWorkflowState> {
  late final VerificationStateMachine _stateMachine;
  late final VerificationStorage _storage;
  late final ReconciliationActor _reconciliationActor;
  late final PassportUploadActor _passportUploadActor;
  late final MrzConfirmActor _mrzConfirmActor;
  late final VideoUploadActor _videoUploadActor;
  late final SubmitActor _submitActor;
  late final PollingActor _pollingActor;

  @override
  VerificationWorkflowState build() {
    _stateMachine = ref.read(verificationStateMachineProvider);
    _storage = ref.read(verificationStorageProvider);
    _reconciliationActor = const ReconciliationActor();
    _passportUploadActor = const PassportUploadActor();
    _mrzConfirmActor = const MrzConfirmActor();
    _videoUploadActor = const VideoUploadActor();
    _submitActor = const SubmitActor();
    _pollingActor = PollingActor();

    ref.onDispose(() {
      _pollingActor.cancel();
    });

    return const VerificationStateUninitialized();
  }

  /// Restores durable recovery state from persistent storage.
  Future<void> initializeFromStorage() async {
    if (state is! VerificationStateUninitialized) return;
    final savedDurable = await _storage.loadDurableData();
    if (state is! VerificationStateUninitialized) return;

    if (savedDurable.lastKnownStatus == 'verified') {
      send(AlreadyVerifiedDetected(savedDurable.verificationScore));
    } else if (savedDurable.jobId != null &&
        savedDurable.lastKnownStatus == 'processing') {
      send(SubmissionAccepted(savedDurable.jobId!));
    }
  }

  /// Sends a domain event to the state machine and coordinates actor execution.
  void send(VerificationEvent event) {
    final nextState = _stateMachine.transition(state, event);
    state = nextState;

    // Persist durable recovery metadata
    _storage.saveDurableData(nextState.durableData);

    // Coordinate async actors based on state transitions
    _executeActorsForState(nextState, event);
  }

  void _executeActorsForState(
    VerificationWorkflowState nextState,
    VerificationEvent triggeringEvent,
  ) {
    if (triggeringEvent is ResetRequested) {
      _pollingActor.cancel();
      _storage.clear();
      return;
    }

    if (nextState is VerificationStateReconciling) {
      _reconciliationActor.execute(
        verificationRepository: ref.read(verificationRepositoryProvider),
        profileRepository: ref.read(profileRepositoryProvider),
        emit: send,
      );
      return;
    }

    if (nextState is VerificationStatePassportProcessing &&
        nextState.stage == PassportProcessingSubStage.uploading &&
        nextState.passportImage != null) {
      _passportUploadActor.execute(
        imageFile: nextState.passportImage!,
        repository: ref.read(verificationRepositoryProvider),
        emit: send,
      );
      return;
    }

    if (nextState is VerificationStateConfirmingMrz) {
      _mrzConfirmActor.execute(
        mrzResult: nextState.mrzExtractionResult,
        repository: ref.read(verificationRepositoryProvider),
        emit: send,
      );
      return;
    }

    if (nextState is VerificationStateSelfieProcessing &&
        nextState.stage == SelfieProcessingSubStage.uploading &&
        nextState.selfieVideo != null) {
      _videoUploadActor.execute(
        videoFile: nextState.selfieVideo!,
        repository: ref.read(verificationRepositoryProvider),
        emit: send,
      );
      return;
    }

    if (nextState is VerificationStateSubmitting) {
      _submitActor.execute(
        nfcPayload: nextState.nfcPayload,
        repository: ref.read(verificationRepositoryProvider),
        emit: send,
      );
      return;
    }

    if (nextState is VerificationStateProcessing &&
        triggeringEvent is! VerificationJobUpdated) {
      _pollingActor.cancel();
      _pollingActor.execute(
        jobId: nextState.jobId,
        repository: ref.read(verificationRepositoryProvider),
        emit: send,
      );
      return;
    }
  }

  // ── Backward-Compatible UI Helpers ─────────────────────────────────

  /// Computes the effective top-level verification state for routing and banners.
  TravelerVerificationState effectiveState(
    TravelerVerificationState profileState,
  ) {
    if (state is VerificationStateVerified) {
      return TravelerVerificationState.verified;
    }
    if (state is VerificationStateFailed) {
      return TravelerVerificationState.failed;
    }
    if (state is VerificationStateProcessing ||
        state is VerificationStateSubmitting) {
      return TravelerVerificationState.submitted;
    }
    return state.effectiveTravelerState;
  }

  /// Triggers full reconciliation with the backend.
  Future<void> reconcileWithBackend({bool force = false}) async {
    send(ReconcileRequested(force: force));
  }

  /// Convenience wrapper for fetching verification status.
  Future<void> fetchVerificationStatus() async {
    send(const ReconcileRequested(force: true));
  }

  /// Resets the notifier state and storage for a new verification session.
  void reset() {
    send(const ResetRequested());
  }

  void setImage(File image) {
    send(PassportCaptured(image));
  }

  void clearImage() {
    send(const StartVerification());
  }

  void setVideo(File video) {
    send(SelfieCaptured(video));
  }

  void clearVideo() {
    send(const StartSelfieCapture());
  }

  void setNfcResult(NfcPassportResult result) {
    send(NfcScanCompleted(result));
  }

  void skipNfc() {
    send(const NfcSkipped());
  }

  Future<void> uploadPassport() async {
    final image = state.capturedImage;
    if (image != null) {
      send(PassportCaptured(image));
    }
  }

  Future<void> confirmMrz() async {
    send(const ConfirmMrzRequested());
  }

  Future<void> uploadSelfie() async {
    final video = state.capturedVideo;
    if (video != null) {
      send(SelfieCaptured(video));
    }
  }

  Future<void> submitVerificationAsync() async {
    send(const SubmitRequested());
  }

  void startPollingVerificationJob(String jobId) {
    send(SubmissionAccepted(jobId));
  }

  void stopPolling() {
    _pollingActor.cancel();
  }
}
