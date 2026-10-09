import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/s3_upload_client.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:trvlez_mobile/features/verification/data/models/confirm_mrz_dto.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/repositories/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Implementation of [VerificationRepository] coordinating remote API calls
/// and storage uploads.
class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  final S3UploadClient s3UploadClient;

  const VerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.s3UploadClient,
  });

  @override
  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      final length = await imageFile.length();
      final ext = imageFile.path.split('.').last.toLowerCase();

      String mimeType = 'image/jpeg';
      if (ext == 'png') mimeType = 'image/png';
      if (ext == 'webp') mimeType = 'image/webp';

      await remoteDataSource.startVerification();

      final init = await remoteDataSource.initPassportUpload(
        mimeType: mimeType,
        fileSizeBytes: length,
      );

      await s3UploadClient.upload(
        uploadUrl: init.uploadUrl,
        file: imageFile,
        mimeType: mimeType,
        fileLength: length,
        onProgress: onProgress,
      );

      await remoteDataSource.completePassportUpload(init.fileId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      final length = await videoFile.length();
      final ext = videoFile.path.split('.').last.toLowerCase();

      String mimeType = 'video/mp4';
      if (ext == 'mov') mimeType = 'video/quicktime';

      await remoteDataSource.startVerification();

      final init = await remoteDataSource.initSelfieUpload(
        mimeType: mimeType,
        fileSizeBytes: length,
      );

      await s3UploadClient.upload(
        uploadUrl: init.uploadUrl,
        file: videoFile,
        mimeType: mimeType,
        fileLength: length,
        onProgress: onProgress,
      );

      await remoteDataSource.completeSelfieUpload(init.fileId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<ImageQualityResult> checkImageQuality() async {
    try {
      return await remoteDataSource.checkImageQuality();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<VideoQualityResult> checkVideoQuality() async {
    try {
      return await remoteDataSource.checkVideoQuality();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<MrzExtractionResult> extractMrz() async {
    try {
      return await remoteDataSource.extractMrz();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    try {
      return await remoteDataSource.submitVerification(nfcPayload: nfcPayload);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    try {
      return await remoteDataSource.getVerificationStatus();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    try {
      return await remoteDataSource.getVerificationJob(jobId);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<VerificationChallenge> getVerificationChallenge() async {
    try {
      final dto = await remoteDataSource.getVerificationChallenge();
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzPayload payload) async {
    try {
      final dto = ConfirmMrzRequestDto.fromDomain(payload);
      return await remoteDataSource.confirmMrz(dto);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
