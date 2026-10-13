import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Pill badge rendering the status of a reservation with tokenized colors.
class ReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color badgeColor;
    final IconData badgeIcon;

    switch (status) {
      case ReservationStatus.confirmed:
      case ReservationStatus.checkedIn:
        badgeColor = colors.feedbackSuccess;
        badgeIcon = Icons.check_circle_outline;
      case ReservationStatus.checkedOut:
        badgeColor = colors.textSecondary;
        badgeIcon = Icons.done_all;
      case ReservationStatus.cancelled:
      case ReservationStatus.noShow:
        badgeColor = colors.feedbackError;
        badgeIcon = Icons.cancel_outlined;
      case ReservationStatus.pending:
        badgeColor = colors.feedbackWarning;
        badgeIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: badgeColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.displayLabel,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
