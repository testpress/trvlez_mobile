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

  // 2. Auth State
  final authNotifier = AuthNotifier(tokenStorage: tokenStorage);
  await authNotifier.checkAuthStatus();

  // 3. Network & Data
  final apiClient = ApiClient(
    onUnauthorized: () {
      authNotifier.logout();
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
