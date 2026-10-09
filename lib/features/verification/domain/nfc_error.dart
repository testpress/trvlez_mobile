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

  /// Data read from the chip could not be parsed (corrupted or unsupported encoding).
  dataParseError,

  /// The secure messaging channel broke during communication.
  secureMessagingError,

  /// The user manually cancelled the NFC reading process.
  cancelled,

  /// An unexpected error occurred.
  unknownError,
}

/// A structured domain exception for NFC operations that provides user-friendly feedback.
class NfcError implements Exception {
  final NfcErrorType type;
  final String message;
  final String? technicalDetails;
  final String? userGuidance;
  final bool isRetryable;

  const NfcError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.userGuidance,
    this.isRetryable = true,
  });

  /// User-facing message when NFC passport authentication fails.
  static const String authenticationFailedMessage =
      'We couldn’t verify this passport. Please make sure you’re using the same passport you uploaded.';

  @override
  String toString() => 'NfcError($type): $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NfcError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          technicalDetails == other.technicalDetails &&
          userGuidance == other.userGuidance &&
          isRetryable == other.isRetryable;

  @override
  int get hashCode =>
      type.hashCode ^
      message.hashCode ^
      technicalDetails.hashCode ^
      userGuidance.hashCode ^
      isRetryable.hashCode;
}
