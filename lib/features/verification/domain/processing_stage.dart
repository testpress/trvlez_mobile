import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';

/// The type of media processing being performed.
enum ProcessingType { passport, video }

/// The visual stage shown to the user during processing.
enum ProcessingStageType {
  uploading,
  checking,
  qualityPassed,
  reading,
  completed,
  failed,
}

/// Represents a single user-facing stage of the verification processing journey.
///
/// Maps technical verification states to calm, human-readable titles and subtitles.
class ProcessingStage {
  final ProcessingStageType type;
  final String title;
  final String subtitle;
  final String? errorMessage;

  const ProcessingStage({
    required this.type,
    required this.title,
    required this.subtitle,
    this.errorMessage,
  });

  bool get isTerminal =>
      type == ProcessingStageType.completed ||
      type == ProcessingStageType.failed;

  /// Intermediate stage shown briefly when passport image quality check passes.
  static const ProcessingStage passportQualityPassed = ProcessingStage(
    type: ProcessingStageType.qualityPassed,
    title: 'Passport image looks good',
    subtitle: 'Moving on to read your passport details.',
  );

  /// Intermediate stage shown briefly when video quality check passes.
  static const ProcessingStage videoQualityPassed = ProcessingStage(
    type: ProcessingStageType.qualityPassed,
    title: 'Video looks good',
    subtitle: 'Your video is clear and ready for verification.',
  );

  /// Resolves the user-facing processing stage from [VerificationWorkflowState].
  factory ProcessingStage.fromWorkflowState(
    VerificationWorkflowState state,
    ProcessingType type,
  ) {
    if (type == ProcessingType.passport) {
      return switch (state) {
        VerificationStatePassportProcessing(
          stage: PassportProcessingSubStage.uploading,
        ) =>
          const ProcessingStage(
            type: ProcessingStageType.uploading,
            title: 'Uploading your passport',
            subtitle: 'We\'re securely preparing your document.',
          ),
        VerificationStatePassportProcessing(
          stage: PassportProcessingSubStage.checkingQuality,
        ) =>
          const ProcessingStage(
            type: ProcessingStageType.checking,
            title: 'Checking your passport',
            subtitle: 'Making sure the image is clear and ready to use.',
          ),
        VerificationStatePassportProcessing(
          stage: PassportProcessingSubStage.qualityPassed,
        ) =>
          passportQualityPassed,
        VerificationStatePassportProcessing(
          stage: PassportProcessingSubStage.extractingMrz,
        ) =>
          const ProcessingStage(
            type: ProcessingStageType.reading,
            title: 'Reading your passport',
            subtitle: 'We\'re securely reading the details from your document.',
          ),
        VerificationStateMrzReview() ||
        VerificationStateConfirmingMrz() => const ProcessingStage(
          type: ProcessingStageType.completed,
          title: 'Passport details ready',
          subtitle: 'Your passport has been processed successfully.',
        ),
        VerificationStatePassportQualityFailed(:final errorMessage) =>
          ProcessingStage(
            type: ProcessingStageType.failed,
            title: 'Let\'s try that again',
            subtitle: errorMessage.isNotEmpty
                ? errorMessage
                : 'Your passport image isn\'t clear enough to continue.',
            errorMessage: errorMessage,
          ),
        VerificationStateMrzExtractionFailed(:final errorMessage) =>
          ProcessingStage(
            type: ProcessingStageType.failed,
            title: 'Let\'s try that again',
            subtitle: errorMessage.isNotEmpty
                ? errorMessage
                : 'We couldn\'t read the details from your passport.',
            errorMessage: errorMessage,
          ),
        VerificationStateError(:final userMessage) => ProcessingStage(
          type: ProcessingStageType.failed,
          title: 'Something went wrong',
          subtitle: userMessage.isNotEmpty
              ? userMessage
              : 'Please try uploading your passport again.',
          errorMessage: userMessage,
        ),
        _ => const ProcessingStage(
          type: ProcessingStageType.uploading,
          title: 'Uploading your passport',
          subtitle: 'We\'re securely preparing your document.',
        ),
      };
    } else {
      return switch (state) {
        VerificationStateSelfieProcessing(
          stage: SelfieProcessingSubStage.uploading,
        ) =>
          const ProcessingStage(
            type: ProcessingStageType.uploading,
            title: 'Uploading your video',
            subtitle: 'Securely preparing your video.',
          ),
        VerificationStateSelfieProcessing(
          stage: SelfieProcessingSubStage.checkingQuality,
        ) =>
          const ProcessingStage(
            type: ProcessingStageType.checking,
            title: 'Checking your video',
            subtitle:
                'Making sure your video is clear and ready for verification.',
          ),
        VerificationStateSelfieProcessing(
          stage: SelfieProcessingSubStage.qualityPassed,
        ) ||
        VerificationStateNfcIntro() ||
        VerificationStateNfcScanning() ||
        VerificationStateNfcResult() ||
        VerificationStateSubmitting() => const ProcessingStage(
          type: ProcessingStageType.completed,
          title: 'Video is ready',
          subtitle: 'Your video has been processed successfully.',
        ),
        VerificationStateSelfieQualityFailed(:final errorMessage) =>
          ProcessingStage(
            type: ProcessingStageType.failed,
            title: 'Let\'s record that again',
            subtitle: errorMessage.isNotEmpty
                ? errorMessage
                : 'We couldn\'t get a clear enough video to continue.',
            errorMessage: errorMessage,
          ),
        VerificationStateError(:final userMessage) => ProcessingStage(
          type: ProcessingStageType.failed,
          title: 'Something went wrong',
          subtitle: userMessage.isNotEmpty
              ? userMessage
              : 'Please try uploading your video again.',
          errorMessage: userMessage,
        ),
        _ => const ProcessingStage(
          type: ProcessingStageType.uploading,
          title: 'Uploading your video',
          subtitle: 'Securely preparing your video.',
        ),
      };
    }
  }

  /// Returns the step labels for the processing step indicator.
  static List<String> stepLabels(ProcessingType type) {
    return switch (type) {
      ProcessingType.passport => const ['Upload', 'Check', 'Read'],
      ProcessingType.video => const ['Upload', 'Check'],
    };
  }

  /// Returns the 0-based step index for the current stage type.
  int stepIndex(ProcessingType type) {
    final maxIndex = stepLabels(type).length - 1;
    return switch (type) {
      ProcessingType.passport => switch (this.type) {
        ProcessingStageType.uploading => 0,
        ProcessingStageType.checking => 1,
        ProcessingStageType.qualityPassed => 1,
        ProcessingStageType.reading => 2,
        ProcessingStageType.completed => maxIndex,
        ProcessingStageType.failed => maxIndex,
      },
      ProcessingType.video => switch (this.type) {
        ProcessingStageType.uploading => 0,
        ProcessingStageType.checking => 1,
        ProcessingStageType.qualityPassed => 1,
        ProcessingStageType.reading => 1,
        ProcessingStageType.completed => maxIndex,
        ProcessingStageType.failed => maxIndex,
      },
    };
  }
}
