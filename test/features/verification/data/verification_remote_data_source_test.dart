import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:trvlez_mobile/features/verification/data/dto/confirm_mrz_dto.dart';

void main() {
  group('VerificationRemoteDataSourceImpl', () {
    late Dio dio;
    late VerificationRemoteDataSourceImpl dataSource;

    setUp(() {
      dio = Dio();
      dataSource = VerificationRemoteDataSourceImpl(dio: dio);
    });

    test('startVerification posts to /traveler/verification/start', () async {
      RequestOptions? recordedOptions;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            recordedOptions = options;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: {}),
            );
          },
        ),
      );

      await dataSource.startVerification();
      expect(recordedOptions?.path, '/traveler/verification/start');
    });

    test('initPassportUpload returns uploadUrl and fileId', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'upload_url': 'https://s3.example.com/put',
                  'file_id': 'pass-uuid',
                },
              ),
            );
          },
        ),
      );

      final res = await dataSource.initPassportUpload(
        mimeType: 'image/jpeg',
        fileSizeBytes: 1024,
      );

      expect(res.uploadUrl, 'https://s3.example.com/put');
      expect(res.fileId, 'pass-uuid');
    });

    test('initPassportUpload throws ServerException on null data', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: null),
            );
          },
        ),
      );

      expect(
        () => dataSource.initPassportUpload(
          mimeType: 'image/jpeg',
          fileSizeBytes: 1024,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('completePassportUpload posts fileId', () async {
      RequestOptions? recordedOptions;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            recordedOptions = options;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: {}),
            );
          },
        ),
      );

      await dataSource.completePassportUpload('pass-uuid');
      expect(recordedOptions?.path, '/upload/passport/complete');
      expect(recordedOptions?.data, {'file_id': 'pass-uuid'});
    });

    test('initSelfieUpload and completeSelfieUpload', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/upload/video/init') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'upload_url': 'https://s3.example.com/selfie',
                    'file_id': 'vid-1',
                  },
                ),
              );
            } else {
              handler.resolve(
                Response(requestOptions: options, statusCode: 200, data: {}),
              );
            }
          },
        ),
      );

      final init = await dataSource.initSelfieUpload(
        mimeType: 'video/mp4',
        fileSizeBytes: 2048,
      );
      expect(init.fileId, 'vid-1');

      await dataSource.completeSelfieUpload('vid-1');
    });

    test('checkImageQuality parses response correctly', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'status': 'passed',
                  'is_acceptable': true,
                },
              ),
            );
          },
        ),
      );

      final result = await dataSource.checkImageQuality();
      expect(result.success, isTrue);
      expect(result.status, 'passed');
      expect(result.isAcceptable, isTrue);
    });

    test('checkVideoQuality parses response correctly', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': false,
                  'status': 'failed',
                  'is_acceptable': false,
                  'message': 'blurry',
                },
              ),
            );
          },
        ),
      );

      final result = await dataSource.checkVideoQuality();
      expect(result.success, isFalse);
      expect(result.status, 'failed');
      expect(result.isAcceptable, isFalse);
      expect(result.message, 'blurry');
    });

    test('extractMrz parses response correctly', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'raw_text': 'P<USA...',
                  'document_number': 'P12345678',
                  'first_name': 'JOHN',
                  'last_name': 'DOE',
                  'nationality': 'USA',
                  'date_of_birth': '1990-01-01',
                  'date_of_expiry': '2030-01-01',
                },
              ),
            );
          },
        ),
      );

      final result = await dataSource.extractMrz();
      expect(result.documentNumber, 'P12345678');
      expect(result.firstName, 'JOHN');
      expect(result.lastName, 'DOE');
    });

    test('submitVerification posts payload and returns result', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'session_id': 'sess-123',
                  'verification_job_id': 'job-999',
                  'status': 'queued',
                  'submitted_at': '2025-01-01T12:00:00Z',
                },
              ),
            );
          },
        ),
      );

      final result = await dataSource.submitVerification(
        nfcPayload: {'test': true},
      );
      expect(result.verificationJobId, 'job-999');
      expect(result.status, 'queued');
      expect(result.sessionId, 'sess-123');
    });

    test('getVerificationStatus parses status and flags', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'session_id': 'sess-1',
                  'status': 'verified',
                  'passport_uploaded': true,
                  'video_uploaded': true,
                },
              ),
            );
          },
        ),
      );

      final status = await dataSource.getVerificationStatus();
      expect(status.status, 'verified');
      expect(status.isVerified, isTrue);
      expect(status.passportUploaded, isTrue);
    });

    test('getVerificationJob parses job result', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'job-1',
                  'traveler_id': 'traveler-1',
                  'verification_session_id': 'sess-1',
                  'status': 'completed',
                  'created_at': '2025-01-01T12:00:00Z',
                },
              ),
            );
          },
        ),
      );

      final job = await dataSource.getVerificationJob('job-1');
      expect(job.id, 'job-1');
      expect(job.status, 'completed');
    });

    test('getVerificationChallenge parses challenge DTO', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'challenge_id': 'c-1', 'challenge_type': 'nod'},
              ),
            );
          },
        ),
      );

      final challenge = await dataSource.getVerificationChallenge();
      expect(challenge.challengeId, 'c-1');
      expect(challenge.challengeType, 'nod');
    });

    test('confirmMrz posts serialized DTO', () async {
      RequestOptions? recordedOptions;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            recordedOptions = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      const dto = ConfirmMrzRequestDto(
        firstName: 'JOHN',
        lastName: 'DOE',
        passportNumber: 'P123',
        nationality: 'USA',
        dateOfBirth: '1990-01-01',
        dateOfExpiry: '2030-01-01',
      );

      final res = await dataSource.confirmMrz(dto);
      expect(recordedOptions?.path, '/traveler/verification/confirm-mrz');
      expect(res['success'], isTrue);
    });
  });
}
