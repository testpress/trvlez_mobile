import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Pill badge rendering the status of a reservation with tokenized colors.
class ReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

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
      padding: space.insetTag,
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: shape.radiusPill,
        border: Border.all(
          color: badgeColor.withAlpha(80),
          width: shape.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: sizes.iconXs, color: badgeColor),
          SizedBox(width: space.inlineMicro),
          Text(
            status.displayLabel,
            style: context.text.labelMedium?.copyWith(color: badgeColor),
          ),
        ],
      ),
    );
  }
}
