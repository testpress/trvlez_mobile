import 'dart:io';
import 'package:dio/dio.dart';
import 'package:trvlez_mobile/features/profile/data/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/profile/domain/profile.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

class FakeVerificationRepository extends VerificationRepository {
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

  VerificationStatus verificationStatus = VerificationStatus(
    sessionId: 'fake-sess-1',
    status: 'not_started',
    passportUploaded: false,
    videoUploaded: false,
  );

  VerificationSubmitResult submitResult = VerificationSubmitResult(
    sessionId: 'fake-sess-1',
    status: 'processing',
    submittedAt: DateTime.now(),
    verificationJobId: 'fake-job-1',
  );

  VerificationJobResult jobResult = VerificationJobResult(
    id: 'fake-job-1',
    travelerId: 'traveler-1',
    verificationSessionId: 'fake-sess-1',
    status: 'verified',
    verificationType: 'full',
    verificationScore: 97.5,
    createdAt: DateTime.now(),
  );

  FakeVerificationRepository() : super(dio: Dio());

  @override
  Future<void> startSession() async {}

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
  Future<Map<String, dynamic>> confirmMrz(Map<String, dynamic> payload) async {
    confirmMrzCalled = true;
    return {'status': 'ok'};
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
}

class FakeProfileRepository extends ProfileRepository {
  Profile profile = const Profile(
    id: 'fake-user-1',
    phone: '+1234567890',
    onboardingStep: 'profile_complete',
  );

  FakeProfileRepository()
    : super(remoteDataSource: ProfileRemoteDataSource(dio: Dio()));

  @override
  Future<Profile> getProfile() async {
    return profile;
  }
}
