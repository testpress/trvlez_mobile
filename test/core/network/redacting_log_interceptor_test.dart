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

    test('onRequest logs route metadata without headers or body fields', () {
      const interceptor = RedactingLogInterceptor();
      final options = RequestOptions(
        path: '/api/v1/auth/login',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer secret_jwt_token',
          'Content-Type': 'application/json',
        },
        data: {'email': 'user@example.com', 'password': 'SuperSecretPassword'},
      );

      final handler = RequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      expect(capturedLogs.length, equals(1));
      final log = capturedLogs.first;
      expect(log, contains('POST /api/v1/auth/login'));
      expect(log, isNot(contains('Authorization')));
      expect(log, isNot(contains('email')));
      expect(log, isNot(contains('user@example.com')));
      expect(log, isNot(contains('secret_jwt_token')));
      expect(log, isNot(contains('SuperSecretPassword')));
    });

    test('onResponse logs route metadata without response body fields', () {
      const interceptor = RedactingLogInterceptor();
      final response = Response(
        requestOptions: RequestOptions(path: '/api/v1/auth/token'),
        statusCode: 200,
        data: {
          'email': 'traveller@example.com',
          'phone': '+15551234567',
          'address_line_1': '1 Test Street',
        },
      );

      final handler = ResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(capturedLogs.length, equals(1));
      final log = capturedLogs.first;
      expect(log, contains('200 /api/v1/auth/token'));
      expect(log, isNot(contains('traveller@example.com')));
      expect(log, isNot(contains('+15551234567')));
      expect(log, isNot(contains('1 Test Street')));
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
