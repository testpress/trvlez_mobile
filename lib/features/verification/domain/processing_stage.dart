import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';

/// The type of processing being performed.
enum ProcessingType { passport, video }

/// The visual stage shown to the user during processing.
enum ProcessingStageType {
  preparing,
  uploading,
  checking,
  qualityPassed,
  reading,
  completed,
  failed,
}

/// Represents a single user-facing stage of the verification processing journey.
///
/// Maps technical backend phases to calm, human-readable titles and subtitles.
/// All technical→human language translation lives here.
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

  /// Maps a [VerificationPhase] to the corresponding passport processing stage.
  factory ProcessingStage.forPassport(
    VerificationPhase phase, {
    String? errorMessage,
  }) {
    return switch (phase) {
      VerificationPhase.preparingImage => const ProcessingStage(
        type: ProcessingStageType.preparing,
        title: 'Preparing your passport',
        subtitle: 'Optimizing and preparing your document.',
      ),
      VerificationPhase.uploading => const ProcessingStage(
        type: ProcessingStageType.uploading,
        title: 'Uploading your passport',
        subtitle: 'We\'re securely preparing your document.',
      ),
      VerificationPhase.checkingImageQuality => const ProcessingStage(
        type: ProcessingStageType.checking,
        title: 'Checking your passport',
        subtitle: 'Making sure the image is clear and ready to use.',
      ),
      VerificationPhase.extractingMrz => const ProcessingStage(
        type: ProcessingStageType.reading,
        title: 'Reading your passport',
        subtitle: 'We\'re securely reading the details from your document.',
      ),
      VerificationPhase.uploadSuccess => const ProcessingStage(
        type: ProcessingStageType.completed,
        title: 'Passport details ready',
        subtitle: 'Your passport has been processed successfully.',
      ),
      VerificationPhase.imageQualityFailed => ProcessingStage(
        type: ProcessingStageType.failed,
        title: 'Let\'s try that again',
        subtitle:
            errorMessage ??
            'Your passport image isn\'t clear enough to continue.',
        errorMessage: errorMessage,
      ),
      VerificationPhase.mrzExtractionFailed => ProcessingStage(
        type: ProcessingStageType.failed,
        title: 'Let\'s try that again',
        subtitle:
            errorMessage ?? 'We couldn\'t read the details from your passport.',
        errorMessage: errorMessage,
      ),
      VerificationPhase.error => ProcessingStage(
        type: ProcessingStageType.failed,
        title: 'Something went wrong',
        subtitle: errorMessage ?? 'Please try uploading your passport again.',
        errorMessage: errorMessage,
      ),
      // For any other phase, default to uploading
      _ => const ProcessingStage(
        type: ProcessingStageType.uploading,
        title: 'Uploading your passport',
        subtitle: 'We\'re securely preparing your document.',
      ),
    };
  }

  /// Maps a [VerificationPhase] to the corresponding video processing stage.
  factory ProcessingStage.forVideo(
    VerificationPhase phase, {
    String? errorMessage,
  }) {
    return switch (phase) {
      VerificationPhase.uploading => const ProcessingStage(
        type: ProcessingStageType.uploading,
        title: 'Uploading your video',
        subtitle: 'Securely preparing your video.',
      ),
      VerificationPhase.checkingVideoQuality => const ProcessingStage(
        type: ProcessingStageType.checking,
        title: 'Checking your video',
        subtitle: 'Making sure your video is clear and ready for verification.',
      ),
      VerificationPhase.uploadSuccess => const ProcessingStage(
        type: ProcessingStageType.completed,
        title: 'Video is ready',
        subtitle: 'Your video has been processed successfully.',
      ),
      VerificationPhase.videoQualityFailed => ProcessingStage(
        type: ProcessingStageType.failed,
        title: 'Let\'s record that again',
        subtitle:
            errorMessage ??
            'We couldn\'t get a clear enough video to continue.',
        errorMessage: errorMessage,
      ),
      VerificationPhase.error => ProcessingStage(
        type: ProcessingStageType.failed,
        title: 'Something went wrong',
        subtitle: errorMessage ?? 'Please try uploading your video again.',
        errorMessage: errorMessage,
      ),
      // For any other phase, default to uploading
      _ => const ProcessingStage(
        type: ProcessingStageType.uploading,
        title: 'Uploading your video',
        subtitle: 'Securely preparing your video.',
      ),
    };
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
        ProcessingStageType.preparing => 0,
        ProcessingStageType.uploading => 0,
        ProcessingStageType.checking => 1,
        ProcessingStageType.qualityPassed => 1,
        ProcessingStageType.reading => 2,
        ProcessingStageType.completed => maxIndex,
        ProcessingStageType.failed => maxIndex,
      },
      ProcessingType.video => switch (this.type) {
        ProcessingStageType.preparing => 0,
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
