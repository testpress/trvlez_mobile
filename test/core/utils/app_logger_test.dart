import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    tearDown(() {
      AppLogger.outputPrinter = null;
    });

    test('logs formatted message to outputPrinter with level prefix', () {
      final messages = <String>[];
      AppLogger.outputPrinter = messages.add;

      AppLogger.debug('Debug message');
      AppLogger.info('Info message');
      AppLogger.warning('Warning message');
      AppLogger.error('Error message');

      expect(messages, [
        '[DEBUG] Debug message',
        '[INFO] Info message',
        '[WARNING] Warning message',
        '[ERROR] Error message',
      ]);
    });

    test('logs error type without serialising error details', () {
      final messages = <String>[];
      AppLogger.outputPrinter = messages.add;

      AppLogger.warning('Network issue', 'Connection timed out');

      expect(messages, ['[WARNING] Network issue | errorType: String']);
    });

    group('sanitize', () {
      test('redacts sensitive keys in map', () {
        final payload = {
          'id': 'user_123',
          'name': 'Alice',
          'password': 'SuperSecretPassword',
          'token': 'jwt_secret_token',
          'access_token': 'oauth_access_token',
          'refresh_token': 'oauth_refresh_token',
          'authorization': 'Bearer token123',
          'click_reference': 'ref_abc_999',
          'referral_id': 'ref_uuid_456',
          'passport_number': 'P12345678',
          'mrz_line1': 'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
          'nfc_data': 'raw_chip_binary',
          'api_key': 'secret_api_key',
        };

        final sanitized = AppLogger.sanitize(payload) as Map;

        expect(sanitized['id'], equals('user_123'));
        expect(sanitized['name'], equals('Alice'));
        expect(sanitized['password'], equals('[REDACTED]'));
        expect(sanitized['token'], equals('[REDACTED]'));
        expect(sanitized['access_token'], equals('[REDACTED]'));
        expect(sanitized['refresh_token'], equals('[REDACTED]'));
        expect(sanitized['authorization'], equals('[REDACTED]'));
        expect(sanitized['click_reference'], equals('[REDACTED]'));
        expect(sanitized['referral_id'], equals('[REDACTED]'));
        expect(sanitized['passport_number'], equals('[REDACTED]'));
        expect(sanitized['mrz_line1'], equals('[REDACTED]'));
        expect(sanitized['nfc_data'], equals('[REDACTED]'));
        expect(sanitized['api_key'], equals('[REDACTED]'));
      });

      test('redacts nested maps and lists recursively', () {
        final nestedPayload = {
          'user': {
            'username': 'bob',
            'details': {'password': '12345'},
          },
          'items': [
            {'token': 'token_a'},
            {'public_id': 'id_b'},
          ],
        };

        final sanitized = AppLogger.sanitize(nestedPayload) as Map;

        expect(sanitized['user']['username'], equals('bob'));
        expect(
          (sanitized['user']['details'] as Map)['password'],
          equals('[REDACTED]'),
        );
        final items = sanitized['items'] as List;
        expect((items[0] as Map)['token'], equals('[REDACTED]'));
        expect((items[1] as Map)['public_id'], equals('id_b'));
      });

      test('redacts Bearer token strings', () {
        final bearerHeader = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
        expect(AppLogger.sanitize(bearerHeader), equals('Bearer [REDACTED]'));
      });

      test('preserves non-sensitive primitives unchanged', () {
        expect(AppLogger.sanitize(42), equals(42));
        expect(AppLogger.sanitize(true), isTrue);
        expect(
          AppLogger.sanitize('harmless string'),
          equals('harmless string'),
        );
        expect(AppLogger.sanitize(null), isNull);
      });
    });
  });
}
