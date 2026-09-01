import 'dart:io';

import 'package:dio/dio.dart';

import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Repository for all verification-related operations.
///
/// Uses the shared [Dio] instance (with auth interceptor) for backend API calls.
/// S3 presigned URL uploads use a separate plain [Dio] instance without
/// interceptors to avoid injecting auth headers into S3 requests.
///
/// All methods guarantee that any network or transport error is cleanly
/// rethrown as a typed [ApiException].
class VerificationRepository {
  final Dio dio;

  const VerificationRepository({required this.dio});

  static const Duration _verificationApiTimeout = Duration(seconds: 45);

  /// Idempotently starts a verification session on the backend.
  Future<void> startSession() async {
    try {
      await dio.post('/traveler/verification/start', data: {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Uploads a passport photo to S3 and registers the upload with the backend.
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

      // 0. Ensure a verification session is started (Idempotent call on backend)
      await startSession();

      // 1. Initialize upload to get presigned URL
      final initResponse = await dio.post<Map<String, dynamic>>(
        '/upload/passport/init',
        data: {'content_type': mimeType, 'file_size_bytes': length},
      );

      final uploadUrl = initResponse.data!['upload_url'] as String;
      final fileId = initResponse.data!['file_id'] as String;

      // 2. Upload file directly to S3 using the presigned URL.
      await _uploadToS3(
        uploadUrl: uploadUrl,
        file: imageFile,
        mimeType: mimeType,
        fileLength: length,
        onProgress: onProgress,
      );

      // 3. Complete the upload on backend
      await dio.post('/upload/passport/complete', data: {'file_id': fileId});
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Uploads a selfie video to S3 and registers the upload with the backend.
  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      final length = await videoFile.length();
      final ext = videoFile.path.split('.').last.toLowerCase();

      String mimeType = 'video/mp4';
      if (ext == 'mov') mimeType = 'video/quicktime';

      // 0. Ensure a verification session is started (Idempotent call on backend)
      await startSession();

      // 1. Initialize upload to get presigned URL
      final initResponse = await dio.post<Map<String, dynamic>>(
        '/upload/video/init',
        data: {'content_type': mimeType, 'file_size_bytes': length},
      );

      final uploadUrl = initResponse.data!['upload_url'] as String;
      final fileId = initResponse.data!['file_id'] as String;

      // 2. Upload file directly to S3 using the presigned URL.
      await _uploadToS3(
        uploadUrl: uploadUrl,
        file: videoFile,
        mimeType: mimeType,
        fileLength: length,
        onProgress: onProgress,
      );

      // 3. Complete the upload on backend
      await dio.post('/upload/video/complete', data: {'file_id': fileId});
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Validates passport image quality (blur, face existence, MRZ presence).
  Future<ImageQualityResult> checkImageQuality() async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/traveler/verification/image-quality',
        data: {},
        options: Options(
          receiveTimeout: _verificationApiTimeout,
          sendTimeout: _verificationApiTimeout,
        ),
      );
      return ImageQualityResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Validates selfie video quality (blur variance across frames).
  Future<VideoQualityResult> checkVideoQuality() async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/traveler/verification/video-quality',
        data: {},
        options: Options(
          receiveTimeout: _verificationApiTimeout,
          sendTimeout: _verificationApiTimeout,
        ),
      );
      return VideoQualityResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Extracts MRZ data from the uploaded passport image.
  Future<MrzExtractionResult> extractMrz() async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/traveler/verification/extract-mrz',
        data: {},
        options: Options(
          receiveTimeout: _verificationApiTimeout,
          sendTimeout: _verificationApiTimeout,
        ),
      );
      return MrzExtractionResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Submits the verification session for ML pipeline processing.
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    try {
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
      return VerificationSubmitResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Fetches the current verification session status.
  Future<VerificationStatus> getVerificationStatus() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/traveler/verification/status',
      );
      return VerificationStatus.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Polls the status of a specific verification job.
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/traveler/verification/job/$jobId',
      );
      return VerificationJobResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// Confirms MRZ-extracted passport data and persists it to the traveller profile.
  Future<Map<String, dynamic>> confirmMrz(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/traveler/verification/confirm-mrz',
        data: payload,
      );
      return response.data!;
    } on DioException catch (e) {
      throw ApiException.from(e);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────────

  /// Uploads a file to S3 via a presigned PUT URL with progress tracking.
  Future<void> _uploadToS3({
    required String uploadUrl,
    required File file,
    required String mimeType,
    required int fileLength,
    required void Function(double progress) onProgress,
  }) async {
    final s3Dio = Dio(
      BaseOptions(
        connectTimeout: _verificationApiTimeout,
        sendTimeout: _verificationApiTimeout,
        receiveTimeout: _verificationApiTimeout,
      ),
    );

    try {
      final fileStream = file.openRead();

      final response = await s3Dio.put<void>(
        uploadUrl,
        data: fileStream,
        options: Options(
          headers: {'Content-Type': mimeType, 'Content-Length': fileLength},
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException.fromStatusCode(
          statusCode,
          'Storage upload failed with status $statusCode',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromStatusCode(
        e.response?.statusCode ?? 0,
        'Storage upload failed: ${e.message}',
      );
    } finally {
      s3Dio.close();
    }
  }
}
