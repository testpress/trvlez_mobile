import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';

/// Maps any [DioException] into the domain-level [AppException] hierarchy.
AppException mapDioException(DioException e) {
  // If an AppException is already attached as inner error
  final inner = e.error;
  if (inner is AppException) {
    return inner;
  }

  // If ErrorInterceptor attached an ApiException
  if (inner is ApiException) {
    final status = inner.statusCode;
    final message = inner.message;

    if (status == 401) {
      return UnauthorizedException(message);
    }
    if (status == 404) {
      return NotFoundException(message);
    }
    if (status != null && status >= 400 && status < 500) {
      return ValidationException(message);
    }
    if (status != null && status >= 500) {
      return ServerException(message);
    }
    return NetworkException(message);
  }

  // Network and timeout failures
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException('Network timeout or connection error. Please try again.');
    case DioExceptionType.badCertificate:
      return const NetworkException('Security certificate validation failed.');
    case DioExceptionType.cancel:
      return const NetworkException('Request was cancelled.');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = 'Unexpected error';

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List) {
          message = detail
              .map((item) => (item as Map<String, dynamic>)['msg'] as String? ?? '')
              .where((m) => m.isNotEmpty)
              .join('. ');
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      if (statusCode == 401) {
        return UnauthorizedException(message);
      }
      if (statusCode == 404) {
        return NotFoundException(message);
      }
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ValidationException(message);
      }
      return ServerException(message);
    case DioExceptionType.unknown:
      return NetworkException(e.message ?? 'Unknown connection error.');
  }
}
