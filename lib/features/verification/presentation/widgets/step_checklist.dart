import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';

enum StepStatus { completed, processing, failed }

class StepItem {
  final String label;
  final StepStatus status;

  const StepItem({required this.label, required this.status});
}

class StepChecklist extends StatelessWidget {
  final TravelerVerificationState state;
  final bool isNfcSkipped;
  final bool hasNfcResult;

  const StepChecklist({
    super.key,
    required this.state,
    this.isNfcSkipped = false,
    this.hasNfcResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = context.space;
    final shape = context.shape;

    // All steps before the user reaches the status screen are already done
    // (profile, passport, selfie). Only "Review" varies.
    final steps = [
      const StepItem(label: 'Complete Profile', status: StepStatus.completed),
      const StepItem(label: 'Upload Passport', status: StepStatus.completed),
      const StepItem(
        label: 'Selfie Verification',
        status: StepStatus.completed,
      ),
      if (hasNfcResult ||
          !isNfcSkipped) // Show NFC step if it was done, or assume done if not explicitly skipped
        StepItem(
          label: 'NFC Passport Scan',
          status: hasNfcResult
              ? StepStatus.completed
              : (isNfcSkipped ? StepStatus.failed : StepStatus.completed),
        ),
      StepItem(
        label: 'Identity Review',
        status: switch (state) {
          TravelerVerificationState.verified => StepStatus.completed,
          TravelerVerificationState.failed => StepStatus.failed,
          _ => StepStatus.processing,
        },
      ),
    ];

    return Container(
      padding: space.insetCardComfortable,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: shape.radiusOverlay,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Steps',
            style: AppTypography.heading.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: space.stackFormField),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return StepRow(step: step, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class StepRow extends StatelessWidget {
  final StepItem step;
  final bool isLast;

  const StepRow({super.key, required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final (IconData icon, Color color) = switch (step.status) {
      StepStatus.completed => (
        Icons.check_circle_rounded,
        theme.colorScheme.primary,
      ),
      StepStatus.processing => (
        Icons.hourglass_top_rounded,
        theme.colorScheme.tertiary,
      ),
      StepStatus.failed => (Icons.cancel_rounded, theme.colorScheme.error),
    };

    final statusLabel = switch (step.status) {
      StepStatus.completed => 'Completed',
      StepStatus.processing => 'In Progress',
      StepStatus.failed => 'Failed',
    };

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : space.insetCardComfortable.top,
      ),
      child: Row(
        children: [
          // Step icon
          SizedBox(
            width: sizes.iconXl,
            child: Center(
              child: Icon(icon, color: color, size: sizes.iconLg),
            ),
          ),
          SizedBox(width: space.inlineItem),
          Expanded(
            child: Text(
              step.label,
              style: AppTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: space.insetTag,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: shape.radiusControlSm,
            ),
            child: Text(
              statusLabel,
              style: AppTypography.label.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
