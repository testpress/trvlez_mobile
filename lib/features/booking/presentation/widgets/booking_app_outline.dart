import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';

/// Secondary full-width outline button on a light surface.
class BookingAppOutline extends StatelessWidget {
  const BookingAppOutline({
    super.key,
    required this.label,
    required this.onPressed,
    this.marginTop = 10.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        margin: EdgeInsets.only(top: marginTop),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.pillRadius,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48.0),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(
                  color: enabled ? colors.line : colors.borderSubtle,
                  width: 1.0,
                ),
                borderRadius: AppRadius.pillRadius,
              ),
              child: EzText(
                text: label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.0,
                  fontWeight: TypeScale.bold,
                  color: enabled ? colors.ink : colors.textDisabled,
                ),
                ezColor: enabled ? colors.brandPrimary : colors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
