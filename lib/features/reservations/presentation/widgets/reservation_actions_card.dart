import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Action buttons for a reservation (Check-in QR, Pre-arrival form, Cancel).
class ReservationActionsCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onCheckIn;
  final VoidCallback onPreArrivalForm;
  final VoidCallback onCancel;

  const ReservationActionsCard({
    super.key,
    required this.reservation,
    required this.onCheckIn,
    required this.onPreArrivalForm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final status = reservation.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status.canGenerateQr) ...[
          AppButton(label: 'Check-in Pass (QR Code)', onPressed: onCheckIn),
          SizedBox(height: space.stackItem),
        ],
        if (reservation.propertySummary.requiresPrearrivalForm) ...[
          AppButton(
            label: 'Complete Pre-arrival Form',
            variant: AppButtonVariant.secondary,
            onPressed: onPreArrivalForm,
          ),
          SizedBox(height: space.stackItem),
        ],
        if (status.canCancel) ...[
          AppButton(
            label: 'Cancel Reservation',
            variant: AppButtonVariant.destructive,
            onPressed: onCancel,
          ),
        ],
      ],
    );
  }
}
