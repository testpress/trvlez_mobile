import 'dart:io';
import 'package:dio/dio.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';

class FakeVerificationRepository extends VerificationRepository {
  bool uploadPassportCalled = false;
  bool checkImageQualityCalled = false;
  bool extractMrzCalled = false;
  bool uploadSelfieCalled = false;
  bool checkVideoQualityCalled = false;

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

  FakeVerificationRepository() : super(dio: Dio());

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
}
