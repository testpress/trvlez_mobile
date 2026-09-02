import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsRepository = await SettingsRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const TrvlEzApp(),
    ),
  );
}

class TrvlEzApp extends ConsumerStatefulWidget {
  const TrvlEzApp({super.key});

  @override
  ConsumerState<TrvlEzApp> createState() => _TrvlEzAppState();
}

class _TrvlEzAppState extends ConsumerState<TrvlEzApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResumed,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// Reconciles verification state when the app returns from background.
  ///
  /// Only runs if the user is authenticated — avoids unnecessary API
  /// calls when the app is brought to foreground on the login screen.
  void _onAppResumed() {
    final authState = ref.read(authNotifierProvider).valueOrNull;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    if (isAuthenticated) {
      ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
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
