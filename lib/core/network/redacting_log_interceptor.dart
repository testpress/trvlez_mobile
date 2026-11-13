import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Dio interceptor that logs request lifecycle metadata without user data.
///
/// HTTP headers and bodies are deliberately excluded. A key-based redactor cannot
/// safely classify every present or future API field, and debug logs are not an
/// approved store for personal, verification, credential, or referral data.
class RedactingLogInterceptor extends Interceptor {
  const RedactingLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('HTTP --> ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      'HTTP <-- ${response.statusCode} ${response.requestOptions.uri.path}',
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
