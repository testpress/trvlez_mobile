import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/core/design_tokens/tokens.dart';

CardThemeData buildCardTheme(
  AppColors colors, {
  AppShape shape = AppShape.standard,
}) {
  return CardThemeData(
    color: colors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: shape.radiusSurface,
      side: BorderSide(color: colors.borderSubtle, width: shape.borderDefault),
    ),
  );
}
