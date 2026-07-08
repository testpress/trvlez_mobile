/// Represents the specific types of errors that can occur during NFC passport reading.
enum NfcErrorType {
  /// The device does not have NFC hardware.
  nfcNotAvailable,

  /// NFC is available but turned off in device settings.
  nfcDisabled,

  /// No passport was detected within the timeout period.
  passportNotDetected,

  /// The passport chip rejected the authentication attempt (likely wrong MRZ data).
  authenticationFailed,

  /// The connection timed out during a read operation.
  readTimeout,

  /// The passport was moved away before reading finished.
  tagLost,

  /// The provided MRZ data is invalid or incorrectly formatted.
  invalidMrzData,

  /// The passport chip is not a standard ICAO ePassport or uses unsupported crypto.
  unsupportedPassport,

  /// The user manually cancelled the NFC reading process.
  cancelled,

  /// An unexpected error occurred.
  unknownError,
}

/// A structured error for NFC operations that provides user-friendly feedback.
class NfcError implements Exception {
  final NfcErrorType type;
  final String message;
  final String? technicalDetails;
  final bool isRetryable;

  const NfcError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.isRetryable = true,
  });

  /// Factory for mapping internal exceptions to user-facing NfcErrors.
  factory NfcError.fromException(dynamic error, {NfcErrorType? fallbackType}) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('not supported') || errorString.contains('not available')) {
      return const NfcError(
        type: NfcErrorType.nfcNotAvailable,
        message: 'Your device does not support NFC.',
        isRetryable: false,
      );
    }
    
    if (errorString.contains('disabled')) {
      return const NfcError(
        type: NfcErrorType.nfcDisabled,
        message: 'NFC is disabled. Please enable it in your device settings.',
      );
    }

    if (errorString.contains('security status not satisfied') || errorString.contains('authentication')) {
      return const NfcError(
        type: NfcErrorType.authenticationFailed,
        message: 'Could not authenticate passport chip. The scanned passport data might be incorrect.',
        isRetryable: false, // Usually requires re-scanning the MRZ
      );
    }

    if (errorString.contains('timeout')) {
      return const NfcError(
        type: NfcErrorType.readTimeout,
        message: 'Connection timed out. Please keep the passport still.',
      );
    }

    if (errorString.contains('tag was lost') || errorString.contains('connection lost')) {
      return const NfcError(
        type: NfcErrorType.tagLost,
        message: 'Passport connection lost. Please keep your phone steady on the passport.',
      );
    }

    if (errorString.contains('invalidated by user') || errorString.contains('cancel')) {
      return const NfcError(
        type: NfcErrorType.cancelled,
        message: 'NFC reading was cancelled.',
        isRetryable: true,
      );
    }

    return NfcError(
      type: fallbackType ?? NfcErrorType.unknownError,
      message: 'An unexpected error occurred while reading the passport.',
      technicalDetails: error.toString(),
      isRetryable: true,
    );
  }

  @override
  String toString() => 'NfcError($type): $message';
}
