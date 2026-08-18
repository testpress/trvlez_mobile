import 'package:dio/dio.dart';

import 'package:trvlez_mobile/core/storage/token_storage.dart';

/// Dio interceptor that automatically attaches the stored auth token
/// to every outgoing request as a Bearer token.
///
/// Unauthenticated endpoints (login, signup) work transparently —
/// if no token is stored, no header is added.
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  const AuthInterceptor({required this.tokenStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
