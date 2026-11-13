import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';

/// Card displaying reservation summary, dates, digital pass CTA, and dispute actions.
class MyTripsReservationCard extends ConsumerWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const MyTripsReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final dateFormat = DateFormat('MMM d');
    final dispute = ref.watch(disputesProvider)[reservation.id];

    final pillState = switch (reservation.status) {
      ReservationStatus.confirmed => StatusPillState.confirmed,
      ReservationStatus.checkedIn => StatusPillState.confirmed,
      ReservationStatus.checkedOut => StatusPillState.completed,
      ReservationStatus.cancelled ||
      ReservationStatus.noShow => StatusPillState.cancelled,
      ReservationStatus.pending => StatusPillState.awaiting,
    };

    return InkWell(
      borderRadius: shape.radiusSurface,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: shape.radiusSurface,
          border: Border.all(
            color: colors.cardBorderSoft,
            width: shape.borderDefault,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhotoBox(
              height: sizes.thumbPhotoMd,
              imageUrl: reservation.propertySummary.heroImageUrl,
              borderRadius: BorderRadius.vertical(
                top: shape.radiusSurface.topLeft,
              ),
              iconSize: sizes.iconXl,
            ),
            Padding(
              padding: space.insetCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          reservation.propertySummary.name,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      StatusPill(
                        label: reservation.status.displayLabel,
                        state: pillState,
                      ),
                    ],
                  ),
                  SizedBox(height: space.stackText),
                  if (reservation.propertySummary.locationString.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: sizes.iconXs,
                          color: colors.inkTertiary,
                        ),
                        SizedBox(width: space.inlineMicro),
                        Expanded(
                          child: Text(
                            reservation.propertySummary.locationString,
                            style: context.text.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  Divider(height: space.stackFormField),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: space.inlineIconLabel,
                    runSpacing: space.stackText,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.calendar,
                            size: sizes.iconXs,
                            color: colors.brandPrimary,
                          ),
                          SizedBox(width: space.inlineIconLabel),
                          Text(
                            '${dateFormat.format(reservation.checkInDate)} – ${dateFormat.format(reservation.checkOutDate)}',
                            style: context.text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${reservation.nights} night(s)',
                        style: context.text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: space.stackText),
                  Row(
                    children: [
                      Icon(
                        AppIcons.receipt,
                        size: sizes.iconXs,
                        color: colors.inkTertiary,
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Text(
                        reservation.confirmationCode,
                        style: context.text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.status.isUpcoming ||
                      reservation.status == ReservationStatus.checkedIn) ...[
                    SizedBox(height: space.stackFormField),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (reservation.status == ReservationStatus.checkedIn) {
                          context.push(
                            AppRoutes.checkInPassPath(reservation.id),
                          );
                        } else {
                          context.push(
                            AppRoutes.checkInStepsPath(reservation.id),
                          );
                        }
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: sizes.touchTargetMin,
                        ),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                            horizontal: space.inlineItem,
                            vertical: space.stackItem,
                          ),
                          decoration: BoxDecoration(
                            color: colors.redTint,
                            borderRadius: shape.radiusSurface,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                reservation.status ==
                                        ReservationStatus.checkedIn
                                    ? AppIcons.qrcode
                                    : AppIcons.doorEnter,
                                size: sizes.iconXs,
                                color: colors.brandPrimary,
                              ),
                              SizedBox(width: space.inlineIconLabel),
                              Expanded(
                                child: Text(
                                  reservation.status ==
                                          ReservationStatus.checkedIn
                                      ? 'Digital pass ready · Show pass'
                                      : 'Check in online · Open now · Start',
                                  style: context.text.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.brandPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                AppIcons.chevronRight,
                                size: sizes.iconXs,
                                color: colors.brandPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (dispute != null && dispute.status == 'holding') ...[
                    SizedBox(height: space.stackItem),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.push(
                          AppRoutes.disputeStatusPath(reservation.id),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: space.inlineItem,
                          vertical: space.stackItem,
                        ),
                        decoration: BoxDecoration(
                          color: colors.statusWarningBackground,
                          borderRadius: shape.radiusSurface,
                          border: Border.all(
                            color: colors.statusWarningForeground.withValues(
                              alpha: 0.3,
                            ),
                            width: shape.borderDefault,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.shieldAlert,
                              size: sizes.iconXs,
                              color: colors.statusWarningForeground,
                            ),
                            SizedBox(width: space.inlineIconLabel),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment on hold',
                                    style: context.text.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.statusWarningForeground,
                                    ),
                                  ),
                                  Text(
                                    'Dispute active · Raised ${dispute.raisedAt}',
                                    style: context.text.labelSmall?.copyWith(
                                      color: colors.statusWarningForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              AppIcons.chevronRight,
                              size: sizes.iconXs,
                              color: colors.statusWarningForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (dispute != null &&
                      dispute.status == 'withdrawn') ...[
                    SizedBox(height: space.stackItem),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.inlineItem,
                        vertical: space.stackItem,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: shape.radiusSurface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.checkCircle,
                            size: sizes.iconXs,
                            color: colors.inkTertiary,
                          ),
                          SizedBox(width: space.inlineIconLabel),
                          Expanded(
                            child: Text(
                              'Dispute withdrawn · Payment released to hotel',
                              style: context.text.bodySmall?.copyWith(
                                color: colors.inkTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (reservation.status ==
                          ReservationStatus.checkedIn ||
                      reservation.status == ReservationStatus.checkedOut) ...[
                    SizedBox(height: space.stackItem),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref
                            .read(disputeDraftProvider.notifier)
                            .initDraft(
                              reservationId: reservation.id,
                              bookingReference: reservation.confirmationCode,
                              hotel: reservation.propertySummary.name,
                            );
                        context.push(
                          AppRoutes.disputeReasonPath(reservation.id),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.alertCircle,
                            size: sizes.iconXs,
                            color: colors.inkTertiary,
                          ),
                          SizedBox(width: space.inlineMicro),
                          Text(
                            'Something wrong with this stay? Report issue',
                            style: context.text.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colors.inkTertiary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
