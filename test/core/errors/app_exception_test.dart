import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';

void main() {
  group('AppException.userMessage', () {
    test('returns message for AppException instances', () {
      expect(
        AppException.userMessage(const NetworkException()),
        equals('No internet connection. Please check your network.'),
      );
      expect(
        AppException.userMessage(const UnauthorizedException()),
        equals('Session expired. Please log in again.'),
      );
      expect(
        AppException.userMessage(
          const ValidationException('Please enter valid dates.'),
        ),
        equals('Please enter valid dates.'),
      );
      expect(
        AppException.userMessage(const NotFoundException()),
        equals('The requested resource was not found.'),
      );
      expect(
        AppException.userMessage(const ServerException()),
        equals('Server error. Please try again later.'),
      );
    });

    test('extracts clean message from ApiException', () {
      final apiException = ApiException.fromStatusCode(
        400,
        'Invalid passport format',
      );
      expect(
        AppException.userMessage(apiException),
        equals('Invalid passport format'),
      );
    });

    test('returns fallback message for raw exceptions or technical errors', () {
      final rawException = Exception('Raw connection reset by peer');
      expect(
        AppException.userMessage(rawException),
        equals('Something went wrong. Please try again.'),
      );

      final formatException = const FormatException(
        'Unexpected character at line 1',
      );
      expect(
        AppException.userMessage(formatException, 'Custom fallback'),
        equals('Custom fallback'),
      );
    });

    test('returns fallback for null error', () {
      expect(
        AppException.userMessage(null),
        equals('Something went wrong. Please try again.'),
      );
      expect(
        AppException.userMessage(null, 'Custom error'),
        equals('Custom error'),
      );
    });
  });
}
