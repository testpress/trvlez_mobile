/// Core domain exceptions for TrvlEz.
///
/// Features and repositories catch infrastructure/network errors
/// and translate them into this sealed [AppException] hierarchy.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when device is offline, connection times out, or DNS fails.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.']);
}

/// Thrown when authentication fails or session expires (HTTP 401).
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.']);
}

/// Thrown when request input is invalid or violates business rules (HTTP 400, 422, etc.).
final class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed. Please verify your input.']);
}

/// Thrown when a requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.']);
}

/// Thrown on unexpected server failures (HTTP 5xx or unparseable payload).
final class ServerException extends AppException {
  const ServerException([super.message = 'Server error. Please try again later.']);
}
