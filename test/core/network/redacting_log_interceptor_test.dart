import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/network/redacting_log_interceptor.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

class _CapturingErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? passedError;

  @override
  void next(DioException err) {
    passedError = err;
  }
}

void main() {
  group('RedactingLogInterceptor', () {
    late List<String> capturedLogs;

    setUp(() {
      capturedLogs = [];
      AppLogger.outputPrinter = capturedLogs.add;
    });

    tearDown(() {
      AppLogger.outputPrinter = null;
    });

    test(
      'onRequest redacts authorization header and sensitive body fields',
      () {
        const interceptor = RedactingLogInterceptor();
        final options = RequestOptions(
          path: '/api/v1/auth/login',
          method: 'POST',
          headers: {
            'Authorization': 'Bearer secret_jwt_token',
            'Content-Type': 'application/json',
          },
          data: {
            'email': 'user@example.com',
            'password': 'SuperSecretPassword',
          },
        );

        final handler = RequestInterceptorHandler();
        interceptor.onRequest(options, handler);

        expect(capturedLogs.length, equals(1));
        final log = capturedLogs.first;
        expect(log, contains('POST /api/v1/auth/login'));
        expect(log, contains('Authorization: [REDACTED]'));
        expect(log, contains('password: [REDACTED]'));
        expect(log, isNot(contains('secret_jwt_token')));
        expect(log, isNot(contains('SuperSecretPassword')));
      },
    );

    test('onResponse redacts sensitive response body fields', () {
      const interceptor = RedactingLogInterceptor();
      final response = Response(
        requestOptions: RequestOptions(path: '/api/v1/auth/token'),
        statusCode: 200,
        data: {
          'access_token': 'new_access_token_123',
          'refresh_token': 'new_refresh_token_456',
          'user_id': 'u-999',
        },
      );

      final handler = ResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(capturedLogs.length, equals(1));
      final log = capturedLogs.first;
      expect(log, contains('200 /api/v1/auth/token'));
      expect(log, contains('access_token: [REDACTED]'));
      expect(log, contains('refresh_token: [REDACTED]'));
      expect(log, isNot(contains('new_access_token_123')));
      expect(log, isNot(contains('new_refresh_token_456')));
    });

    test('onError logs status code and path without dumping raw payload', () {
      const interceptor = RedactingLogInterceptor();
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/sensitive/resource'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/sensitive/resource'),
          statusCode: 403,
          data: {'secret': 'private_server_data'},
        ),
        type: DioExceptionType.badResponse,
      );

      final handler = _CapturingErrorInterceptorHandler();
      interceptor.onError(err, handler);

      expect(handler.passedError, equals(err));
      expect(capturedLogs.length, equals(1));
      final log = capturedLogs.first;
      expect(log, contains('ERROR 403 /api/v1/sensitive/resource'));
      expect(log, isNot(contains('private_server_data')));
    });
  });
}
