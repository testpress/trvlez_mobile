import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
export 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
export 'package:trvlez_mobile/core/design_tokens/tokens.dart';

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

/// Semantic text role extensions on [TextTheme].
extension TrvlEzTextTheme on TextTheme {
  /// Brand screen main heading (26pt bold).
  TextStyle? get brandHeading => headlineLarge;

  /// Brand screen subtitle / description (16pt medium).
  TextStyle? get brandSubtitle => bodyLarge;

  /// Semantic typography for primary button labels (15pt semibold).
  TextStyle? get buttonLabel => titleMedium;
}
