import 'dart:io';

import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/verification_job_result.dart';
import '../domain/verification_status.dart';
import '../domain/verification_submit_result.dart';

class VerificationRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  VerificationRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : apiClient = apiClient ?? ApiClient(),
      tokenStorage = tokenStorage ?? const TokenStorage();

  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  }) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final length = await imageFile.length();
    final ext = imageFile.path.split('.').last.toLowerCase();

    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    if (ext == 'webp') mimeType = 'image/webp';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await apiClient.post(
      '/traveler/verification/start',
      body: {},
      authToken: token,
    );

    // 1. Initialize upload to get presigned URL
    final initResponse = await apiClient.post(
      '/upload/passport/init',
      body: {'content_type': mimeType, 'file_size_bytes': length},
      authToken: token,
    );

    final uploadUrl = initResponse['upload_url'] as String;
    final fileId = initResponse['file_id'] as String;

    // 2. Upload file directly to S3 using the presigned URL
    final uri = Uri.parse(uploadUrl);
    final request = http.StreamedRequest('PUT', uri);
    request.headers['Content-Type'] = mimeType;
    request.contentLength = length;

    int bytes = 0;
    final stream = imageFile.openRead();

    // Listen to the stream to update progress and add to request sink
    stream.listen(
      (chunk) {
        bytes += chunk.length;
        if (length > 0) {
          onProgress(bytes / length);
        }
        request.sink.add(chunk);
      },
      onDone: () => request.sink.close(),
      onError: (e) => request.sink.addError(e),
    );

    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseBody = await response.stream.bytesToString();
      throw ApiException.fromStatusCode(
        response.statusCode,
        'Storage upload failed: $responseBody',
      );
    }

    // 3. Complete the upload
    await apiClient.post(
      '/upload/passport/complete',
      body: {'file_id': fileId},
      authToken: token,
    );
  }

  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final length = await videoFile.length();
    final ext = videoFile.path.split('.').last.toLowerCase();

    String mimeType = 'video/mp4';
    if (ext == 'mov') mimeType = 'video/quicktime';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await apiClient.post(
      '/traveler/verification/start',
      body: {},
      authToken: token,
    );

    // 1. Initialize upload to get presigned URL
    final initResponse = await apiClient.post(
      '/upload/video/init',
      body: {'content_type': mimeType, 'file_size_bytes': length},
      authToken: token,
    );

    final uploadUrl = initResponse['upload_url'] as String;
    final fileId = initResponse['file_id'] as String;

    // 2. Upload file directly to S3 using the presigned URL
    final uri = Uri.parse(uploadUrl);
    final request = http.StreamedRequest('PUT', uri);
    request.headers['Content-Type'] = mimeType;
    request.contentLength = length;

    int bytes = 0;
    final stream = videoFile.openRead();

    // Listen to the stream to update progress and add to request sink
    stream.listen(
      (chunk) {
        bytes += chunk.length;
        if (length > 0) {
          onProgress(bytes / length);
        }
        request.sink.add(chunk);
      },
      onDone: () => request.sink.close(),
      onError: (e) => request.sink.addError(e),
    );

    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseBody = await response.stream.bytesToString();
      throw ApiException.fromStatusCode(
        response.statusCode,
        'Storage upload failed: $responseBody',
      );
    }

    // 3. Complete the upload
    await apiClient.post(
      '/upload/video/complete',
      body: {'file_id': fileId},
      authToken: token,
    );
  }

  /// Submits the verification session for ML pipeline processing.
  ///
  /// Returns [VerificationSubmitResult] containing the job ID for polling
  /// and an optional verification score if the pipeline completes inline.
  Future<VerificationSubmitResult> submitVerification() async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final response = await apiClient.post(
      '/traveler/verification/submit',
      body: {},
      authToken: token,
    );

    return VerificationSubmitResult.fromJson(response);
  }

  /// Fetches the current verification session status.
  ///
  /// Returns [VerificationStatus] which may have null fields if no
  /// active session exists. Used to detect the `failed` state which
  /// only exists on [VerificationSessionStatus], not on
  /// [TravelerOnboardingStep].
  Future<VerificationStatus> getVerificationStatus() async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final response = await apiClient.get(
      '/traveler/verification/status',
      authToken: token,
    );

    return VerificationStatus.fromJson(response);
  }

  /// Polls the status of a specific verification job.
  ///
  /// Used to track ML pipeline progress after submission.
  /// The backend returns the full job record including score and error details.
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final response = await apiClient.get(
      '/traveler/verification/job/$jobId',
      authToken: token,
    );

    return VerificationJobResult.fromJson(response);
  }

  /// Generates a liveness challenge session from the verification service.
  ///
  /// Returns the challenge data (e.g., challenge type, session ID) for
  /// the traveler to perform during selfie capture. Reserved for future use
  /// when liveness detection is enabled.
  Future<Map<String, dynamic>> getVerificationChallenge() async {
    final token = await tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final response = await apiClient.get(
      '/traveler/verification/challenge',
      authToken: token,
    );

    return response;
  }
}
