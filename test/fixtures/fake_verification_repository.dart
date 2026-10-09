import 'dart:io';

import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

class FakeVerificationRepository implements VerificationRepository {
  bool uploadPassportCalled = false;
  bool checkImageQualityCalled = false;
  bool extractMrzCalled = false;
  bool uploadSelfieCalled = false;
  bool checkVideoQualityCalled = false;
  bool submitVerificationCalled = false;
  bool confirmMrzCalled = false;

  ImageQualityResult imageQualityResult = ImageQualityResult(
    success: true,
    status: 'passed',
    isAcceptable: true,
  );

  MrzExtractionResult mrzResult = MrzExtractionResult(
    success: true,
    documentNumber: 'AB1234567',
    dateOfBirth: '1990-01-15',
    dateOfExpiry: '2030-06-20',
    nationality: 'USA',
    firstName: 'JOHN',
    lastName: 'DOE',
  );

  VideoQualityResult videoQualityResult = VideoQualityResult(
    success: true,
    status: 'passed',
    isAcceptable: true,
  );

  VerificationStatus verificationStatus = const VerificationStatus(
    status: 'pending',
  );

  VerificationSubmitResult submitResult = VerificationSubmitResult(
    sessionId: 'session-123',
    status: 'verified',
    submittedAt: DateTime.utc(2026, 1, 1),
    verificationJobId: 'test-job-123',
  );

  VerificationJobResult jobResult = VerificationJobResult(
    id: 'test-job-123',
    travelerId: 'traveler-123',
    verificationSessionId: 'session-123',
    status: 'verified',
    verificationType: 'full',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  VerificationChallenge challenge = const VerificationChallenge(
    challengeId: 'test-challenge-123',
    challengeType: 'smile',
  );

  @override
  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  }) async {
    uploadPassportCalled = true;
    onProgress(1.0);
  }

  @override
  Future<ImageQualityResult> checkImageQuality() async {
    checkImageQualityCalled = true;
    return imageQualityResult;
  }

  @override
  Future<MrzExtractionResult> extractMrz() async {
    extractMrzCalled = true;
    return mrzResult;
  }

  @override
  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    uploadSelfieCalled = true;
    onProgress(1.0);
  }

  @override
  Future<VideoQualityResult> checkVideoQuality() async {
    checkVideoQualityCalled = true;
    return videoQualityResult;
  }

  @override
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    submitVerificationCalled = true;
    return submitResult;
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    return verificationStatus;
  }

  @override
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    return jobResult;
  }

  @override
  Future<VerificationChallenge> getVerificationChallenge() async {
    return challenge;
  }

  @override
  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzPayload payload) async {
    confirmMrzCalled = true;
    return {'status': 'confirmed'};
  }
}
