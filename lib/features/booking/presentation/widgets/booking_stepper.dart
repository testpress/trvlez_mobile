import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Numeric stepper (`− [count] +`) with accessible touch targets.
class BookingStepper extends StatelessWidget {
  const BookingStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 30,
    this.label = '',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          glyph: '−',
          enabled: value > min,
          semanticLabel: 'Fewer $label',
          onTap: () => onChanged(value - 1),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 32.0),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            '$value',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15.0,
              fontWeight: TypeScale.bold,
              color: colors.ink,
            ),
          ),
        ),
        _StepperButton(
          glyph: '+',
          enabled: value < max,
          semanticLabel: 'More $label',
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.glyph,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
  });

  final String glyph;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 48.0,
          height: 48.0,
          alignment: Alignment.center,
          child: Container(
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? colors.line : colors.borderSubtle,
                width: 1.2,
              ),
            ),
            child: Text(
              glyph,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15.0,
                fontWeight: TypeScale.semiBold,
                color: enabled ? colors.ink : colors.inkTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
