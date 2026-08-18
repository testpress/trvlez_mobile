import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';

import 'package:trvlez_mobile/core/constants/app_config.dart';
import 'package:trvlez_mobile/core/network/auth_interceptor.dart';
import 'package:trvlez_mobile/core/network/error_interceptor.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage
  const tokenStorage = TokenStorage();
  final settingsRepository = await SettingsRepository.init();

  // 2. Network — Dio with interceptors (replaces ApiClient)
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

  // Auth interceptor — automatically injects Bearer token
  dio.interceptors.add(
    AuthInterceptor(tokenStorage: tokenStorage),
  );

  // Error interceptor — maps DioException to ApiException.
  dio.interceptors.add(
    ErrorInterceptor(
      onUnauthorized: () {
        // Handle logout globally
      },
    ),
  );

  // Debug logging in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  // 3. Data Sources & Repositories




  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const TrvlEzApp(),

    ),
  );
}

class TrvlEzApp extends ConsumerWidget {
  const TrvlEzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
