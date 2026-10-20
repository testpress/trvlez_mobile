import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/core/network/error_interceptor.dart';

class _CapturingInterceptorHandler extends ErrorInterceptorHandler {
  DioException? rejectedError;

  @override
  void reject(DioException error, [bool? callNext]) {
    rejectedError = error;
  }
}

void main() {
  group('ErrorInterceptor Tests', () {
    late bool unauthorizedCalled;
    late ErrorInterceptor interceptor;

    setUp(() {
      unauthorizedCalled = false;
      interceptor = ErrorInterceptor(
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );
    });

    test('401 on login endpoint does not call onUnauthorized and parses error message', () {
      final handler = _CapturingInterceptorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/login/access-token'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/login/access-token'),
          statusCode: 401,
          data: {'detail': 'Incorrect email or password'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      expect(unauthorizedCalled, isFalse);
      expect(handler.rejectedError, isNotNull);
      final apiException = handler.rejectedError!.error as ApiException;
      expect(apiException.statusCode, 401);
      expect(apiException.message, 'Incorrect email or password');
    });

    test('401 on signup endpoint does not call onUnauthorized and provides auth error', () {
      final handler = _CapturingInterceptorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/traveler/signup'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/traveler/signup'),
          statusCode: 401,
          data: {'detail': 'Account already exists'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      expect(unauthorizedCalled, isFalse);
      final apiException = handler.rejectedError!.error as ApiException;
      expect(apiException.statusCode, 401);
      expect(apiException.message, 'Account already exists');
    });

    test('401 on protected endpoint calls onUnauthorized and returns session expired', () {
      final handler = _CapturingInterceptorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/traveler/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/traveler/profile'),
          statusCode: 401,
          data: {'detail': 'Signature has expired'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      expect(unauthorizedCalled, isTrue);
      final apiException = handler.rejectedError!.error as ApiException;
      expect(apiException.statusCode, 401);
      expect(apiException.message, 'Session expired. Please log in again.');
    });

    test('400 with validation list is parsed cleanly', () {
      final handler = _CapturingInterceptorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/traveler/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/traveler/profile'),
          statusCode: 422,
          data: {
            'detail': [
              {'msg': 'Field required'},
              {'msg': 'Invalid email'},
            ],
          },
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      expect(unauthorizedCalled, isFalse);
      final apiException = handler.rejectedError!.error as ApiException;
      expect(apiException.statusCode, 422);
      expect(apiException.message, 'Field required. Invalid email');
    });
  });
}
