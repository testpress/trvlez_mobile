import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/constants/app_config.dart';
import 'package:trvlez_mobile/core/network/auth_interceptor.dart';
import 'package:trvlez_mobile/core/network/error_interceptor.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';

export 'package:trvlez_mobile/core/network/dio_error_mapper.dart';

/// Provides the app-wide [TokenStorage] instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provides the app-wide configured [Dio] instance.
///
/// This is the single shared HTTP client for all backend API calls.
/// S3 presigned URL uploads use a separate plain [Dio] instance
/// (see [VerificationRepository]).
///
/// Configuration:
/// - Base URL from [AppConfig.apiUrl]
/// - Auth token injection via [AuthInterceptor]
/// - Error mapping via [ErrorInterceptor]
/// - Debug logging in debug mode
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final tokenStorage = ref.read(tokenStorageProvider);

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage: tokenStorage),
    ErrorInterceptor(
      onUnauthorized: () {
        ref.read(authNotifierProvider.notifier).logout();
      },
    ),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
  ]);

  return dio;
});
