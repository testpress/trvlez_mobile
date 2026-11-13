import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/core/widgets/app_confirmation_dialog.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_actions_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_info_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_property_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_status_badge.dart';

/// Detailed view of a single reservation.
class ReservationDetailScreen extends StatelessWidget {
  final String reservationId;
  final Reservation? reservation;
  final ReservationRepository? repository;

  ReservationDetailScreen({
    super.key,
    String? reservationId,
    this.reservation,
    this.repository,
  }) : reservationId = reservationId ?? reservation?.id ?? '';

  @override
  Widget build(BuildContext context) {
    if (repository != null) {
      return ProviderScope(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(repository!),
        ],
        child: _ReservationDetailContent(
          reservationId: reservationId,
          reservation: reservation,
        ),
      );
    }

    return _ReservationDetailContent(
      reservationId: reservationId,
      reservation: reservation,
    );
  }
}

class _ReservationDetailContent extends ConsumerWidget {
  final String reservationId;
  final Reservation? reservation;

  const _ReservationDetailContent({
    required this.reservationId,
    this.reservation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    if (reservation != null) {
      final reservationsState = ref.watch(reservationListProvider);
      final updated = reservationsState.valueOrNull
          ?.where((r) => r.id == reservationId)
          .firstOrNull;
      final activeReservation = updated ?? reservation!;
      return _buildScaffold(context, ref, activeReservation);
    }

    final detailAsync = ref.watch(
      reservationDetailNotifierProvider(reservationId),
    );

    final sizes = context.sizes;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, size: sizes.iconMd),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservation Details',
          style: context.text.headlineMedium?.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: detailAsync.when(
        data: (loaded) => _buildBody(context, ref, loaded),
        loading: () => const LoadingView(message: 'Loading reservation...'),
        error: (err, stack) => ErrorView.fromError(
          error: err,
          title: 'Unable to load reservation',
          onRetry: () {
            ref
                .read(reservationDetailNotifierProvider(reservationId).notifier)
                .refresh();
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    Reservation activeReservation,
  ) {
    final colors = context.colors;
    final sizes = context.sizes;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, size: sizes.iconMd),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservation Details',
          style: context.text.headlineMedium?.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(context, ref, activeReservation),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Reservation activeReservation,
  ) {
    final space = context.space;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reservationDetailNotifierProvider(reservationId));
        ref.invalidate(reservationListProvider);
        await ref.read(reservationDetailNotifierProvider(reservationId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: space.insetScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationPropertyCard(
              property: activeReservation.propertySummary,
            ),
            SizedBox(height: space.stackFormField),
            _buildStatusCard(context, activeReservation),
            SizedBox(height: space.stackFormField),
            ReservationInfoCard(
              title: 'Stay Details',
              children: [
                ReservationInfoRow(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: dateFormat.format(activeReservation.checkInDate),
                ),
                ReservationInfoRow(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: dateFormat.format(activeReservation.checkOutDate),
                ),
                ReservationInfoRow(
                  icon: Icons.nights_stay_outlined,
                  label: 'Duration',
                  value: '${activeReservation.nights} night(s)',
                ),
                if (activeReservation.totalAmount != null)
                  ReservationInfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total Amount',
                    value: PriceFormatter.formatTotal(
                      activeReservation.totalAmount!,
                      currencyCode: activeReservation.currencyCode,
                    ),
                  ),
              ],
            ),
            SizedBox(height: space.stackFormField),
            ReservationInfoCard(
              title: 'Guest Information',
              children: [
                ReservationInfoRow(
                  icon: Icons.person_outline,
                  label: 'Guest Name',
                  value: activeReservation.guestName,
                ),
                ReservationInfoRow(
                  icon: Icons.group_outlined,
                  label: 'Guests',
                  value: '${activeReservation.numberOfGuests}',
                ),
                ReservationInfoRow(
                  icon: Icons.bed_outlined,
                  label: 'Rooms',
                  value: activeReservation.rooms
                      .map((r) => r.roomNumber)
                      .join(', '),
                ),
                if (activeReservation.guestEmail != null)
                  ReservationInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: activeReservation.guestEmail!,
                  ),
                if (activeReservation.guestPhone != null)
                  ReservationInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: activeReservation.guestPhone!,
                  ),
              ],
            ),
            if (activeReservation.specialRequests != null &&
                activeReservation.specialRequests!.isNotEmpty) ...[
              SizedBox(height: space.stackFormField),
              ReservationInfoCard(
                title: 'Special Requests',
                children: [
                  Text(
                    activeReservation.specialRequests!,
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: space.stackHero),
            ReservationActionsCard(
              reservation: activeReservation,
              onCheckIn: () {
                if (activeReservation.status == ReservationStatus.checkedIn) {
                  context.push(AppRoutes.checkInPassPath(activeReservation.id));
                } else {
                  context.push(
                    AppRoutes.checkInStepsPath(activeReservation.id),
                  );
                }
              },
              onPreArrivalForm: () {
                context.push(
                  AppRoutes.reservationFormPath(activeReservation.id),
                );
              },
              onCancel: () => _handleCancel(context, ref, activeReservation),
            ),
            SizedBox(height: space.stackHero),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Reservation activeReservation) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: space.inlineItem,
        runSpacing: space.stackItem,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONFIRMATION CODE',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                activeReservation.confirmationCode,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.actionPrimary,
                ),
              ),
            ],
          ),
          ReservationStatusBadge(status: activeReservation.status),
        ],
      ),
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    WidgetRef ref,
    Reservation activeReservation,
  ) async {
    final colors = context.colors;
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Cancel Reservation?',
      message:
          'Are you sure you want to cancel this reservation at ${activeReservation.propertySummary.name}?',
      confirmLabel: 'Cancel Reservation',
      cancelLabel: 'Keep it',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(reservationListProvider.notifier)
          .cancelReservation(activeReservation.id);

      if (context.mounted) {
        if (success) {
          ref.invalidate(
            reservationDetailNotifierProvider(activeReservation.id),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation cancelled successfully.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Failed to cancel reservation. Please try again.',
              ),
              backgroundColor: colors.feedbackError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
