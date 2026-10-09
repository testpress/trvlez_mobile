import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Primary action buttons at the bottom of the confirmation screen.
class BookingActionFooter extends StatelessWidget {
  final Reservation reservation;
  final bool isKycVerified;
  final TravelerVerificationState verificationState;
  final VoidCallback onStartVerification;
  final VoidCallback onViewTrips;

  const BookingActionFooter({
    super.key,
    required this.reservation,
    required this.isKycVerified,
    required this.verificationState,
    required this.onStartVerification,
    required this.onViewTrips,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isKycVerified) ...[
          AppButton(
            label: verificationState.needsOnboarding
                ? 'Start Identity Verification'
                : 'Check Verification Status',
            onPressed: onStartVerification,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppButton(
          label: 'View in My Trips',
          variant: isKycVerified
              ? AppButtonVariant.primary
              : AppButtonVariant.secondary,
          onPressed: onViewTrips,
        ),
      ],
    );
  }
}
