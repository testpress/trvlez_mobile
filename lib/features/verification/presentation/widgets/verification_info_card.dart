import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';

class InfoCard extends StatelessWidget {
  final TravelerVerificationState state;
  final String? failedStep;
  final String? errorReason;
  final String? uiMitigation;

  const InfoCard({
    super.key,
    required this.state,
    this.failedStep,
    this.errorReason,
    this.uiMitigation,
  });

  String formatStep(String step) {
    return step
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    if (state == TravelerVerificationState.failed) {
      return Container(
        padding: space.insetCard,
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withAlpha(15),
          borderRadius: shape.radiusSurface,
          border: Border.all(
            color: theme.colorScheme.error.withAlpha(40),
            width: shape.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: sizes.iconMd,
                ),
                SizedBox(width: space.inlineButtonGroup),
                Text(
                  'Verification Unsuccessful',
                  style: AppTypography.heading.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: space.inlineButtonGroup),
            if (failedStep != null && failedStep!.isNotEmpty) ...[
              Text(
                'Failed at: ${formatStep(failedStep!)}',
                style: AppTypography.label.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(200),
                ),
              ),
              SizedBox(height: space.stackText),
            ],
            Text(
              errorReason ??
                  'Your verification could not be completed. This may be due to unclear document images or a mismatch. Please try again.',
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
            ),
            if (uiMitigation != null && uiMitigation!.isNotEmpty) ...[
              SizedBox(height: space.inlineButtonGroup),
              Container(
                padding: space.insetCardCompact,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: shape.radiusControlSm,
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(40),
                    width: shape.borderDefault,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: sizes.iconSm,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(width: space.inlineIconLabel),
                    Expanded(
                      child: Text(
                        uiMitigation!,
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withAlpha(200),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    final (IconData icon, Color color, String message) = switch (state) {
      TravelerVerificationState.submitted => (
        Icons.info_outline_rounded,
        theme.colorScheme.primary,
        'Your documents are being verified automatically. This usually takes less than a minute.',
      ),
      TravelerVerificationState.verified => (
        Icons.celebration_rounded,
        theme.colorScheme.primary,
        'Congratulations! Your identity has been verified. You now have full access to all TrvlEz features.',
      ),
      _ => (
        Icons.info_outline_rounded,
        theme.colorScheme.primary,
        'Your verification status will be updated here.',
      ),
    };

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: color.withAlpha(40),
          width: shape.borderDefault,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: sizes.iconMd),
          SizedBox(width: space.inlineButtonGroup),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
