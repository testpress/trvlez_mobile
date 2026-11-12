import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';

/// Primary full-width button on a light surface.
class BookingAppButton extends StatelessWidget {
  const BookingAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.paddingVertical,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? paddingVertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: shape.radiusPill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: sizes.controlLg),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: paddingVertical ?? space.insetInput.top,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled ? colors.brandPrimary : colors.borderSubtle,
              borderRadius: shape.radiusPill,
            ),
            child: EzText(
              text: label,
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
