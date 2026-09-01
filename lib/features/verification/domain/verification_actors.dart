import 'dart:async';
import 'dart:io';

import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/verification/data/nfc_passport_service.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_validator.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';

/// Actor that reconciles client state against authoritative backend status and profile.
class ReconciliationActor {
  const ReconciliationActor();

  Future<void> execute({
    required VerificationRepository verificationRepository,
    required ProfileRepository profileRepository,
    required void Function(VerificationEvent) emit,
  }) async {
    try {
      final statusFuture = verificationRepository.getVerificationStatus();
      final profileFuture = profileRepository.getProfile();

      final results = await Future.wait([statusFuture, profileFuture]);
      final status = results[0] as VerificationStatus;
      final profile = results[1] as dynamic;

      emit(BackendReconciled(status: status, profile: profile));
    } on ApiException catch (e) {
      if (e.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else {
        emit(OperationalErrorOccurred(e.message));
      }
    } catch (e) {
      final apiEx = ApiException.from(e);
      if (apiEx.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else {
        emit(OperationalErrorOccurred(apiEx.message));
      }
    }
  }
}

/// Actor that orchestrates passport S3 upload, ML image quality validation, and MRZ extraction.
class PassportUploadActor {
  const PassportUploadActor();

  Future<void> execute({
    required File imageFile,
    required VerificationRepository repository,
    required void Function(VerificationEvent) emit,
  }) async {
    try {
      await repository.uploadPassport(
        imageFile,
        onProgress: (progress) {
          emit(PassportUploadProgressUpdate(progress));
        },
      );

      emit(const PassportUploaded('passport'));

      // 1. Perform targeted image quality check
      final qualityResult = await repository.checkImageQuality();
      if (!qualityResult.isAcceptable) {
        final errorMsg =
            qualityResult.uiGuidance ??
            qualityResult.message ??
            'Passport photo quality is insufficient. Please retake the photo.';
        emit(PassportQualityFailed(errorMsg, qualityResult));
        return;
      }

      emit(PassportQualityPassed(qualityResult));

      // 2. Extract MRZ data from the uploaded image
      final mrzResult = await repository.extractMrz();
      if (mrzResult.success) {
        final validatedMrz = MrzValidator.validate(
          documentNumber: mrzResult.documentNumber,
          dateOfBirthStr: mrzResult.dateOfBirth,
          dateOfExpiryStr: mrzResult.dateOfExpiry,
        );

        if (validatedMrz != null) {
          emit(MrzExtracted(mrzResult));
        } else {
          emit(
            const MrzExtractionFailed(
              'Could not read all required passport data (Document Number, Date of Birth, Expiry). Please ensure the MRZ code is clearly visible and retake the photo.',
            ),
          );
        }
      } else {
        emit(
          MrzExtractionFailed(
            mrzResult.errorMessage ?? 'Could not read passport MRZ data',
          ),
        );
      }
    } on ApiException catch (e) {
      if (e.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (e.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(e.message));
      }
    } catch (e) {
      final apiEx = ApiException.from(e);
      if (apiEx.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (apiEx.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(apiEx.message));
      }
    }
  }
}

/// Actor that confirms verified MRZ data and persists it to the profile.
class MrzConfirmActor {
  const MrzConfirmActor();

  Future<void> execute({
    required MrzExtractionResult mrzResult,
    required VerificationRepository repository,
    required void Function(VerificationEvent) emit,
  }) async {
    try {
      await repository.confirmMrz(mrzResult.toConfirmPayload());
      emit(const MrzConfirmed());
    } on ApiException catch (e) {
      if (e.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else {
        emit(OperationalErrorOccurred(e.message));
      }
    } catch (e) {
      final apiEx = ApiException.from(e);
      if (apiEx.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else {
        emit(OperationalErrorOccurred(apiEx.message));
      }
    }
  }
}

/// Actor that uploads the selfie video and validates its quality.
class VideoUploadActor {
  const VideoUploadActor();

  Future<void> execute({
    required File videoFile,
    required VerificationRepository repository,
    required void Function(VerificationEvent) emit,
  }) async {
    try {
      await repository.uploadSelfie(
        videoFile,
        onProgress: (progress) {
          emit(SelfieUploadProgressUpdate(progress));
        },
      );

      emit(const SelfieUploaded('video'));

      final qualityResult = await repository.checkVideoQuality();
      if (!qualityResult.isAcceptable) {
        final errorMsg =
            qualityResult.uiGuidance ??
            qualityResult.message ??
            'Selfie video quality is insufficient. Please re-record your video.';
        emit(SelfieQualityFailed(errorMsg, qualityResult));
        return;
      }

      emit(SelfieQualityPassed(qualityResult));
    } on ApiException catch (e) {
      if (e.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (e.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(e.message));
      }
    } catch (e) {
      final apiEx = ApiException.from(e);
      if (apiEx.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (apiEx.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(apiEx.message));
      }
    }
  }
}

/// Actor that submits the verification documents to the ML pipeline.
class SubmitActor {
  const SubmitActor();

  Future<void> execute({
    Map<String, dynamic>? nfcPayload,
    required VerificationRepository repository,
    required void Function(VerificationEvent) emit,
  }) async {
    try {
      final submitResult = await repository.submitVerification(
        nfcPayload: nfcPayload,
      );

      if (submitResult.isVerified) {
        emit(
          SubmissionCompletedImmediate(
            isVerified: true,
            score: submitResult.verificationScore,
          ),
        );
      } else if (submitResult.isFailed) {
        emit(const SubmissionCompletedImmediate(isVerified: false));
      } else if (submitResult.verificationJobId != null) {
        emit(SubmissionAccepted(submitResult.verificationJobId!));
      } else {
        emit(const ReconcileRequested(force: true));
      }
    } on ApiException catch (e) {
      if (e.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (e.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(e.message));
      }
    } catch (e) {
      final apiEx = ApiException.from(e);
      if (apiEx.isAlreadyVerified) {
        emit(const AlreadyVerifiedDetected());
      } else if (apiEx.isAlreadySubmitted) {
        emit(const ReconcileRequested(force: true));
      } else {
        emit(OperationalErrorOccurred(apiEx.message));
      }
    }
  }
}

/// Actor that polls background ML pipeline progress with exponential backoff.
class PollingActor {
  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
  }

  Future<void> execute({
    required String jobId,
    required VerificationRepository repository,
    required void Function(VerificationEvent) emit,
    int initialIntervalSeconds = 2,
    int maxIntervalSeconds = 15,
    int maxDurationSeconds = 300,
  }) async {
    _isCancelled = false;
    int currentInterval = initialIntervalSeconds;
    int totalElapsed = 0;

    while (!_isCancelled && totalElapsed < maxDurationSeconds) {
      await Future.delayed(Duration(seconds: currentInterval));
      if (_isCancelled) break;

      try {
        final jobResult = await repository.getVerificationJob(jobId);
        VerificationStatus? domainStatus;

        if (jobResult.isComplete) {
          try {
            domainStatus = await repository.getVerificationStatus();
          } catch (_) {}
        }

        if (_isCancelled) break;

        emit(VerificationJobUpdated(jobResult, domainStatus));

        if (jobResult.isComplete) {
          break;
        }
      } catch (_) {
        // Non-critical network retry
      }

      totalElapsed += currentInterval;
      if (currentInterval < maxIntervalSeconds) {
        currentInterval = (currentInterval * 2).clamp(1, maxIntervalSeconds);
      }
    }
  }
}

/// Actor that coordinates NFC ePassport chip reading.
class NfcScanActor {
  const NfcScanActor();

  Future<void> execute({
    required NfcPassportService nfcService,
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(VerificationEvent) emit,
    void Function(NfcReadProgress)? onProgress,
  }) async {
    try {
      final result = await nfcService.readPassport(
        documentNumber: documentNumber,
        dateOfBirth: dateOfBirth,
        dateOfExpiry: dateOfExpiry,
        onProgress: onProgress ?? (_) {},
      );
      emit(NfcScanCompleted(result));
    } catch (e) {
      emit(OperationalErrorOccurred(e.toString()));
    }
  }
}
