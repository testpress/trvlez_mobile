import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/constants/app_config.dart';
import 'package:trvlez_mobile/core/network/auth_interceptor.dart';
import 'package:trvlez_mobile/core/network/error_interceptor.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/auth/data/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/data/auth_repository.dart';
import 'package:trvlez_mobile/features/profile/data/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/properties/data/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';


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
  // The onUnauthorized callback will be wired to authNotifier below.
  late final AuthNotifier authNotifier;
  dio.interceptors.add(
    ErrorInterceptor(
      onUnauthorized: () {
        authNotifier.logout();
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
  final authRemoteDataSource = AuthRemoteDataSource(dio: dio);
  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );

  final profileRemoteDataSource = ProfileRemoteDataSource(dio: dio);
  final profileRepository = ProfileRepository(
    remoteDataSource: profileRemoteDataSource,
  );

  final propertiesRemoteDataSource = PropertiesRemoteDataSource(dio: dio);
  final propertiesRepository = PropertiesRepository(
    remoteDataSource: propertiesRemoteDataSource,
  );

  final reservationRemoteDataSource = ReservationRemoteDataSource(dio: dio);
  final reservationRepository = ReservationRepository(
    remoteDataSource: reservationRemoteDataSource,
  );

  final verificationNotifier = VerificationNotifier(
    repository: VerificationRepository(dio: dio),
  );


  // 4. Auth State (with profile repo for onboarding step check)
  authNotifier = AuthNotifier(
    tokenStorage: tokenStorage,
    profileRepository: profileRepository,
    onLogout: () {
      verificationNotifier.reset();
    },
  );

  await authNotifier.checkAuthStatus();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: TrvlEzApp(
        authNotifier: authNotifier,
        authRepository: authRepository,
        profileRepository: profileRepository,
        propertiesRepository: propertiesRepository,
        reservationRepository: reservationRepository,
        verificationNotifier: verificationNotifier,

        settingsRepository: settingsRepository,
      ),
    ),
  );
}

class TrvlEzApp extends ConsumerWidget {
  final AuthNotifier authNotifier;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final PropertiesRepository propertiesRepository;
  final ReservationRepository reservationRepository;
  final VerificationNotifier verificationNotifier;

  final SettingsRepository settingsRepository;

  const TrvlEzApp({
    super.key,
    required this.authNotifier,
    required this.authRepository,
    required this.profileRepository,
    required this.propertiesRepository,
    required this.reservationRepository,
    required this.verificationNotifier,

    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentMode,
      routerConfig: createRouter(
        authNotifier,
        authRepository,
        profileRepository,
        propertiesRepository,
        reservationRepository,
        verificationNotifier,
        settingsRepository,
      ),
    );
  }
}
