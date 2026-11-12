/// Core domain exceptions for TrvlEz.
///
/// Features and repositories catch infrastructure/network errors
/// and translate them into this sealed [AppException] hierarchy.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  /// Resolves a user-safe message from any error or exception object.
  /// Never returns technical types, raw stack strings, or transport details.
  static String userMessage(
    Object? error, [
    String fallback = 'Something went wrong. Please try again.',
  ]) {
    if (error == null) return fallback;
    if (error is AppException) return error.message;
    if (error is String) {
      if (error.isEmpty) return fallback;
      final lower = error.toLowerCase();
      if (lower.contains('exception') ||
          lower.contains('stacktrace') ||
          lower.contains('error:')) {
        return fallback;
      }
      return error;
    }
    if (error.runtimeType.toString() == 'ApiException') {
      final dynamic apiError = error;
      final Object? apiMessage = apiError.message;
      if (apiMessage is String && apiMessage.isNotEmpty) return apiMessage;
    }
    return fallback;
  }

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when device is offline, connection times out, or DNS fails.
final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// Thrown when authentication fails or session expires (HTTP 401).
final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired. Please log in again.',
  ]);
}

/// Thrown when request input is invalid or violates business rules (HTTP 400, 422, etc.).
final class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Validation failed. Please verify your input.',
  ]);
}

/// Thrown when a requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

/// Thrown on unexpected server failures (HTTP 5xx or unparseable payload).
final class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error. Please try again later.',
  ]);
}
