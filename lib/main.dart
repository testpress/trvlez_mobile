import 'package:flutter/material.dart';


import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/network/api_client.dart';
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
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage
  const tokenStorage = TokenStorage();
  final settingsRepository = await SettingsRepository.init();

  // 2. Network & Data (needed before auth check)
  final apiClient = ApiClient(
    onUnauthorized: () {
      // Will be wired to authNotifier below
    },
  );

  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );

  final profileRemoteDataSource = ProfileRemoteDataSource(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final profileRepository = ProfileRepository(
    remoteDataSource: profileRemoteDataSource,
  );

  final propertiesRemoteDataSource = PropertiesRemoteDataSource(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final propertiesRepository = PropertiesRepository(
    remoteDataSource: propertiesRemoteDataSource,
  );

  final reservationRemoteDataSource = ReservationRemoteDataSource(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final reservationRepository = ReservationRepository(
    remoteDataSource: reservationRemoteDataSource,
  );

  final verificationNotifier = VerificationNotifier();
  final propertiesNotifier = PropertiesNotifier(repository: propertiesRepository);
  final reservationsNotifier = ReservationsNotifier(repository: reservationRepository);

  // 3. Auth State (with profile repo for onboarding step check)
  final authNotifier = AuthNotifier(
    tokenStorage: tokenStorage,
    profileRepository: profileRepository,
    onLogout: () {
      verificationNotifier.reset();
      propertiesNotifier.reset();
      reservationsNotifier.reset();
    },
  );

  // Wire unauthorized callback now that authNotifier exists
  apiClient.onUnauthorized = () {
    authNotifier.logout();
  };

  await authNotifier.checkAuthStatus();

  final themeMode = settingsRepository.getThemeMode();
  TrvlEzApp.themeNotifier.value = themeMode;

  runApp(
    TrvlEzApp(
      authNotifier: authNotifier,
      authRepository: authRepository,
      profileRepository: profileRepository,
      propertiesRepository: propertiesRepository,
      reservationRepository: reservationRepository,
      verificationNotifier: verificationNotifier,
      propertiesNotifier: propertiesNotifier,
      reservationsNotifier: reservationsNotifier,
      settingsRepository: settingsRepository,
    ),
  );
}

class TrvlEzApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final PropertiesRepository propertiesRepository;
  final ReservationRepository reservationRepository;
  final VerificationNotifier verificationNotifier;
  final PropertiesNotifier propertiesNotifier;
  final ReservationsNotifier reservationsNotifier;
  final SettingsRepository settingsRepository;

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  const TrvlEzApp({
    super.key,
    required this.authNotifier,
    required this.authRepository,
    required this.profileRepository,
    required this.propertiesRepository,
    required this.reservationRepository,
    required this.verificationNotifier,
    required this.propertiesNotifier,
    required this.reservationsNotifier,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
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
            propertiesNotifier,
            reservationsNotifier,
            settingsRepository,
          ),
        );
      },
    );
  }
}

