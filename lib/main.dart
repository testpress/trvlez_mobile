import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
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
      onResume: () {
        final authState = ref.read(authNotifierProvider);
        if (authState.valueOrNull?.isAuthenticated == true) {
          ref
              .read(verificationNotifierProvider.notifier)
              .send(const ReconcileRequested());
          ref.read(authNotifierProvider.notifier).refreshVerificationState();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
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
