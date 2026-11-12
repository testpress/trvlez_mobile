import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Dio interceptor that safely logs HTTP traffic without exposing sensitive credentials,
/// auth tokens, passports, or personal data.
class RedactingLogInterceptor extends Interceptor {
  const RedactingLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final sanitizedHeaders = AppLogger.sanitize(
      Map<String, dynamic>.from(options.headers),
    );
    final sanitizedData = AppLogger.sanitize(options.data);
    AppLogger.debug(
      'HTTP --> ${options.method} ${options.uri.path} | headers: $sanitizedHeaders | body: $sanitizedData',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final sanitizedData = AppLogger.sanitize(response.data);
    AppLogger.debug(
      'HTTP <-- ${response.statusCode} ${response.requestOptions.uri.path} | body: $sanitizedData',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      'HTTP <-- ERROR ${err.response?.statusCode ?? err.type} ${err.requestOptions.uri.path}',
    );
    handler.next(err);
  }
}
