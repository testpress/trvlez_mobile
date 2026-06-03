import 'dart:io';

import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';

class VerificationRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  VerificationRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  Future<void> uploadPassport(
    File imageFile, {
    required void Function(double progress) onProgress,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final length = await imageFile.length();
    final ext = imageFile.path.split('.').last.toLowerCase();
    
    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    if (ext == 'webp') mimeType = 'image/webp';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await _apiClient.post(
      '/traveler/verification/start',
      body: {},
      authToken: token,
    );

    // 1. Initialize upload to get presigned URL
    final initResponse = await _apiClient.post(
      '/upload/passport/init',
      body: {
        'content_type': mimeType,
        'file_size_bytes': length,
      },
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
    await _apiClient.post(
      '/upload/passport/complete',
      body: {
        'file_id': fileId,
      },
      authToken: token,
    );
  }

  Future<void> uploadSelfie(
    File videoFile, {
    required void Function(double progress) onProgress,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    final length = await videoFile.length();
    final ext = videoFile.path.split('.').last.toLowerCase();
    
    String mimeType = 'video/mp4';
    if (ext == 'mov') mimeType = 'video/quicktime';

    // 0. Ensure a verification session is started (Idempotent call on backend)
    await _apiClient.post(
      '/traveler/verification/start',
      body: {},
      authToken: token,
    );

    // 1. Initialize upload to get presigned URL
    final initResponse = await _apiClient.post(
      '/upload/video/init',
      body: {
        'content_type': mimeType,
        'file_size_bytes': length,
      },
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
    await _apiClient.post(
      '/upload/video/complete',
      body: {
        'file_id': fileId,
      },
      authToken: token,
    );
  }

  Future<void> submitVerification() async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw ApiException.unauthorized();

    await _apiClient.post(
      '/traveler/verification/submit',
      body: {},
      authToken: token,
    );
  }
}
