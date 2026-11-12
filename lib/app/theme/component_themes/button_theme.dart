import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/design_tokens/tokens.dart';

FilledButtonThemeData buildFilledButtonTheme(
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppSize size = AppSize.regular,
  AppShape shape = AppShape.standard,
}) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: Size(double.infinity, size.controlLg),
      padding: space.insetControlMd,
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: shape.radiusControl),
      textStyle: AppTypography.buttonLabel,
      elevation: 0,
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppSize size = AppSize.regular,
  AppShape shape = AppShape.standard,
}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, size.controlLg),
      padding: space.insetControlMd,
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: shape.radiusControl),
      textStyle: AppTypography.buttonLabel,
      elevation: 0,
    ),
  );
}

OutlinedButtonThemeData buildOutlinedButtonTheme(
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppSize size = AppSize.regular,
  AppShape shape = AppShape.standard,
}) {
  final textTheme = AppTypography.buildTextTheme(colors);
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, size.touchTargetMin),
      padding: space.insetControlMd,
      foregroundColor: colors.textPrimary,
      side: BorderSide(color: colors.borderSubtle, width: shape.borderDefault),
      shape: RoundedRectangleBorder(borderRadius: shape.radiusControl),
      textStyle: textTheme.labelLarge,
    ),
  );
}

TextButtonThemeData buildTextButtonTheme(
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppSize size = AppSize.regular,
  AppShape shape = AppShape.standard,
}) {
  final textTheme = AppTypography.buildTextTheme(colors);
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: space.insetControlSm,
      foregroundColor: colors.actionPrimary,
      textStyle: textTheme.labelLarge,
    ),
  );
}
