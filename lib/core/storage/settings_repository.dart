import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _themeKey = 'isDark';
  
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
}
