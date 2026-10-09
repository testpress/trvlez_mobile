import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/src/proto/iso7816/response_apdu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_error_mapper.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';

void main() {
  group('NfcErrorMapper - Authentication Failure Handling', () {
    const expectedAuthMessage =
        'We couldn’t verify this passport. Please make sure you’re using the same passport you uploaded.';

    test(
      'maps PassportError with 0x6982 (Security status not satisfied) to authentication failure message',
      () {
        final error = PassportError(
          'Security status not satisfied',
          code: const StatusWord(sw1: 0x69, sw2: 0x82),
        );

        final nfcError = NfcErrorMapper.fromException(
          error,
          readStep: 'authenticating',
        );

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test(
      'maps PassportError with 0x6300 (Authentication failed) to authentication failure message',
      () {
        final error = PassportError(
          'The protocol (step) failed.',
          code: const StatusWord(sw1: 0x63, sw2: 0x00),
        );

        final nfcError = NfcErrorMapper.fromException(error);

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test(
      'maps PassportError with 0x63CF (Wrong DBAKeys) to authentication failure message',
      () {
        final error = PassportError(
          'Security status not satisfied',
          code: const StatusWord(sw1: 0x63, sw2: 0xCF),
        );

        final nfcError = NfcErrorMapper.fromException(error);

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test(
      'maps PassportError with message containing "authentication failed" without status code',
      () {
        final error = PassportError('Authentication failed');

        final nfcError = NfcErrorMapper.fromException(error);

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test(
      'maps PassportError with message containing "the protocol (step) failed"',
      () {
        final error = PassportError('The protocol (step) failed.');

        final nfcError = NfcErrorMapper.fromException(error);

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test(
      'maps any PassportError occurring during authenticating step context to authentication failure',
      () {
        final error = PassportError('Generic passport failure');

        final nfcError = NfcErrorMapper.fromException(
          error,
          readStep: 'authenticating',
        );

        expect(nfcError.type, NfcErrorType.authenticationFailed);
        expect(nfcError.message, expectedAuthMessage);
        expect(nfcError.isRetryable, isFalse);
      },
    );

    test('maps BACError from string to authentication failure message', () {
      final error = Exception('BACError: Verifying mac of Eicc failed');

      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.authenticationFailed);
      expect(nfcError.message, expectedAuthMessage);
      expect(nfcError.isRetryable, isFalse);
    });

    test('maps PACEError from string to authentication failure message', () {
      final error = Exception(
        'PACEError: PACE <ECDH> key establishment failed',
      );

      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.authenticationFailed);
      expect(nfcError.message, expectedAuthMessage);
      expect(nfcError.isRetryable, isFalse);
    });

    test('maps fallbackType authenticationFailed to expected message', () {
      final error = Exception('Unexpected session initialization failure');

      final nfcError = NfcErrorMapper.fromException(
        error,
        fallbackType: NfcErrorType.authenticationFailed,
        readStep: 'authenticating',
      );

      expect(nfcError.type, NfcErrorType.authenticationFailed);
      expect(nfcError.message, expectedAuthMessage);
      expect(nfcError.isRetryable, isFalse);
    });
  });

  group('NfcErrorMapper - Preserved Non-Authentication Error Mapping', () {
    test('maps not supported to nfcNotAvailable', () {
      final error = Exception('NFC is not supported on this device');
      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.nfcNotAvailable);
      expect(nfcError.isRetryable, isFalse);
    });

    test('maps disabled to nfcDisabled', () {
      final error = Exception('NFC feature is disabled');
      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.nfcDisabled);
    });

    test('maps timeout to readTimeout', () {
      final error = Exception('Connection timed out while reading tag');
      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.readTimeout);
    });

    test('maps tag lost to tagLost', () {
      final error = Exception('Tag was lost');
      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.tagLost);
    });

    test('maps cancel to cancelled', () {
      final error = Exception('Session invalidated by user');
      final nfcError = NfcErrorMapper.fromException(error);

      expect(nfcError.type, NfcErrorType.cancelled);
    });
  });
}
