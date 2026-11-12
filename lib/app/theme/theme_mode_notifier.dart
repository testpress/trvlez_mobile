import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Notifier to manage the application's [ThemeMode].
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      return ref.watch(settingsRepositoryProvider).getThemeMode();
    } catch (error, stackTrace) {
      // Harmless fallback to light theme if settings repository is unconfigured.
      AppLogger.debug(
        'Settings repository unconfigured for theme mode',
        error,
        stackTrace,
      );
      return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(settingsRepositoryProvider).setThemeMode(mode);
    } catch (error, stackTrace) {
      // Harmless best-effort persistence: in-memory state is already updated;
      // storage failure does not degrade active UI session.
      AppLogger.warning('Failed to persist theme mode', error, stackTrace);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

/// Provider for the application's [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
