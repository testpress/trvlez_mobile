import 'dart:io';

import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Domain contract for traveler identity verification operations.
abstract interface class VerificationRepository {
  /// Initiates an enterprise re-verification session for an already-verified traveler.
  Future<void> startReverification();

  /// Uploads a passport photo to storage with upload progress tracking.
  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  });

  /// Uploads a selfie video to storage with upload progress tracking.
  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  });

  /// Validates passport image quality (blur, glare, face & MRZ detection).
  Future<ImageQualityResult> checkImageQuality();

  /// Validates selfie video quality (blur variance across frames).
  Future<VideoQualityResult> checkVideoQuality();

  /// Extracts MRZ data from the uploaded passport image.
  Future<MrzExtractionResult> extractMrz();

  /// Submits the verification session and optional NFC payload to ML pipeline.
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  });

  /// Fetches the current verification session status.
  Future<VerificationStatus> getVerificationStatus();

  /// Polls the status of an ongoing verification ML job.
  Future<VerificationJobResult> getVerificationJob(String jobId);

  /// Generates a liveness challenge session for traveler verification.
  Future<VerificationChallenge> getVerificationChallenge();

  /// Confirms verified MRZ passport data and persists it to traveler profile.
  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzPayload payload);
}
