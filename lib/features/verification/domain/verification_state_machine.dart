import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';

/// Pure Dart statechart engine for the verification workflow.
///
/// Implements deterministic `(currentState, event) -> nextState` transitions,
/// validates guards, and prevents invalid or duplicate state transitions.
class VerificationStateMachine {
  const VerificationStateMachine();

  /// Computes the next state based on the current state and incoming event.
  VerificationWorkflowState transition(
    VerificationWorkflowState state,
    VerificationEvent event,
  ) {
    // ── Universal Events (Valid from any state) ─────────────────────

    if (event is ResetRequested) {
      return const VerificationStateNotStarted(
        durableData: VerificationDurableData.empty,
      );
    }

    if (event is AlreadyVerifiedDetected) {
      return VerificationStateVerified(
        durableData: state.durableData.copyWith(
          lastKnownStatus: 'verified',
          verificationScore: event.score,
        ),
        verificationScore: event.score,
      );
    }

    if (event is ReconcileRequested) {
      // Do not interrupt active critical upload streaming unless forced
      if (!event.force &&
          (state is VerificationStatePassportProcessing ||
              state is VerificationStateSelfieProcessing ||
              state is VerificationStateSubmitting)) {
        return state;
      }
      return VerificationStateReconciling(
        durableData: state.durableData,
        previousState: state,
      );
    }

    if (event is BackendReconciled) {
      return _handleBackendReconciled(state, event);
    }

    if (event is OperationalErrorOccurred) {
      // If already terminal, keep terminal state
      if (state is VerificationStateVerified ||
          state is VerificationStateFailed) {
        return state;
      }
      return VerificationStateError(
        durableData: state.durableData,
        userMessage: event.userMessage,
        previousState: state is VerificationStateReconciling
            ? (state.previousState ?? const VerificationStateNotStarted())
            : state,
      );
    }

    // ── State-Specific Transition Table ─────────────────────────────

    return switch (state) {
      VerificationStateUninitialized() => _handleUninitialized(state, event),
      VerificationStateNotStarted() => _handleNotStarted(state, event),
      VerificationStatePassportCapture() => _handlePassportCapture(
        state,
        event,
      ),
      VerificationStatePassportProcessing() => _handlePassportProcessing(
        state,
        event,
      ),
      VerificationStatePassportQualityFailed() => _handlePassportQualityFailed(
        state,
        event,
      ),
      VerificationStateMrzExtractionFailed() => _handleMrzExtractionFailed(
        state,
        event,
      ),
      VerificationStateMrzReview() => _handleMrzReview(state, event),
      VerificationStateConfirmingMrz() => _handleConfirmingMrz(state, event),
      VerificationStateSelfieInstruction() => _handleSelfieInstruction(
        state,
        event,
      ),
      VerificationStateSelfieCapture() => _handleSelfieCapture(state, event),
      VerificationStateSelfieProcessing() => _handleSelfieProcessing(
        state,
        event,
      ),
      VerificationStateSelfieQualityFailed() => _handleSelfieQualityFailed(
        state,
        event,
      ),
      VerificationStateNfcIntro() => _handleNfcIntro(state, event),
      VerificationStateNfcScanning() => _handleNfcScanning(state, event),
      VerificationStateNfcResult() => _handleNfcResult(state, event),
      VerificationStateSubmitting() => _handleSubmitting(state, event),
      VerificationStateProcessing() => _handleProcessing(state, event),
      VerificationStateVerified() => _handleVerified(state, event),
      VerificationStateFailed() => _handleFailed(state, event),
      VerificationStateReconciling() => _handleReconciling(state, event),
      VerificationStateError() => _handleError(state, event),
    };
  }

  // ── Reconciliation Transition Logic ───────────────────────────────

  VerificationWorkflowState _handleBackendReconciled(
    VerificationWorkflowState state,
    BackendReconciled event,
  ) {
    // If client is actively processing local uploads, preserve active local state
    if (state is VerificationStatePassportProcessing ||
        state is VerificationStateSelfieProcessing ||
        state is VerificationStateConfirmingMrz ||
        state is VerificationStateSubmitting) {
      return state;
    }

    final status = event.status;
    final profile = event.profile;

    final updatedDurable = state.durableData.copyWith(
      sessionId: status.sessionId ?? state.durableData.sessionId,
      jobId: status.verificationJobId ?? state.durableData.jobId,
      lastKnownStatus: status.status,
      lastReconciledAt: DateTime.now(),
      extractedDocumentNumber:
          profile.passportNumber ?? state.durableData.extractedDocumentNumber,
      extractedDateOfBirth:
          profile.dateOfBirth ?? state.durableData.extractedDateOfBirth,
      extractedDateOfExpiry:
          profile.passportExpiry ?? state.durableData.extractedDateOfExpiry,
    );

    // 1. Verified on backend
    if (status.isVerified ||
        profile.verificationState == TravelerVerificationState.verified) {
      return VerificationStateVerified(
        durableData: updatedDurable,
        verificationStatus: status,
      );
    }

    // 2. Failed / Rejected on backend
    if (status.isFailed ||
        profile.verificationState == TravelerVerificationState.failed) {
      return VerificationStateFailed(
        durableData: updatedDurable,
        errorReason: status.errorReason,
        failedStep: status.failedStep,
        uiMitigation: status.uiMitigation,
        verificationStatus: status,
      );
    }

    // 3. Processing on backend (submitted to ML pipeline)
    if (status.isProcessing ||
        profile.verificationState == TravelerVerificationState.submitted) {
      return VerificationStateProcessing(
        durableData: updatedDurable,
        jobId: status.verificationJobId ?? updatedDurable.jobId ?? '',
        verificationStatus: status,
      );
    }

    // 4. Documents uploaded (ready for NFC / submission)
    if (status.isUploaded ||
        (status.passportUploaded && status.videoUploaded) ||
        profile.verificationState ==
            TravelerVerificationState.documentsUploaded) {
      return VerificationStateNfcIntro(durableData: updatedDurable);
    }

    // 5. Passport confirmed (ready for selfie)
    if (profile.verificationState ==
            TravelerVerificationState.passportReviewed ||
        (status.passportUploaded && !status.videoUploaded)) {
      return VerificationStateSelfieInstruction(durableData: updatedDurable);
    }

    // 6. Not started / Incomplete profile
    return VerificationStateNotStarted(durableData: updatedDurable);
  }

  // ── State Handler Implementations ─────────────────────────────────

  VerificationWorkflowState _handleUninitialized(
    VerificationStateUninitialized state,
    VerificationEvent event,
  ) {
    if (event is StartVerification) {
      return VerificationStatePassportCapture(durableData: state.durableData);
    }
    if (event is PassportCaptured) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: PassportProcessingSubStage.uploading,
        passportImage: event.imageFile,
      );
    }
    if (event is SelfieCaptured) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: SelfieProcessingSubStage.uploading,
        selfieVideo: event.videoFile,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleNotStarted(
    VerificationStateNotStarted state,
    VerificationEvent event,
  ) {
    if (event is StartVerification) {
      return VerificationStatePassportCapture(durableData: state.durableData);
    }
    if (event is PassportCaptured) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: PassportProcessingSubStage.uploading,
        passportImage: event.imageFile,
      );
    }
    if (event is SelfieCaptured) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: SelfieProcessingSubStage.uploading,
        selfieVideo: event.videoFile,
      );
    }
    return state;
  }

  VerificationWorkflowState _handlePassportCapture(
    VerificationStatePassportCapture state,
    VerificationEvent event,
  ) {
    if (event is PassportCaptured) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: PassportProcessingSubStage.uploading,
        passportImage: event.imageFile,
      );
    }
    return state;
  }

  VerificationWorkflowState _handlePassportProcessing(
    VerificationStatePassportProcessing state,
    VerificationEvent event,
  ) {
    if (event is PassportUploadProgressUpdate) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: state.stage,
        uploadProgress: event.progress,
        passportImage: state.passportImage,
      );
    }
    if (event is PassportUploaded) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: PassportProcessingSubStage.checkingQuality,
        uploadProgress: 1.0,
        passportImage: state.passportImage,
      );
    }
    if (event is PassportQualityPassed) {
      return VerificationStatePassportProcessing(
        durableData: state.durableData,
        stage: PassportProcessingSubStage.extractingMrz,
        uploadProgress: 1.0,
        passportImage: state.passportImage,
      );
    }
    if (event is PassportQualityFailed) {
      return VerificationStatePassportQualityFailed(
        durableData: state.durableData,
        errorMessage: event.message,
        qualityResult: event.result,
        passportImage: state.passportImage,
      );
    }
    if (event is MrzExtracted) {
      return VerificationStateMrzReview(
        durableData: state.durableData.copyWith(
          extractedDocumentNumber: event.result.documentNumber,
          extractedDateOfBirth: DateTime.tryParse(
            event.result.dateOfBirth ?? '',
          ),
          extractedDateOfExpiry: DateTime.tryParse(
            event.result.dateOfExpiry ?? '',
          ),
        ),
        mrzExtractionResult: event.result,
        passportImage: state.passportImage,
      );
    }
    if (event is MrzExtractionFailed) {
      return VerificationStateMrzExtractionFailed(
        durableData: state.durableData,
        errorMessage: event.message,
        passportImage: state.passportImage,
      );
    }
    return state;
  }

  VerificationWorkflowState _handlePassportQualityFailed(
    VerificationStatePassportQualityFailed state,
    VerificationEvent event,
  ) {
    if (event is RetryRequested || event is StartVerification) {
      return VerificationStatePassportCapture(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleMrzExtractionFailed(
    VerificationStateMrzExtractionFailed state,
    VerificationEvent event,
  ) {
    if (event is RetryRequested || event is StartVerification) {
      return VerificationStatePassportCapture(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleMrzReview(
    VerificationStateMrzReview state,
    VerificationEvent event,
  ) {
    if (event is ConfirmMrzRequested) {
      return VerificationStateConfirmingMrz(
        durableData: state.durableData,
        mrzExtractionResult: state.mrzExtractionResult,
        passportImage: state.passportImage,
      );
    }
    if (event is RetryRequested || event is StartVerification) {
      return VerificationStatePassportCapture(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleConfirmingMrz(
    VerificationStateConfirmingMrz state,
    VerificationEvent event,
  ) {
    if (event is MrzConfirmed) {
      return VerificationStateSelfieInstruction(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleSelfieInstruction(
    VerificationStateSelfieInstruction state,
    VerificationEvent event,
  ) {
    if (event is StartSelfieCapture) {
      return VerificationStateSelfieCapture(durableData: state.durableData);
    }
    if (event is SelfieCaptured) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: SelfieProcessingSubStage.uploading,
        selfieVideo: event.videoFile,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleSelfieCapture(
    VerificationStateSelfieCapture state,
    VerificationEvent event,
  ) {
    if (event is SelfieCaptured) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: SelfieProcessingSubStage.uploading,
        selfieVideo: event.videoFile,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleSelfieProcessing(
    VerificationStateSelfieProcessing state,
    VerificationEvent event,
  ) {
    if (event is SelfieUploadProgressUpdate) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: state.stage,
        uploadProgress: event.progress,
        selfieVideo: state.selfieVideo,
      );
    }
    if (event is SelfieUploaded) {
      return VerificationStateSelfieProcessing(
        durableData: state.durableData,
        stage: SelfieProcessingSubStage.checkingQuality,
        uploadProgress: 1.0,
        selfieVideo: state.selfieVideo,
      );
    }
    if (event is SelfieQualityPassed) {
      return VerificationStateNfcIntro(durableData: state.durableData);
    }
    if (event is SelfieQualityFailed) {
      return VerificationStateSelfieQualityFailed(
        durableData: state.durableData,
        errorMessage: event.message,
        qualityResult: event.result,
        selfieVideo: state.selfieVideo,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleSelfieQualityFailed(
    VerificationStateSelfieQualityFailed state,
    VerificationEvent event,
  ) {
    if (event is RetryRequested || event is StartSelfieCapture) {
      return VerificationStateSelfieCapture(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleNfcIntro(
    VerificationStateNfcIntro state,
    VerificationEvent event,
  ) {
    if (event is StartNfcScan) {
      return VerificationStateNfcScanning(durableData: state.durableData);
    }
    if (event is NfcSkipped || event is SubmitRequested) {
      return VerificationStateSubmitting(
        durableData: state.durableData,
        isNfcSkipped: true,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleNfcScanning(
    VerificationStateNfcScanning state,
    VerificationEvent event,
  ) {
    if (event is NfcScanCompleted) {
      return VerificationStateNfcResult(
        durableData: state.durableData,
        passportNfcResult: event.result,
      );
    }
    if (event is RetryRequested || event is NfcSkipped) {
      return VerificationStateNfcIntro(durableData: state.durableData);
    }
    return state;
  }

  VerificationWorkflowState _handleNfcResult(
    VerificationStateNfcResult state,
    VerificationEvent event,
  ) {
    if (event is SubmitRequested) {
      return VerificationStateSubmitting(
        durableData: state.durableData,
        nfcPayload: event.nfcPayload ?? state.passportNfcResult.toJson(),
        isNfcSkipped: false,
      );
    }
    return state;
  }

  VerificationWorkflowState _handleSubmitting(
    VerificationStateSubmitting state,
    VerificationEvent event,
  ) {
    if (event is SubmissionAccepted) {
      return VerificationStateProcessing(
        durableData: state.durableData.copyWith(jobId: event.jobId),
        jobId: event.jobId,
      );
    }
    if (event is SubmissionCompletedImmediate) {
      if (event.isVerified) {
        return VerificationStateVerified(
          durableData: state.durableData.copyWith(
            verificationScore: event.score,
          ),
          verificationScore: event.score,
        );
      } else {
        return VerificationStateFailed(
          durableData: state.durableData,
          errorReason: 'Identity verification was unsuccessful.',
        );
      }
    }
    return state;
  }

  VerificationWorkflowState _handleProcessing(
    VerificationStateProcessing state,
    VerificationEvent event,
  ) {
    if (event is VerificationJobUpdated) {
      if (event.result.isVerified) {
        return VerificationStateVerified(
          durableData: state.durableData.copyWith(
            verificationScore: event.result.verificationScore,
          ),
          verificationScore: event.result.verificationScore,
          jobResult: event.result,
          verificationStatus: event.status,
        );
      }
      if (event.result.isFailed) {
        return VerificationStateFailed(
          durableData: state.durableData,
          errorReason: event.result.errorMessage ?? event.status?.errorReason,
          failedStep: event.status?.failedStep,
          uiMitigation: event.status?.uiMitigation,
          jobResult: event.result,
          verificationStatus: event.status,
        );
      }
      return VerificationStateProcessing(
        durableData: state.durableData,
        jobId: state.jobId,
        interimScore: event.result.verificationScore,
        jobResult: event.result,
        verificationStatus: event.status,
      );
    }
    if (event is VerificationJobCompleted) {
      if (event.isVerified) {
        return VerificationStateVerified(
          durableData: state.durableData.copyWith(
            verificationScore: event.score,
          ),
          verificationScore: event.score,
          jobResult: event.result,
        );
      } else {
        return VerificationStateFailed(
          durableData: state.durableData,
          errorReason: 'Identity verification was unsuccessful.',
          jobResult: event.result,
        );
      }
    }
    if (event is VerificationJobFailed) {
      return VerificationStateFailed(
        durableData: state.durableData,
        errorReason: event.errorReason,
        failedStep: event.failedStep,
        uiMitigation: event.uiMitigation,
        jobResult: event.result,
      );
    }
    // Block duplicate submissions when already in processing
    return state;
  }

  VerificationWorkflowState _handleVerified(
    VerificationStateVerified state,
    VerificationEvent event,
  ) {
    // Verified is terminal; ignore submission or capture events
    return state;
  }

  VerificationWorkflowState _handleFailed(
    VerificationStateFailed state,
    VerificationEvent event,
  ) {
    if (event is ResetRequested || event is StartVerification) {
      return const VerificationStateNotStarted();
    }
    return state;
  }

  VerificationWorkflowState _handleReconciling(
    VerificationStateReconciling state,
    VerificationEvent event,
  ) {
    // Reconciling transitions when BackendReconciled or error occurs
    return state;
  }

  VerificationWorkflowState _handleError(
    VerificationStateError state,
    VerificationEvent event,
  ) {
    if (event is RetryRequested) {
      return state.previousState;
    }
    if (event is ResetRequested) {
      return const VerificationStateNotStarted();
    }
    return state;
  }
}
