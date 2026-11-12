import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/design_tokens/tokens.dart';

InputDecorationTheme buildInputTheme(
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppShape shape = AppShape.standard,
}) {
  final textTheme = AppTypography.buildTextTheme(colors);
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.surfaceSubtle,
    contentPadding: space.insetInput,
    hintStyle: textTheme.bodyLarge?.copyWith(color: colors.textDisabled),
    labelStyle: textTheme.titleSmall?.copyWith(color: colors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: shape.radiusControl,
      borderSide: BorderSide(
        color: colors.borderSubtle,
        width: shape.borderDefault,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: shape.radiusControl,
      borderSide: BorderSide(
        color: colors.borderSubtle,
        width: shape.borderDefault,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: shape.radiusControl,
      borderSide: BorderSide(
        color: colors.borderFocused,
        width: shape.borderMedium,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: shape.radiusControl,
      borderSide: BorderSide(
        color: colors.feedbackError,
        width: shape.borderDefault,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: shape.radiusControl,
      borderSide: BorderSide(
        color: colors.feedbackError,
        width: shape.borderMedium,
      ),
    ),
    errorStyle: textTheme.labelMedium?.copyWith(color: colors.feedbackError),
  );
}
