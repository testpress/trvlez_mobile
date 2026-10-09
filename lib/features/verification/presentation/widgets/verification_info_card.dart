import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

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

    if (state == TravelerVerificationState.failed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withAlpha(15),
          borderRadius: AppRadius.lgRadius,
          border: Border.all(color: theme.colorScheme.error.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Verification Unsuccessful',
                  style: GoogleFonts.cabin(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (failedStep != null && failedStep!.isNotEmpty) ...[
              Text(
                'Failed at: ${formatStep(failedStep!)}',
                style: GoogleFonts.cabin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withAlpha(200),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              errorReason ??
                  'Your verification could not be completed. This may be due to unclear document images or a mismatch. Please try again.',
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
            ),
            if (uiMitigation != null && uiMitigation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.smRadius,
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(40),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uiMitigation!,
                        style: GoogleFonts.cabin(
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cabin(
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
