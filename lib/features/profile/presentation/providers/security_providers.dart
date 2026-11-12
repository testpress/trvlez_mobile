import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/storage/passcode_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';

/// Provider for active passcode enabled status.
final appPasscodeNotifierProvider =
    AsyncNotifierProvider<AppPasscodeNotifier, bool>(() {
      return AppPasscodeNotifier();
    });

/// Async notifier managing whether the device passcode lock is enabled.
class AppPasscodeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = ref.watch(passcodeStorageProvider);
    return storage.isPasscodeEnabled();
  }

  Future<void> toggleEnabled() async {
    final current = state.valueOrNull ?? false;
    final storage = ref.read(passcodeStorageProvider);
    final next = !current;
    await storage.setPasscodeEnabled(next);
    state = AsyncData(next);
  }

  Future<void> setPasscode(String passcode) async {
    final storage = ref.read(passcodeStorageProvider);
    await storage.setPasscode(passcode);
    state = const AsyncData(true);
  }

  Future<void> disablePasscode() async {
    final storage = ref.read(passcodeStorageProvider);
    await storage.setPasscodeEnabled(false);
    state = const AsyncData(false);
  }
}

/// Provider for two-step verification setting state.
final twoStepVerificationNotifierProvider =
    NotifierProvider<TwoStepVerificationNotifier, bool>(() {
      return TwoStepVerificationNotifier();
    });

/// Notifier managing whether two-step verification is toggled on.
class TwoStepVerificationNotifier extends Notifier<bool> {
  @override
  bool build() {
    try {
      return ref
          .watch(settingsRepositoryProvider)
          .isTwoStepVerificationEnabled();
    } catch (error, stackTrace) {
      // Harmless default fallback when settings repository is unavailable (e.g. test isolation).
      AppLogger.debug(
        'Settings repository unavailable for 2-step verification',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> toggle() async {
    final next = !state;
    state = next;
    try {
      await ref
          .read(settingsRepositoryProvider)
          .setTwoStepVerificationEnabled(next);
    } catch (error, stackTrace) {
      // Best-effort settings persistence; in-memory state is already updated.
      AppLogger.warning(
        'Failed to persist two-step verification setting',
        error,
        stackTrace,
      );
    }
  }
}
