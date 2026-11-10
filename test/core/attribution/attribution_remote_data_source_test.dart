import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
import 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';

class MockDioAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AttributionRemoteDataSource', () {
    late Dio dio;
    late MockDioAdapter mockAdapter;
    late AttributionRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1'));
      mockAdapter = MockDioAdapter();
      dio.httpClientAdapter = mockAdapter;
      dataSource = AttributionRemoteDataSource(dio: dio);
    });

    test('successfully records install evidence with 200 response', () async {
      mockAdapter.handler = (options) {
        expect(
          options.path,
          equals('/public/referrals/traveler/install-evidence'),
        );
        expect(options.method, equals('POST'));
        final data = options.data as Map<String, dynamic>;
        expect(data['click_reference'], equals('sample_click_ref_12345'));
        expect(data['occurred_at'], contains('2026-11-10T'));

        return ResponseBody.fromString(
          '{"valid": true, "message": "Install evidence successfully verified.", "referral_id": "b96a9870-137b-4b2a-8ffc-11234567890a"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await dataSource.recordInstallEvidence(
        InstallEvidenceRequestDto(
          clickReference: 'sample_click_ref_12345',
          occurredAt: DateTime.utc(2026, 11, 10, 10, 30, 0),
        ),
      );

      expect(response.valid, isTrue);
      expect(response.message, contains('verified'));
      expect(response.referralId, equals('b96a9870-137b-4b2a-8ffc-11234567890a'));
    });

    test('throws ServerException on null or empty response payload', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString('', 204);
      };

      expect(
        () => dataSource.recordInstallEvidence(
          const InstallEvidenceRequestDto(
            clickReference: 'sample_click_ref_12345',
          ),
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('propagates DioException when server responds with 404', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          '{"detail": "Invalid or expired click reference."}',
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => dataSource.recordInstallEvidence(
          const InstallEvidenceRequestDto(
            clickReference: 'non_existent_reference_xyz',
          ),
        ),
        throwsA(
          isA<DioException>().having(
            (dioError) => dioError.response?.statusCode,
            'statusCode',
            equals(404),
          ),
        ),
      );
    });
  });
}

