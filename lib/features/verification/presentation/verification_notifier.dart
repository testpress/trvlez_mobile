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
  final VerificationRepository _repository;

  VerificationNotifier({VerificationRepository? repository})
      : _repository = repository ?? VerificationRepository();

  File? _capturedImage;
  File? _capturedVideo;
  VerificationPhase _phase = VerificationPhase.idle;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  VerificationSubmitResult? _submitResult;
  VerificationJobResult? _jobResult;
  domain.VerificationStatus? _verificationStatus;
  Timer? _pollTimer;

  File? get capturedImage => _capturedImage;
  File? get capturedVideo => _capturedVideo;
  VerificationPhase get phase => _phase;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  VerificationSubmitResult? get submitResult => _submitResult;
  VerificationJobResult? get jobResult => _jobResult;
  domain.VerificationStatus? get verificationStatus => _verificationStatus;

  /// Backward-compatible status getter used by existing UI code.
  VerificationStatus get status => switch (_phase) {
        VerificationPhase.idle => VerificationStatus.idle,
        VerificationPhase.uploading => VerificationStatus.uploading,
        VerificationPhase.uploadSuccess ||
        VerificationPhase.submitting ||
        VerificationPhase.verifying ||
        VerificationPhase.verified =>
          VerificationStatus.success,
        VerificationPhase.verificationFailed ||
        VerificationPhase.error =>
          VerificationStatus.error,
      };

  void setImage(File image) {
    _capturedImage = image;
    _phase = VerificationPhase.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearImage() {
    _capturedImage = null;
    _phase = VerificationPhase.idle;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  void setVideo(File video) {
    _capturedVideo = video;
    _phase = VerificationPhase.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearVideo() {
    _capturedVideo = null;
    _phase = VerificationPhase.idle;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  /// Resets the notifier state completely for a new verification session.
  void reset() {
    _capturedImage = null;
    _capturedVideo = null;
    _phase = VerificationPhase.idle;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _submitResult = null;
    _jobResult = null;
    _verificationStatus = null;
    stopPolling();
    notifyListeners();
  }

  Future<void> uploadPassport() async {
    if (_capturedImage == null) return;

    _phase = VerificationPhase.uploading;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadPassport(
        _capturedImage!,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      
      _phase = VerificationPhase.uploadSuccess;
      notifyListeners();
    } on ApiException catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  /// Uploads the selfie video.
  ///
  /// After a successful upload, this method transitions the phase to
  /// [VerificationPhase.uploadSuccess] so the UI can proceed without waiting.
  /// It then asynchronously triggers the backend ML verification pipeline.
  Future<void> uploadSelfie() async {
    if (_capturedVideo == null) return;

    _phase = VerificationPhase.uploading;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _submitResult = null;
    _jobResult = null;
    _verificationStatus = null;
    notifyListeners();

    try {
      await _repository.uploadSelfie(
        _capturedVideo!,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // Upload complete. Don't block the caller (UI) for submit.
      _phase = VerificationPhase.uploadSuccess;
      notifyListeners();

      // Fire off submit in the background
      _submitVerificationAsync();
    } on ApiException catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<void> _submitVerificationAsync() async {
    _phase = VerificationPhase.submitting;
    notifyListeners();

    try {
      _submitResult = await _repository.submitVerification();

      if (_submitResult!.isVerified) {
        _phase = VerificationPhase.verified;
      } else if (_submitResult!.isFailed) {
        _phase = VerificationPhase.verificationFailed;
        _errorMessage = 'Identity verification was unsuccessful. Please try again.';
      } else {
        _phase = VerificationPhase.verifying;
        startPollingVerificationJob();
      }

      if (!_submitResult!.isProcessing) {
        try {
          _verificationStatus = await _repository.getVerificationStatus();
          if (_submitResult!.isFailed) {
            _errorMessage = _verificationStatus?.uiMitigation ?? _verificationStatus?.errorReason ?? _errorMessage;
          }
        } catch (_) {}
      }

      notifyListeners();
    } on ApiException catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _phase = VerificationPhase.error;
      _errorMessage = 'Verification submit failed: $e';
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
    final jobId = _submitResult?.verificationJobId;
    if (jobId == null) return;

    stopPolling();

    int currentInterval = initialIntervalSeconds;
    int totalElapsed = 0;

    _pollTimer = Timer.periodic(Duration(seconds: currentInterval), (timer) async {
      if (totalElapsed >= maxDurationSeconds) {
        stopPolling();
        return;
      }

      try {
        _jobResult = await _repository.getVerificationJob(jobId);

        if (_jobResult!.isComplete) {
          _phase = _jobResult!.isVerified
              ? VerificationPhase.verified
              : VerificationPhase.verificationFailed;

          if (_jobResult!.isFailed) {
            _errorMessage = _jobResult!.errorMessage ??
                'Identity verification was unsuccessful. Please try again.';
          }

          try {
            _verificationStatus = await _repository.getVerificationStatus();
            if (_jobResult!.isFailed) {
              _errorMessage = _verificationStatus?.uiMitigation ?? _verificationStatus?.errorReason ?? _errorMessage;
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
        _pollTimer = Timer.periodic(
          Duration(seconds: currentInterval),
          (newTimer) async {
            if (totalElapsed >= maxDurationSeconds) {
              stopPolling();
              return;
            }

            try {
              _jobResult = await _repository.getVerificationJob(jobId);

              if (_jobResult!.isComplete) {
                _phase = _jobResult!.isVerified
                    ? VerificationPhase.verified
                    : VerificationPhase.verificationFailed;

                if (_jobResult!.isFailed) {
                  _errorMessage = _jobResult!.errorMessage ??
                      'Identity verification was unsuccessful. Please try again.';
                }

                try {
                  _verificationStatus = await _repository.getVerificationStatus();
                  if (_jobResult!.isFailed) {
                    _errorMessage = _verificationStatus?.uiMitigation ?? _verificationStatus?.errorReason ?? _errorMessage;
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
          },
        );
      }
    });
  }

  /// Stops any active polling timer.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

/// Legacy status enum kept for backward compatibility with passport screens.
enum VerificationStatus {
  idle,
  uploading,
  success,
  error,
}
