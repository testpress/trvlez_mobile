import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';

/// Extension methods on [BuildContext] to access semantic theme tokens easily.
extension AppThemeContext on BuildContext {
  /// Access semantic color tokens configured in [ThemeData.extensions].
  ///
  /// Falls back to [AppColors.dark] or [AppColors.light] based on active brightness
  /// if the extension has not been registered (e.g. in standalone tests).
  AppColors get colors {
    final extension = Theme.of(this).extension<AppColors>();
    if (extension != null) return extension;
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppColors.dark : AppColors.light;
  }

  /// Access the active typography [TextTheme].
  TextTheme get text => Theme.of(this).textTheme;
}
