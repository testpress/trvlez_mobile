import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/verification/data/models/confirm_mrz_dto.dart';
import 'package:trvlez_mobile/features/verification/data/models/verification_challenge_dto.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Contract for remote network calls related to traveler verification.
abstract interface class VerificationRemoteDataSource {
  Future<void> startVerification();

  Future<({String uploadUrl, String fileId})> initPassportUpload({
    required String mimeType,
    required int fileSizeBytes,
  });

  Future<void> completePassportUpload(String fileId);

  Future<({String uploadUrl, String fileId})> initSelfieUpload({
    required String mimeType,
    required int fileSizeBytes,
  });

  Future<void> completeSelfieUpload(String fileId);

  Future<ImageQualityResult> checkImageQuality();

  Future<VideoQualityResult> checkVideoQuality();

  Future<MrzExtractionResult> extractMrz();

  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  });

  Future<VerificationStatus> getVerificationStatus();

  Future<VerificationJobResult> getVerificationJob(String jobId);

  Future<VerificationChallengeDto> getVerificationChallenge();

  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzRequestDto payload);
}

/// Implementation of [VerificationRemoteDataSource] using Dio.
class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final Dio dio;
  static const Duration _verificationApiTimeout = Duration(seconds: 45);

  const VerificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> startVerification() async {
    await dio.post('/traveler/verification/start', data: {});
  }

  @override
  Future<({String uploadUrl, String fileId})> initPassportUpload({
    required String mimeType,
    required int fileSizeBytes,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/upload/passport/init',
      data: {'content_type': mimeType, 'file_size_bytes': fileSizeBytes},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response when initializing passport upload',
      );
    }

    final uploadUrl = data['upload_url'] as String? ?? '';
    final fileId = data['file_id'] as String? ?? '';
    return (uploadUrl: uploadUrl, fileId: fileId);
  }

  @override
  Future<void> completePassportUpload(String fileId) async {
    await dio.post('/upload/passport/complete', data: {'file_id': fileId});
  }

  @override
  Future<({String uploadUrl, String fileId})> initSelfieUpload({
    required String mimeType,
    required int fileSizeBytes,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/upload/video/init',
      data: {'content_type': mimeType, 'file_size_bytes': fileSizeBytes},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response when initializing selfie upload',
      );
    }

    final uploadUrl = data['upload_url'] as String? ?? '';
    final fileId = data['file_id'] as String? ?? '';
    return (uploadUrl: uploadUrl, fileId: fileId);
  }

  @override
  Future<void> completeSelfieUpload(String fileId) async {
    await dio.post('/upload/video/complete', data: {'file_id': fileId});
  }

  @override
  Future<ImageQualityResult> checkImageQuality() async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/image-quality',
      data: {},
      options: Options(
        receiveTimeout: _verificationApiTimeout,
        sendTimeout: _verificationApiTimeout,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty response from image quality check');
    }
    return ImageQualityResult.fromJson(data);
  }

  @override
  Future<VideoQualityResult> checkVideoQuality() async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/video-quality',
      data: {},
      options: Options(
        receiveTimeout: _verificationApiTimeout,
        sendTimeout: _verificationApiTimeout,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty response from video quality check');
    }
    return VideoQualityResult.fromJson(data);
  }

  @override
  Future<MrzExtractionResult> extractMrz() async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/extract-mrz',
      data: {},
      options: Options(
        receiveTimeout: _verificationApiTimeout,
        sendTimeout: _verificationApiTimeout,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty response from MRZ extraction');
    }
    return MrzExtractionResult.fromJson(data);
  }

  @override
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    final body = <String, dynamic>{};
    if (nfcPayload != null) {
      body['nfc_data'] = nfcPayload;
    }

    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/submit',
      data: body,
      options: Options(
        receiveTimeout: _verificationApiTimeout,
        sendTimeout: _verificationApiTimeout,
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response from verification submission',
      );
    }
    return VerificationSubmitResult.fromJson(data);
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/status',
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response from verification status endpoint',
      );
    }
    return VerificationStatus.fromJson(data);
  }

  @override
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/job/$jobId',
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response from verification job endpoint',
      );
    }
    return VerificationJobResult.fromJson(data);
  }

  @override
  Future<VerificationChallengeDto> getVerificationChallenge() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/challenge',
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response from verification challenge endpoint',
      );
    }
    return VerificationChallengeDto.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzRequestDto payload) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/confirm-mrz',
      data: payload.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response from MRZ confirmation endpoint',
      );
    }
    return data;
  }
}
