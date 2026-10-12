import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';

/// Primary full-width button on a light surface.
class BookingAppButton extends StatelessWidget {
  const BookingAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.paddingVertical = 14.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final double paddingVertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.pillRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 48.0),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: paddingVertical),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled ? colors.brandPrimary : colors.borderSubtle,
              borderRadius: AppRadius.pillRadius,
            ),
            child: EzText(
              text: label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.0,
                fontWeight: TypeScale.bold,
                color: enabled ? colors.brandOnSurface : colors.textDisabled,
              ),
              ezColor: enabled ? colors.brandOnSurface : colors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}
