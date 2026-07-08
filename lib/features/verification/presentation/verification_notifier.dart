import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../data/verification_repository.dart';
import '../domain/verification_job_result.dart';
import '../domain/verification_submit_result.dart';
import '../domain/verification_status.dart' as domain;

/// Tracks the current phase of the verification flow in the UI.
enum VerificationPhase {
  /// No operation in progress.
  idle,

  /// Uploading a file to S3.
  uploading,

  /// File upload succeeded (passport or selfie).
  uploadSuccess,

  /// Submitting documents for verification (triggers ML pipeline).
  submitting,

  /// ML pipeline is running — polling for results.
  verifying,

  /// Verification pipeline completed successfully.
  verified,

  /// Verification pipeline completed with failure.
  verificationFailed,

  /// An error occurred (upload, submit, or network failure).
  error,
}

class VerificationNotifier extends ChangeNotifier {
  final VerificationRepository repository;

  VerificationNotifier({VerificationRepository? repository})
    : repository = repository ?? VerificationRepository();

  File? capturedImage;
  File? capturedVideo;
  VerificationPhase phase = VerificationPhase.idle;
  double uploadProgress = 0.0;
  String? errorMessage;
  VerificationSubmitResult? submitResult;
  VerificationJobResult? jobResult;
  domain.VerificationStatus? verificationStatus;
  Timer? pollTimer;

  /// Backward-compatible status getter used by existing UI code.
  VerificationStatus get status => switch (phase) {
    VerificationPhase.idle => VerificationStatus.idle,
    VerificationPhase.uploading => VerificationStatus.uploading,
    VerificationPhase.uploadSuccess ||
    VerificationPhase.submitting ||
    VerificationPhase.verifying ||
    VerificationPhase.verified => VerificationStatus.success,
    VerificationPhase.verificationFailed ||
    VerificationPhase.error => VerificationStatus.error,
  };

  void setImage(File image) {
    capturedImage = image;
    phase = VerificationPhase.idle;
    errorMessage = null;
    notifyListeners();
  }

  void clearImage() {
    capturedImage = null;
    phase = VerificationPhase.idle;
    errorMessage = null;
    uploadProgress = 0.0;
    notifyListeners();
  }

  void setVideo(File video) {
    capturedVideo = video;
    phase = VerificationPhase.idle;
    errorMessage = null;
    notifyListeners();
  }

  void clearVideo() {
    capturedVideo = null;
    phase = VerificationPhase.idle;
    errorMessage = null;
    uploadProgress = 0.0;
    notifyListeners();
  }

  /// Resets the notifier state completely for a new verification session.
  void reset() {
    capturedImage = null;
    capturedVideo = null;
    phase = VerificationPhase.idle;
    uploadProgress = 0.0;
    errorMessage = null;
    submitResult = null;
    jobResult = null;
    verificationStatus = null;
    stopPolling();
    notifyListeners();
  }

  Future<void> uploadPassport() async {
    if (capturedImage == null) return;

    phase = VerificationPhase.uploading;
    uploadProgress = 0.0;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.uploadPassport(
        capturedImage!,
        onProgress: (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      phase = VerificationPhase.uploadSuccess;
      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  /// Uploads the selfie video.
  ///
  /// After a successful upload, this method transitions the phase to
  /// [VerificationPhase.uploadSuccess] so the UI can proceed without waiting.
  /// It then asynchronously triggers the backend ML verification pipeline.
  Future<void> uploadSelfie() async {
    if (capturedVideo == null) return;

    phase = VerificationPhase.uploading;
    uploadProgress = 0.0;
    errorMessage = null;
    submitResult = null;
    jobResult = null;
    verificationStatus = null;
    notifyListeners();

    try {
      await repository.uploadSelfie(
        capturedVideo!,
        onProgress: (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      // Upload complete. Don't block the caller (UI) for submit.
      phase = VerificationPhase.uploadSuccess;
      notifyListeners();

      // Fire off submit in the background
      submitVerificationAsync();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<void> submitVerificationAsync() async {
    phase = VerificationPhase.submitting;
    notifyListeners();

    try {
      submitResult = await repository.submitVerification();

      if (submitResult!.isVerified) {
        phase = VerificationPhase.verified;
      } else if (submitResult!.isFailed) {
        phase = VerificationPhase.verificationFailed;
        errorMessage =
            'Identity verification was unsuccessful. Please try again.';
      } else {
        phase = VerificationPhase.verifying;
        startPollingVerificationJob();
      }

      if (!submitResult!.isProcessing) {
        try {
          verificationStatus = await repository.getVerificationStatus();
          if (submitResult!.isFailed) {
            errorMessage =
                verificationStatus?.uiMitigation ??
                verificationStatus?.errorReason ??
                errorMessage;
          }
        } catch (_) {}
      }

      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Verification submit failed: $e';
      notifyListeners();
    }
  }

  /// Polls the verification job with exponential backoff.
  ///
  /// Starts polling at [initialIntervalSeconds] and doubles the interval
  /// up to [maxIntervalSeconds]. Stops after [maxDurationSeconds] or when
  /// the job completes.
  ///
  /// Calls [onComplete] when the job finishes (verified or failed).
  void startPollingVerificationJob({
    int initialIntervalSeconds = 2,
    int maxIntervalSeconds = 15,
    int maxDurationSeconds = 300,
    VoidCallback? onComplete,
  }) {
    final jobId = submitResult?.verificationJobId;
    if (jobId == null) return;

    stopPolling();

    int currentInterval = initialIntervalSeconds;
    int totalElapsed = 0;

    pollTimer = Timer.periodic(Duration(seconds: currentInterval), (
      timer,
    ) async {
      if (totalElapsed >= maxDurationSeconds) {
        stopPolling();
        return;
      }

      try {
        jobResult = await repository.getVerificationJob(jobId);

        if (jobResult!.isComplete) {
          phase = jobResult!.isVerified
              ? VerificationPhase.verified
              : VerificationPhase.verificationFailed;

          if (jobResult!.isFailed) {
            errorMessage =
                jobResult!.errorMessage ??
                'Identity verification was unsuccessful. Please try again.';
          }

          try {
            verificationStatus = await repository.getVerificationStatus();
            if (jobResult!.isFailed) {
              errorMessage =
                  verificationStatus?.uiMitigation ??
                  verificationStatus?.errorReason ??
                  errorMessage;
            }
          } catch (_) {}

          notifyListeners();
          stopPolling();
          onComplete?.call();
          return;
        }

        notifyListeners();
      } catch (_) {
        // Non-critical — continue polling on next interval
      }

      totalElapsed += currentInterval;

      // Exponential backoff — cancel current timer and create new one
      if (currentInterval < maxIntervalSeconds) {
        timer.cancel();
        currentInterval = (currentInterval * 2).clamp(1, maxIntervalSeconds);
        pollTimer = Timer.periodic(Duration(seconds: currentInterval), (
          newTimer,
        ) async {
          if (totalElapsed >= maxDurationSeconds) {
            stopPolling();
            return;
          }

          try {
            jobResult = await repository.getVerificationJob(jobId);

            if (jobResult!.isComplete) {
              phase = jobResult!.isVerified
                  ? VerificationPhase.verified
                  : VerificationPhase.verificationFailed;

              if (jobResult!.isFailed) {
                errorMessage =
                    jobResult!.errorMessage ??
                    'Identity verification was unsuccessful. Please try again.';
              }

              try {
                verificationStatus = await repository.getVerificationStatus();
                if (jobResult!.isFailed) {
                  errorMessage =
                      verificationStatus?.uiMitigation ??
                      verificationStatus?.errorReason ??
                      errorMessage;
                }
              } catch (_) {}

              notifyListeners();
              stopPolling();
              onComplete?.call();
              return;
            }

            notifyListeners();
          } catch (_) {
            // Non-critical — continue polling
          }

          totalElapsed += currentInterval;
        });
      }
    });
  }

  /// Stops any active polling timer.
  void stopPolling() {
    pollTimer?.cancel();
    pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

/// Legacy status enum kept for backward compatibility with passport screens.
enum VerificationStatus { idle, uploading, success, error }
