import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/theme.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';

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
