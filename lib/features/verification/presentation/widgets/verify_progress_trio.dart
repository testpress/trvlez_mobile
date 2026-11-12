import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

enum TrioState { waiting, done, failed }

typedef TrioStepState = TrioState;

/// Animated 2 or 3 step progress indicator (e.g., Upload -> Check -> Read).
class VerifyProgressTrio extends StatelessWidget {
  const VerifyProgressTrio({
    super.key,
    required this.labels,
    required this.states,
  });

  final List<String> labels;
  final List<TrioState> states;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0)
            SizedBox(
              height: sizes.iconDefault,
              child: Center(
                child: Container(
                  width: sizes.controlSm,
                  height: shape.borderFocus,
                  decoration: BoxDecoration(
                    color: colors.verificationStepTrack,
                    borderRadius: shape.radiusMicro,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 450),
                      curve: const Cubic(0.4, 0.0, 0.2, 1.0),
                      widthFactor: states[i - 1] == TrioState.done ? 1.0 : 0.0,
                      heightFactor: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.brandOnSurface,
                          borderRadius: shape.radiusMicro,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            width: sizes.controlXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: sizes.iconDefault,
                  height: sizes.iconDefault,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: states[i] == TrioState.waiting
                        ? colors.transparent
                        : colors.brandOnSurface,
                    border: Border.all(
                      color: states[i] == TrioState.waiting
                          ? colors.verificationStepRing
                          : colors.brandOnSurface,
                      width: shape.borderMedium,
                    ),
                  ),
                  child: switch (states[i]) {
                    TrioState.waiting => const SizedBox.shrink(),
                    TrioState.done => Icon(
                      AppIcons.check,
                      size: sizes.iconXs,
                      color: colors.brandPrimary,
                    ),
                    TrioState.failed => Icon(
                      AppIcons.close,
                      size: sizes.iconXs,
                      color: colors.brandActionLabel,
                    ),
                  },
                ),
                SizedBox(height: space.stackItem),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: states[i] != TrioState.waiting
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: states[i] != TrioState.waiting
                        ? colors.brandOnSurface
                        : colors.verificationStepInactiveText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
