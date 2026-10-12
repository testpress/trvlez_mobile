import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Container(
              width: 38.0,
              height: 2.0,
              margin: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                color: colors.verificationStepTrack,
                borderRadius: BorderRadius.circular(2.0),
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
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            width: 56.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: 22.0,
                  height: 22.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: states[i] == TrioState.waiting
                        ? Colors.transparent
                        : colors.brandOnSurface,
                    border: Border.all(
                      color: states[i] == TrioState.waiting
                          ? colors.verificationStepRing
                          : colors.brandOnSurface,
                      width: 1.5,
                    ),
                  ),
                  child: switch (states[i]) {
                    TrioState.waiting => const SizedBox.shrink(),
                    TrioState.done => Icon(
                        AppIcons.check,
                        size: 13.0,
                        color: colors.brandPrimary,
                      ),
                    TrioState.failed => Icon(
                        AppIcons.close,
                        size: 13.0,
                        color: colors.brandActionLabel,
                      ),
                  },
                ),
                const SizedBox(height: 7.0),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.5,
                    fontWeight: states[i] != TrioState.waiting
                        ? TypeScale.semiBold
                        : TypeScale.regular,
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
