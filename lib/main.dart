import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_notifier.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';

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

  runApp(TrvlEzApp(
    authNotifier: authNotifier,
    authRepository: authRepository,
  ));
}

class TrvlEzApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  final AuthRepository authRepository;

  const TrvlEzApp({
    super.key,
    required this.authNotifier,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: createRouter(authNotifier, authRepository),
    );
  }
}
