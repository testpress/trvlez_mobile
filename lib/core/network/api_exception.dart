import 'package:dio/dio.dart';

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

  /// Extracts or converts any exception object into a clean [ApiException].
  ///
  /// Unwraps [DioException] (including its inner error, response payload, or timeout)
  /// and ensures no raw technical transport strings are exposed.
  factory ApiException.from(Object? error) {
    if (error == null) {
      return const ApiException('An unexpected error occurred.');
    }

    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      // 1. If error.error was already mapped to ApiException by ErrorInterceptor
      if (error.error is ApiException) {
        return error.error as ApiException;
      }

      // 2. Check if a response with FastAPI error body is present
      final response = error.response;
      if (response != null) {
        final statusCode = response.statusCode ?? 500;
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final detail = data['detail'];
          if (detail is String && detail.isNotEmpty) {
            return ApiException.fromStatusCode(statusCode, detail);
          } else if (detail is List && detail.isNotEmpty) {
            final joined = detail
                .map((e) => (e is Map ? e['msg']?.toString() : e.toString()))
                .where((msg) => msg != null && msg.isNotEmpty)
                .join('. ');
            if (joined.isNotEmpty) {
              return ApiException.fromStatusCode(statusCode, joined);
            }
          }
        }
        return ApiException.fromStatusCode(
          statusCode,
          'Request failed with status $statusCode',
        );
      }

      // 3. Network or connection timeouts
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException.network(
            'Connection timed out. Please check your network and try again.',
          );
        case DioExceptionType.connectionError:
          return ApiException.network(
            'Unable to connect to the server. Please check your internet connection.',
          );
        case DioExceptionType.cancel:
          return const ApiException('Request was cancelled.');
        default:
          return ApiException.network();
      }
    }

    if (error is String) {
      return ApiException(error);
    }

    // Clean up generic exception prefixes like "Exception: ..."
    final errorStr = error.toString();
    final cleanMsg = errorStr.startsWith('Exception: ')
        ? errorStr.substring('Exception: '.length)
        : errorStr;

    return ApiException(cleanMsg);
  }

  /// Convenience utility that returns a human-readable, user-facing error message
  /// from any exception without exposing technical error strings.
  static String extractMessage(Object? error, [String? fallback]) {
    if (error == null) {
      return fallback ?? 'Something went wrong. Please try again.';
    }
    final apiEx = ApiException.from(error);
    if (apiEx.message.trim().isEmpty) {
      return fallback ?? 'Something went wrong. Please try again.';
    }
    return apiEx.message;
  }

  // ── Domain Predicates ─────────────────────────────────────────────

  /// Whether the error represents an HTTP 409 Conflict.
  bool get isConflict => statusCode == 409;

  /// Whether the error indicates the user is already verified on the backend.
  bool get isAlreadyVerified =>
      isConflict && message.toLowerCase().contains('already verified');

  /// Whether the error indicates verification has already been submitted / in progress.
  bool get isAlreadySubmitted =>
      isConflict &&
      (message.toLowerCase().contains('already submitted') ||
          message.toLowerCase().contains('in progress') ||
          message.toLowerCase().contains('processing'));

  /// Whether the error indicates a verification session was not started or was lost.
  bool get isSessionNotStarted =>
      message.toLowerCase().contains('start a verification session') ||
      message.toLowerCase().contains('session not found') ||
      message.toLowerCase().contains('no active session');

  /// Whether the error indicates an authentication/session expiration.
  bool get isSessionExpired =>
      statusCode == 401 || message.toLowerCase().contains('session expired');

  @override
  String toString() => 'ApiException($statusCode): $message';
}
