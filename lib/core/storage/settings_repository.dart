import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/core/design_tokens/text_scale_preset.dart';

export 'package:trvlez_mobile/core/design_tokens/text_scale_preset.dart';

class SettingsRepository {
  static const _themeKey = 'isDark';
  static const _textScaleKey = 'textScalePreset';
  static const _twoStepKey = 'isTwoStepVerificationEnabled';
  static const _findrActivatedKey = 'isFindrActivated';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static Future<SettingsRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  ThemeMode getThemeMode() {
    final isDark = _prefs.getBool(_themeKey);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      await _prefs.remove(_themeKey);
    } else {
      await _prefs.setBool(_themeKey, mode == ThemeMode.dark);
    }
  }

  TextScalePreset getTextScalePreset() {
    final saved = _prefs.getString(_textScaleKey);
    return TextScalePreset.fromName(saved);
  }

  Future<void> setTextScalePreset(TextScalePreset preset) async {
    await _prefs.setString(_textScaleKey, preset.name);
  }

  bool isTwoStepVerificationEnabled() {
    return _prefs.getBool(_twoStepKey) ?? false;
  }

  Future<void> setTwoStepVerificationEnabled(bool enabled) async {
    await _prefs.setBool(_twoStepKey, enabled);
  }

  bool isFindrActivated() {
    return _prefs.getBool(_findrActivatedKey) ?? false;
  }

  Future<void> setFindrActivated(bool activated) async {
    await _prefs.setBool(_findrActivatedKey, activated);
  }
}

/// Provider for the [SettingsRepository].
///
/// Since [SettingsRepository] requires asynchronous initialization, this provider
/// will throw an [UnimplementedError] if read before it is overridden in [ProviderScope].
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});
