/// Structured exception for API errors.
///
/// Maps FastAPI's error responses to Dart exceptions with
/// human-readable messages and optional HTTP status codes.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// Network failure — device offline, DNS resolution, timeout, etc.
  factory ApiException.network([String? message]) {
    return ApiException(
      message ?? 'Network error. Please check your connection and try again.',
      statusCode: null,
    );
  }

  /// Session expired or invalid token (401).
  factory ApiException.unauthorized() {
    return const ApiException(
      'Session expired. Please log in again.',
      statusCode: 401,
    );
  }

  /// Server returned a known validation/business error (4xx).
  factory ApiException.fromStatusCode(int statusCode, String detail) {
    return ApiException(detail, statusCode: statusCode);
  }

  /// Unexpected server error (5xx or unparseable response).
  factory ApiException.server([String? message]) {
    return ApiException(
      message ?? 'Something went wrong. Please try again later.',
      statusCode: 500,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
