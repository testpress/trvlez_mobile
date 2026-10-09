import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';

void main() {
  group('NfcError Domain Entity', () {
    const expectedAuthMessage =
        'We couldn’t verify this passport. Please make sure you’re using the same passport you uploaded.';

    test(
      'authenticationFailedMessage constant has the exact required wording',
      () {
        expect(NfcError.authenticationFailedMessage, expectedAuthMessage);
      },
    );

    test('supports value equality and properties', () {
      const error1 = NfcError(
        type: NfcErrorType.authenticationFailed,
        message: 'Auth failed',
        technicalDetails: 'sw: 0x6982',
        userGuidance: 'Retake photo',
        isRetryable: false,
      );

      const error2 = NfcError(
        type: NfcErrorType.authenticationFailed,
        message: 'Auth failed',
        technicalDetails: 'sw: 0x6982',
        userGuidance: 'Retake photo',
        isRetryable: false,
      );

      const error3 = NfcError(
        type: NfcErrorType.readTimeout,
        message: 'Timed out',
      );

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
      expect(
        error1.toString(),
        'NfcError(NfcErrorType.authenticationFailed): Auth failed',
      );
    });
  });
}
