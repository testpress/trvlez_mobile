import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/services.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';

/// Maps raw platform and library exceptions to structured [NfcError]s.
class NfcErrorMapper {
  const NfcErrorMapper._();

  /// Maps internal exceptions (dmrtd, platform, timeout) to user-facing [NfcError]s.
  ///
  /// Uses type-based matching first for dmrtd exceptions and platform exceptions,
  /// then falls back to keyword matching on the error string.
  /// The [readStep] parameter provides context about which NFC read operation
  /// was in progress when the error occurred.
  static NfcError fromException(
    dynamic error, {
    NfcErrorType? fallbackType,
    String? readStep,
  }) {
    final errorString = error.toString().toLowerCase();
    final stepContext = readStep != null ? ' while $readStep' : '';

    // --- Type-based matching for dmrtd library exceptions ---

    if (error is PassportError) {
      return _fromPassportError(error, stepContext);
    }

    if (error is PlatformException) {
      return _fromPlatformException(error, stepContext);
    }

    // --- String-based matching for all other exceptions ---

    if (errorString.contains('not supported') ||
        errorString.contains('not_supported') ||
        errorString.contains('unsupported')) {
      return NfcError(
        type: NfcErrorType.nfcNotAvailable,
        message: 'Your device does not support NFC.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    if (errorString.contains('disabled') || errorString.contains('404')) {
      return NfcError(
        type: NfcErrorType.nfcDisabled,
        message: 'NFC is turned off. Please enable it in your device settings.',
        technicalDetails: error.toString(),
      );
    }

    // BAC/PACE authentication failures — MRZ data is likely wrong
    if (errorString.contains('security status not satisfied') ||
        errorString.contains('authentication failed') ||
        errorString.contains('authentication method blocked') ||
        errorString.contains('the protocol (step) failed') ||
        errorString.contains('verifying mac') ||
        errorString.contains('bacerror') ||
        errorString.contains('paceerror') ||
        errorString.contains('paceresponsecheckerror')) {
      return NfcError(
        type: NfcErrorType.authenticationFailed,
        message: NfcError.authenticationFailedMessage,
        userGuidance:
            'The scanned passport data may be incorrect. '
            'Please go back and retake the passport photo, ensuring the '
            'MRZ text lines at the bottom are clearly visible.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    // Secure messaging channel errors — connection instability mid-read
    if (errorString.contains('sm data objects missing') ||
        errorString.contains('sm data objects incorrect') ||
        errorString.contains('sm data invalid') ||
        errorString.contains('sm data missing') ||
        errorString.contains('smerror') ||
        errorString.contains('secure messaging')) {
      return NfcError(
        type: NfcErrorType.secureMessagingError,
        message:
            'The secure connection to the passport was interrupted$stepContext.',
        userGuidance:
            'Keep your phone pressed firmly against the passport '
            'without moving until the scan completes.',
        technicalDetails: error.toString(),
      );
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return NfcError(
        type: NfcErrorType.readTimeout,
        message:
            'Connection timed out$stepContext. Please keep the passport still.',
        userGuidance:
            'Hold your phone steady against the passport and try again. '
            'The face image read can take up to 30 seconds.',
        technicalDetails: error.toString(),
      );
    }

    if (errorString.contains('tag was lost') ||
        errorString.contains('connection lost') ||
        errorString.contains('tag connection') ||
        errorString.contains('ioexception') ||
        errorString.contains('transceive fail')) {
      return NfcError(
        type: NfcErrorType.tagLost,
        message: 'Passport connection lost$stepContext.',
        userGuidance:
            'Keep your phone steady on the passport without lifting it. '
            'Try placing it flat on a table.',
        technicalDetails: error.toString(),
      );
    }

    // Data parsing errors — chip data is malformed or uses unsupported encoding
    if (errorString.contains('efparseerror') ||
        errorString.contains('mrzparseerror') ||
        errorString.contains('tlverror') ||
        errorString.contains('parse') ||
        errorString.contains('invalid data field') ||
        errorString.contains('incorrect parameters')) {
      return NfcError(
        type: NfcErrorType.dataParseError,
        message: 'Could not read data from the passport chip$stepContext.',
        userGuidance:
            'Your passport chip may use an unsupported format. '
            'You can skip NFC verification and continue.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    // File/feature not found on chip
    if (errorString.contains('file not found') ||
        errorString.contains('record not found') ||
        errorString.contains('function not supported') ||
        errorString.contains('command not allowed') ||
        errorString.contains('class not supported') ||
        errorString.contains('instruction code not supported')) {
      return NfcError(
        type: NfcErrorType.unsupportedPassport,
        message:
            'This passport does not support the required data format$stepContext.',
        userGuidance:
            'Your passport chip may not contain all required data groups. '
            'You can skip NFC verification and continue.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    // Conditions not satisfied — chip state issue, retryable
    if (errorString.contains('conditions of use not satisfied') ||
        errorString.contains('conditionsnotsatisfied') ||
        errorString.contains('wrong length') ||
        errorString.contains('referenced data')) {
      return NfcError(
        type: NfcErrorType.tagLost,
        message: 'The passport chip rejected the command$stepContext.',
        userGuidance:
            'Try repositioning your phone on the passport and scanning again.',
        technicalDetails: error.toString(),
      );
    }

    if (errorString.contains('invalidated by user') ||
        errorString.contains('cancel') ||
        errorString.contains('user canceled') ||
        errorString.contains('session invalidated')) {
      return NfcError(
        type: NfcErrorType.cancelled,
        message: 'NFC reading was cancelled.',
        technicalDetails: error.toString(),
        isRetryable: true,
      );
    }

    // Communication provider errors from dmrtd
    if (errorString.contains('nfcprovidererror') ||
        errorString.contains('comprovidererror')) {
      return NfcError(
        type: NfcErrorType.tagLost,
        message: 'Lost communication with the passport$stepContext.',
        userGuidance:
            'Keep your phone pressed firmly against the passport and try again.',
        technicalDetails: error.toString(),
      );
    }

    // Fallback — include the exception type for diagnostics
    final exceptionTypeName = error.runtimeType.toString();
    if (fallbackType == NfcErrorType.authenticationFailed) {
      return NfcError(
        type: NfcErrorType.authenticationFailed,
        message: NfcError.authenticationFailedMessage,
        userGuidance:
            'The scanned passport data may be incorrect. '
            'Please go back and retake the passport photo.',
        technicalDetails: '[$exceptionTypeName] ${error.toString()}',
        isRetryable: false,
      );
    }
    return NfcError(
      type: fallbackType ?? NfcErrorType.unknownError,
      message: 'Something went wrong while reading the passport$stepContext.',
      userGuidance:
          'Please try again. If the problem persists, you can skip NFC '
          'verification and continue.',
      technicalDetails: '[$exceptionTypeName] ${error.toString()}',
      isRetryable: true,
    );
  }

  /// Maps [PassportError] from the dmrtd library using its status code
  /// for precise classification.
  static NfcError _fromPassportError(PassportError error, String stepContext) {
    final code = error.code;
    final message = error.message.toLowerCase();

    // Check status code first for precise mapping
    if (code != null) {
      // Security status not satisfied (0x6982) / Authentication failed (0x6300, 0x63CF) — BAC/PACE auth failed
      if ((code.sw1 == 0x69 && code.sw2 == 0x82) ||
          (code.sw1 == 0x63 && (code.sw2 == 0x00 || code.sw2 == 0xCF))) {
        return NfcError(
          type: NfcErrorType.authenticationFailed,
          message: NfcError.authenticationFailedMessage,
          userGuidance:
              'The scanned passport data may be incorrect. '
              'Please go back and retake the passport photo.',
          technicalDetails: error.toString(),
          isRetryable: false,
        );
      }

      // Authentication method blocked (0x6983)
      if (code.sw1 == 0x69 && code.sw2 == 0x83) {
        return NfcError(
          type: NfcErrorType.authenticationFailed,
          message:
              'Passport authentication is temporarily blocked$stepContext.',
          userGuidance:
              'Too many failed attempts. Please wait a moment and try again, '
              'or skip NFC verification.',
          technicalDetails: error.toString(),
          isRetryable: false,
        );
      }

      // SM data missing/incorrect (0x6987, 0x6988) — connection instability
      if (code.sw1 == 0x69 && (code.sw2 == 0x87 || code.sw2 == 0x88)) {
        return NfcError(
          type: NfcErrorType.secureMessagingError,
          message: 'The secure connection was interrupted$stepContext.',
          userGuidance:
              'Keep your phone pressed firmly against the passport '
              'without moving until the scan completes.',
          technicalDetails: error.toString(),
        );
      }

      // File not found (0x6A82) — DG not present on chip
      if (code.sw1 == 0x6A && code.sw2 == 0x82) {
        return NfcError(
          type: NfcErrorType.unsupportedPassport,
          message:
              'Required data was not found on the passport chip$stepContext.',
          userGuidance:
              'Your passport chip may not contain all required data. '
              'You can skip NFC verification.',
          technicalDetails: error.toString(),
          isRetryable: false,
        );
      }

      // Conditions not satisfied (0x6985) — retry may help
      if (code.sw1 == 0x69 && code.sw2 == 0x85) {
        return NfcError(
          type: NfcErrorType.tagLost,
          message: 'The passport chip rejected the command$stepContext.',
          userGuidance: 'Reposition your phone on the passport and try again.',
          technicalDetails: error.toString(),
        );
      }

      // Wrong length (0x6700) — protocol issue, retryable
      if (code.sw1 == 0x67 && code.sw2 == 0x00) {
        return NfcError(
          type: NfcErrorType.tagLost,
          message: 'Communication error with the passport$stepContext.',
          userGuidance: 'Reposition your phone and try again.',
          technicalDetails: error.toString(),
        );
      }

      // Function/class/instruction not supported — unsupported chip
      if ((code.sw1 == 0x6A && code.sw2 == 0x81) ||
          (code.sw1 == 0x6D && code.sw2 == 0x00) ||
          (code.sw1 == 0x6E && code.sw2 == 0x00)) {
        return NfcError(
          type: NfcErrorType.unsupportedPassport,
          message: 'This passport uses an unsupported chip format$stepContext.',
          userGuidance:
              'Your passport chip may not be compatible. '
              'You can skip NFC verification.',
          technicalDetails: error.toString(),
          isRetryable: false,
        );
      }
    }

    // Fall back to message-based matching for PassportError without status code
    if (message.contains('security status not satisfied') ||
        message.contains('authentication failed') ||
        message.contains('authentication') ||
        message.contains('the protocol (step) failed') ||
        message.contains('verifying mac')) {
      return NfcError(
        type: NfcErrorType.authenticationFailed,
        message: NfcError.authenticationFailedMessage,
        userGuidance:
            'The scanned passport data may be incorrect. '
            'Please retake the passport photo.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    // A PassportError during the authentication step indicates the keys derived
    // from the uploaded passport MRZ were rejected by the chip.
    if (stepContext.contains('authenticating')) {
      return NfcError(
        type: NfcErrorType.authenticationFailed,
        message: NfcError.authenticationFailedMessage,
        userGuidance:
            'The scanned passport data may be incorrect. '
            'Please retake the passport photo.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    // Generic PassportError fallback
    return NfcError(
      type: NfcErrorType.unknownError,
      message: 'Failed to read the passport chip$stepContext.',
      userGuidance:
          'Please try again. If the problem persists, skip NFC verification.',
      technicalDetails: error.toString(),
    );
  }

  /// Maps Flutter [PlatformException] from the NFC plugin layer.
  static NfcError _fromPlatformException(
    PlatformException error,
    String stepContext,
  ) {
    final code = (error.code).toLowerCase();
    final errorMessage = (error.message ?? '').toLowerCase();
    final combined = '$code $errorMessage';

    if (combined.contains('not supported') ||
        combined.contains('not_supported') ||
        combined.contains('unsupported')) {
      return NfcError(
        type: NfcErrorType.nfcNotAvailable,
        message: 'Your device does not support NFC.',
        technicalDetails: error.toString(),
        isRetryable: false,
      );
    }

    if (combined.contains('disabled') ||
        code == '404' ||
        errorMessage.contains('nfc not available')) {
      return NfcError(
        type: NfcErrorType.nfcDisabled,
        message: 'NFC is turned off. Please enable it in your device settings.',
        technicalDetails: error.toString(),
      );
    }

    if (combined.contains('timeout')) {
      return NfcError(
        type: NfcErrorType.readTimeout,
        message: 'NFC connection timed out$stepContext.',
        userGuidance:
            'Hold your phone steady against the passport and try again.',
        technicalDetails: error.toString(),
      );
    }

    if (combined.contains('tag was lost') ||
        combined.contains('connection lost') ||
        combined.contains('invalidated')) {
      return NfcError(
        type: NfcErrorType.tagLost,
        message: 'Passport connection lost$stepContext.',
        userGuidance:
            'Keep your phone steady on the passport without lifting it.',
        technicalDetails: error.toString(),
      );
    }

    if (combined.contains('cancel') || combined.contains('user')) {
      return NfcError(
        type: NfcErrorType.cancelled,
        message: 'NFC reading was cancelled.',
        technicalDetails: error.toString(),
      );
    }

    return NfcError(
      type: NfcErrorType.unknownError,
      message: 'NFC communication error$stepContext.',
      userGuidance:
          'Please try again. If the problem persists, skip NFC verification.',
      technicalDetails: '[PlatformException] ${error.toString()}',
    );
  }
}
