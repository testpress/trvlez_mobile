import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
                AppIcons.shield,
                color: colors.feedbackWarning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Verification Required to Check In',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$propertyName requires all arriving guests to complete identity verification before key issuance.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
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
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                    color: colors.actionPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  AppIcons.arrowRight,
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
