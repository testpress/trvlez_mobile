import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservation Details',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: detailAsync.when(
        data: (loaded) => _buildBody(context, ref, loaded),
        loading: () => const LoadingView(message: 'Loading reservation...'),
        error: (err, stack) => ErrorView(
          title: 'Unable to load reservation',
          message: err.toString(),
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservation Details',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
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
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reservationDetailNotifierProvider(reservationId));
        ref.invalidate(reservationListProvider);
        await ref.read(reservationDetailNotifierProvider(reservationId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationPropertyCard(
              property: activeReservation.propertySummary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatusCard(context, activeReservation),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
              ReservationInfoCard(
                title: 'Special Requests',
                children: [
                  Text(
                    activeReservation.specialRequests!,
                    style: GoogleFonts.cabin(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            ReservationActionsCard(
              reservation: activeReservation,
              onCheckIn: () {
                context.push(
                  AppRoutes.reservationQrPath(activeReservation.id),
                  extra: activeReservation,
                );
              },
              onPreArrivalForm: () {
                context.push(
                  AppRoutes.reservationFormPath(activeReservation.id),
                );
              },
              onCancel: () => _handleCancel(context, ref, activeReservation),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Reservation activeReservation) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONFIRMATION CODE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                activeReservation.confirmationCode,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Cancel Reservation?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to cancel this reservation at ${activeReservation.propertySummary.name}?',
            style: GoogleFonts.cabin(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Keep it'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colors.feedbackError,
              ),
              child: const Text('Cancel Reservation'),
            ),
          ],
        );
      },
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
