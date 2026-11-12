import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/router/app_router.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/attribution/attribution_providers.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Root application widget for TrvlEz.
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
    _lifecycleListener = AppLifecycleListener(onResume: _onAppResumed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onAppResumed();
      _triggerAttributionCapture();
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// Triggers background capture of Android Play Install Referrer attribution evidence.
  void _triggerAttributionCapture() {
    try {
      ref.read(attributionServiceProvider).captureInstallReferrer().catchError((
        error,
      ) {
        debugPrint('[App] Attribution capture background failure: $error');
        return false;
      });
    } catch (exception) {
      debugPrint('[App] Error dispatching attribution capture: $exception');
    }
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
    } else {
      _triggerAttributionCapture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeModeProvider);
    final textScalePreset = ref.watch(textScaleNotifierProvider);

    return MaterialApp.router(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentMode,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final effectiveScaler = textScalePreset.scalerFor(
          mediaQuery.textScaler,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: effectiveScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
