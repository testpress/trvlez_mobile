import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The 4 standard verification step labels per the design system.
const List<String> kVerificationStepLabels = [
  'Passport',
  'Profile\nReview',
  'Selfie',
  'NFC',
];

/// The 4-step horizontal stepper for identity verification flows.
///
/// Steps prior to [current] display a checkmark.
/// Step [current] displays the active step number with a white circle.
/// Subsequent steps display a translucent ring with the step number.
/// Connector tracks animate a fill line when steps are completed.
class VerificationStepper extends StatelessWidget {
  const VerificationStepper({
    super.key,
    required this.current,
    this.circleSize = 26.0,
    this.labels = kVerificationStepLabels,
  });

  /// 0-based index of the currently active step (0..4).
  final int current;

  /// Diameter of the step circle indicator.
  final double circleSize;

  /// Step labels. Must match length of the steps.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inset = circleSize / 2 + 4.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / labels.length;

        return Stack(
          children: [
            // ── Connectors behind the step circles ──────────────────────────
            for (int i = 0; i < labels.length - 1; i++)
              Positioned(
                top: circleSize / 2 - 0.75,
                left: cellWidth * i + cellWidth / 2 + inset,
                width: cellWidth - (inset * 2),
                height: 2.0,
                child: _StepConnector(
                  isFilled: i < current,
                  trackColor: colors.verificationStepTrack,
                  fillColor: colors.brandOnSurface,
                ),
              ),

            // ── Step circles and two-line labels ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < labels.length; i++)
                  Expanded(
                    child: _StepNode(
                      index: i,
                      label: labels[i],
                      isDone: i < current,
                      isActive: i == current,
                      size: circleSize,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({
    required this.isFilled,
    required this.trackColor,
    required this.fillColor,
  });

  final bool isFilled;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 450),
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
          widthFactor: isFilled ? 1.0 : 0.0,
          heightFactor: 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.size,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isActive;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isOn = isDone || isActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? colors.brandOnSurface : Colors.transparent,
            border: Border.all(
              color: isOn ? colors.brandOnSurface : colors.verificationStepRing,
              width: 1.5,
            ),
          ),
          child: isDone
              ? Icon(
                  AppIcons.check,
                  size: size * 0.56,
                  color: colors.brandPrimary,
                )
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.44,
                    fontWeight: isOn ? TypeScale.semiBold : TypeScale.medium,
                    color: isOn
                        ? colors.verificationStepActiveText
                        : colors.verificationStepInactiveText,
                    height: 1.0,
                  ),
                ),
        ),
        const SizedBox(height: 6.0),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10.5,
            fontWeight: isOn ? TypeScale.semiBold : TypeScale.regular,
            color: isOn
                ? colors.brandOnSurface
                : colors.verificationStepInactiveText,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
