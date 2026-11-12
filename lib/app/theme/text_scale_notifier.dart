import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Notifier managing the active [TextScalePreset].
class TextScaleNotifier extends Notifier<TextScalePreset> {
  @override
  TextScalePreset build() {
    try {
      return ref.watch(settingsRepositoryProvider).getTextScalePreset();
    } catch (error, stackTrace) {
      // Harmless fallback to system default if settings repository is unconfigured.
      AppLogger.debug(
        'Settings repository unconfigured for text scale preset',
        error,
        stackTrace,
      );
      return TextScalePreset.followSystem;
    }
  }

  Future<void> setTextScalePreset(TextScalePreset preset) async {
    state = preset;
    try {
      await ref.read(settingsRepositoryProvider).setTextScalePreset(preset);
    } catch (error, stackTrace) {
      // Harmless best-effort persistence: in-memory state is already updated.
      AppLogger.warning(
        'Failed to persist text scale preset',
        error,
        stackTrace,
      );
    }
  }
}

/// Provider for the application's active [TextScalePreset].
final textScaleNotifierProvider =
    NotifierProvider<TextScaleNotifier, TextScalePreset>(() {
      return TextScaleNotifier();
    });
