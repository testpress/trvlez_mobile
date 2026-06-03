import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_notifier.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/profile/data/profile_remote_data_source.dart';
import 'features/profile/data/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage
  const tokenStorage = TokenStorage();

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

  // 3. Auth State (with profile repo for onboarding step check)
  final authNotifier = AuthNotifier(
    tokenStorage: tokenStorage,
    profileRepository: profileRepository,
  );

  // Wire unauthorized callback now that authNotifier exists
  apiClient.onUnauthorized = () {
    authNotifier.logout();
  };

  await authNotifier.checkAuthStatus();

  runApp(TrvlEzApp(
    authNotifier: authNotifier,
    authRepository: authRepository,
    profileRepository: profileRepository,
  ));
}

class TrvlEzApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  const TrvlEzApp({
    super.key,
    required this.authNotifier,
    required this.authRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: createRouter(authNotifier, authRepository, profileRepository),
    );
  }
}
