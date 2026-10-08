import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

CardThemeData buildCardTheme(AppColors colors) {
  return CardThemeData(
    color: colors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: BorderSide(color: colors.borderSubtle),
    ),
  );
}
