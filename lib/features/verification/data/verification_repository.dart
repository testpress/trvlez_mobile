import 'dart:io';

import 'package:dio/dio.dart';

import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Repository for all verification-related operations.
///
/// Uses the shared [Dio] instance (with auth interceptor) for backend API calls.
/// S3 presigned URL uploads use a separate plain [Dio] instance without
/// interceptors to avoid injecting auth headers into S3 requests.
class VerificationRepository {
  final Dio dio;

  const VerificationRepository({required this.dio});

  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  }) async {
    final length = await imageFile.length();
    final ext = imageFile.path.split('.').last.toLowerCase();

    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    if (ext == 'webp') mimeType = 'image/webp';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await dio.post('/traveler/verification/start', data: {});

    // 1. Initialize upload to get presigned URL
    final initResponse = await dio.post<Map<String, dynamic>>(
      '/upload/passport/init',
      data: {'content_type': mimeType, 'file_size_bytes': length},
    );

    final uploadUrl = initResponse.data!['upload_url'] as String;
    final fileId = initResponse.data!['file_id'] as String;

    // 2. Upload file directly to S3 using the presigned URL.
    //    Uses a separate plain Dio instance — no auth interceptor, no base URL.
    await _uploadToS3(
      uploadUrl: uploadUrl,
      file: imageFile,
      mimeType: mimeType,
      fileLength: length,
      onProgress: onProgress,
    );

    // 3. Complete the upload
    await dio.post(
      '/upload/passport/complete',
      data: {'file_id': fileId},
    );
  }

  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    final length = await videoFile.length();
    final ext = videoFile.path.split('.').last.toLowerCase();

    String mimeType = 'video/mp4';
    if (ext == 'mov') mimeType = 'video/quicktime';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await dio.post('/traveler/verification/start', data: {});

    // 1. Initialize upload to get presigned URL
    final initResponse = await dio.post<Map<String, dynamic>>(
      '/upload/video/init',
      data: {'content_type': mimeType, 'file_size_bytes': length},
    );

    final uploadUrl = initResponse.data!['upload_url'] as String;
    final fileId = initResponse.data!['file_id'] as String;

    // 2. Upload file directly to S3 using the presigned URL.
    //    Uses a separate plain Dio instance — no auth interceptor, no base URL.
    await _uploadToS3(
      uploadUrl: uploadUrl,
      file: videoFile,
      mimeType: mimeType,
      fileLength: length,
      onProgress: onProgress,
    );

    // 3. Complete the upload
    await dio.post(
      '/upload/video/complete',
      data: {'file_id': fileId},
    );
  }

  /// Extracts MRZ data from the uploaded passport image.
  ///
  /// This should be called immediately after [uploadPassport] completes
  /// to fetch the document number, DOB, and expiry date needed for NFC chip authentication.
  Future<MrzExtractionResult> extractMrz() async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/extract-mrz',
      data: {},
    );

    return MrzExtractionResult.fromJson(response.data!);
  }

  /// Submits the verification session for ML pipeline processing.
  ///
  /// Returns [VerificationSubmitResult] containing the job ID for polling
  /// and an optional verification score if the pipeline completes inline.
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
    );

    return VerificationSubmitResult.fromJson(response.data!);
  }

  /// Fetches the current verification session status.
  ///
  /// Returns [VerificationStatus] which may have null fields if no
  /// active session exists. Used to detect the `failed` state which
  /// only exists on [VerificationSessionStatus], not on
  /// [TravelerOnboardingStep].
  Future<VerificationStatus> getVerificationStatus() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/status',
    );

    return VerificationStatus.fromJson(response.data!);
  }

  /// Polls the status of a specific verification job.
  ///
  /// Used to track ML pipeline progress after submission.
  /// The backend returns the full job record including score and error details.
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/job/$jobId',
    );

    return VerificationJobResult.fromJson(response.data!);
  }

  /// Generates a liveness challenge session from the verification service.
  ///
  /// Returns the challenge data (e.g., challenge type, session ID) for
  /// the traveler to perform during selfie capture. Reserved for future use
  /// when liveness detection is enabled.
  Future<Map<String, dynamic>> getVerificationChallenge() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/verification/challenge',
    );

    return response.data!;
  }

  /// Confirms MRZ-extracted passport data and persists it to the traveller profile.
  ///
  /// Called after the traveller reviews the extracted details on the MRZ review screen.
  /// Returns the updated profile response from the backend.
  Future<Map<String, dynamic>> confirmMrz(Map<String, dynamic> payload) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/verification/confirm-mrz',
      data: payload,
    );

    return response.data!;
  }

  // ─── Private Helpers ──────────────────────────────────────────────

  /// Uploads a file to S3 via a presigned PUT URL with progress tracking.
  ///
  /// Uses a separate plain [Dio] instance without interceptors to avoid
  /// injecting auth headers or applying error mapping meant for the backend.
  Future<void> _uploadToS3({
    required String uploadUrl,
    required File file,
    required String mimeType,
    required int fileLength,
    required void Function(double progress) onProgress,
  }) async {
    final s3Dio = Dio();

    try {
      final fileStream = file.openRead();

      final response = await s3Dio.put<void>(
        uploadUrl,
        data: fileStream,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileLength,
          },
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
