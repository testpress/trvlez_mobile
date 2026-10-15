import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';

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

  // ─── Exception Unwrapping ───────────────────────────────────────

  /// Extracts an [ApiException] from any error object.
  ///
  /// Handles the common case where [ErrorInterceptor] wraps an
  /// [ApiException] inside [DioException.error]. Returns `null` if
  /// the error is not an [ApiException] at any nesting level.
  static ApiException? from(Object? error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) return inner;
    }
    return null;
  }

  /// Returns a clean, user-facing error message from any error.
  ///
  /// Unwraps [DioException] → [ApiException] if present, otherwise
  /// returns a generic fallback. Never exposes raw Dio internals.
  static String extractMessage(
    Object? error, [
    String fallback = 'Something went wrong. Please try again.',
  ]) {
    final apiException = from(error);
    if (apiException != null) return apiException.message;
    if (error is AppException) return error.message;
    if (error is Exception) return fallback;
    return fallback;
  }

  // ─── Conflict / Domain Helpers ──────────────────────────────────

  /// Whether this is a 409 Conflict response.
  bool get isConflict => statusCode == 409;

  /// Whether this 409 indicates the user is already verified.
  bool get isAlreadyVerified =>
      isConflict && message.toLowerCase().contains('already verified');

  /// Whether this 409 indicates a verification was already submitted.
  bool get isAlreadySubmitted =>
      isConflict &&
      (message.toLowerCase().contains('already submitted') ||
          message.toLowerCase().contains('already processing'));

  /// Whether this error indicates the session has expired or is invalid.
  bool get isSessionExpired =>
      statusCode == 400 &&
      (message.toLowerCase().contains('session') ||
          message.toLowerCase().contains('start a verification'));

  @override
  String toString() => 'ApiException($statusCode): $message';
}
