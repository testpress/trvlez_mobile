import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';

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

    // All steps before the user reaches the status screen are already done
    // (profile, passport, selfie). Only "Review" varies.
    final steps = [
      StepItem(label: 'Complete Profile', status: StepStatus.completed),
      StepItem(label: 'Upload Passport', status: StepStatus.completed),
      StepItem(label: 'Selfie Verification', status: StepStatus.completed),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Steps',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          // Step icon
          SizedBox(
            width: 32,
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              step.label,
              style: GoogleFonts.cabin(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.cabin(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
