import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';

/// Network utility responsible for uploading files to S3 via presigned PUT URLs.
///
/// Uses an isolated [Dio] client without authorization interceptors to avoid
/// injecting bearer tokens into external S3 storage requests.
class S3UploadClient {
  final Dio Function()? dioFactory;
  static const Duration _timeout = Duration(seconds: 45);

  const S3UploadClient({this.dioFactory});

  Dio _createDio() {
    if (dioFactory != null) {
      return dioFactory!();
    }
    return Dio(
      BaseOptions(
        connectTimeout: _timeout,
        sendTimeout: _timeout,
        receiveTimeout: _timeout,
      ),
    );
  }

  /// Uploads [file] to [uploadUrl] via HTTP PUT with progress tracking.
  Future<void> upload({
    required String uploadUrl,
    required File file,
    required String mimeType,
    required int fileLength,
    required void Function(double progress) onProgress,
  }) async {
    final client = _createDio();

    try {
      final fileStream = file.openRead();

      final response = await client.put<void>(
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
      client.close();
    }
  }
}
