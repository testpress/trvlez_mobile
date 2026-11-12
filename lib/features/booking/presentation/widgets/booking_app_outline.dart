import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';

/// Secondary full-width outline button on a light surface.
class BookingAppOutline extends StatelessWidget {
  const BookingAppOutline({
    super.key,
    required this.label,
    required this.onPressed,
    this.marginTop,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? marginTop;

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
      child: Container(
        margin: EdgeInsets.only(top: marginTop ?? space.inlineButtonGroup),
        child: Material(
          color: colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: shape.radiusPill,
            child: Container(
              constraints: BoxConstraints(minHeight: sizes.controlLg),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: space.insetControlMd.top),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(
                  color: enabled ? colors.line : colors.borderSubtle,
                  width: shape.borderDefault,
                ),
                borderRadius: shape.radiusPill,
              ),
              child: EzText(
                text: label,
                style: context.text.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
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
