import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/s3_upload_client.dart';

void main() {
  group('S3UploadClient', () {
    late Directory tempDir;
    late File dummyFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('s3_test_');
      dummyFile = File('${tempDir.path}/sample.jpg');
      dummyFile.writeAsBytesSync([10, 20, 30, 40]);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('successful upload invokes PUT and triggers onProgress', () async {
      final dio = Dio();
      RequestOptions? recordedOptions;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          recordedOptions = options;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
          ));
        },
      ));

      final client = S3UploadClient(dioFactory: () => dio);

      await client.upload(
        uploadUrl: 'https://s3.example.com/test-bucket/file.jpg',
        file: dummyFile,
        mimeType: 'image/jpeg',
        fileLength: 4,
        onProgress: (_) {},
      );

      expect(recordedOptions?.method, 'PUT');
      expect(recordedOptions?.headers['Content-Type'], 'image/jpeg');
      expect(recordedOptions?.headers['Content-Length'], 4);
    });

    test('throws ApiException on HTTP error status code', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 403,
          ));
        },
      ));

      final client = S3UploadClient(dioFactory: () => dio);

      expect(
        () => client.upload(
          uploadUrl: 'https://s3.example.com/forbidden',
          file: dummyFile,
          mimeType: 'image/jpeg',
          fileLength: 4,
          onProgress: (_) {},
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on DioException', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Timed out',
          ));
        },
      ));

      final client = S3UploadClient(dioFactory: () => dio);

      expect(
        () => client.upload(
          uploadUrl: 'https://s3.example.com/timeout',
          file: dummyFile,
          mimeType: 'image/jpeg',
          fileLength: 4,
          onProgress: (_) {},
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
