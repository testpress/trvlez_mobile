import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    final space = context.space;
    final sizes = context.sizes;

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
          constraints: BoxConstraints(minWidth: sizes.iconXl),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: space.inlineMicro),
          child: Text(
            '$value',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          width: sizes.touchTargetMin,
          height: sizes.touchTargetMin,
          alignment: Alignment.center,
          child: Container(
            width: sizes.iconXl,
            height: sizes.iconXl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? colors.line : colors.borderSubtle,
                width: shape.borderDefault,
              ),
            ),
            child: Text(
              glyph,
              style: context.text.titleMedium?.copyWith(
                color: enabled ? colors.ink : colors.inkTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
