import 'package:dio/dio.dart';

import 'package:trvlez_mobile/core/network/api_exception.dart';

/// Dio interceptor that maps all error responses to [ApiException].
///
/// Handles:
/// - Network errors (connection failures, timeouts) → [ApiException.network]
/// - HTTP 401 → notifies [onUnauthorized] + [ApiException.unauthorized]
/// - HTTP 4xx/5xx → parses FastAPI `detail` field → [ApiException.fromStatusCode]
/// - Unparseable responses → [ApiException.server]
///
/// The [onUnauthorized] callback should notify the auth state mechanism.
/// It must NOT perform navigation or show UI.
class ErrorInterceptor extends Interceptor {
  final void Function() onUnauthorized;

  const ErrorInterceptor({required this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapToApiException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }

  ApiException _mapToApiException(DioException err) {
    // Network-level errors (no response received)
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.network();
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      case DioExceptionType.badResponse:
        return _handleBadResponse(err);
      case DioExceptionType.badCertificate:
        return ApiException.network('Certificate verification failed.');
      case DioExceptionType.transformTimeout:
        return ApiException.network();
      case DioExceptionType.unknown:
        return ApiException.network();
    }
  }

  ApiException _handleBadResponse(DioException err) {
    final response = err.response;
    if (response == null) {
      return ApiException.server();
    }

    final statusCode = response.statusCode ?? 500;

    // 401 — notify auth state and throw
    if (statusCode == 401) {
      onUnauthorized();
      return ApiException.unauthorized();
    }

    // Try to parse FastAPI error body
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return _parseApiError(statusCode, data);
    }

    return ApiException.server();
  }

  /// Parses FastAPI's error response format.
  ///
  /// FastAPI returns either:
  /// - `{"detail": "string message"}`
  /// - `{"detail": [{"msg": "...", ...}, ...]}`
  ApiException _parseApiError(int statusCode, Map<String, dynamic> body) {
    final detail = body['detail'];

    final String message;
    if (detail is List) {
      message = detail
          .map((e) => (e as Map<String, dynamic>)['msg'] as String? ?? '')
          .where((msg) => msg.isNotEmpty)
          .join('. ');
    } else if (detail is String) {
      message = detail;
    } else {
      message = 'An unexpected error occurred.';
    }

    return ApiException.fromStatusCode(statusCode, message);
  }
}
