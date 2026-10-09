import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';

/// Instructions and verification guidance card shown upon reservation confirmation.
class BookingInstructionsCard extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final String propertyName;
  final VoidCallback onVerifyTap;

  const BookingInstructionsCard({
    super.key,
    required this.verificationState,
    required this.propertyName,
    required this.onVerifyTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.feedbackWarning.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.feedbackWarning.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: colors.feedbackWarning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Verification Required to Check In',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$propertyName requires all arriving guests to complete identity verification before key issuance.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: onVerifyTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verify Your Identity Now',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.actionPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colors.actionPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
