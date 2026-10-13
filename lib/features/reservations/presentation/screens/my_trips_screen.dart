import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/anywhere/domain/entities/anywhere_stay.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';

/// Displays the traveler's reservations and booking history.
class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reservationsState = ref.watch(reservationListProvider);
    final reservations = reservationsState.valueOrNull ?? [];

    final upcoming = reservations.where((r) => r.status.isUpcoming).toList();
    final completed = reservations.where((r) => r.status.isCompleted).toList();
    final cancelled = reservations.where((r) => r.status.isCancelled).toList();

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Trips',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: TypeScale.bold,
                    letterSpacing: -0.3,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TabBar(
                  controller: _tabController,
                  indicatorColor: colors.brandPrimary,
                  indicatorWeight: 2.5,
                  labelColor: colors.brandPrimary,
                  unselectedLabelColor: colors.inkTertiary,
                  labelStyle: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.medium,
                  ),
                  tabs: [
                    Tab(text: 'Upcoming (${upcoming.length})'),
                    Tab(text: 'Completed (${completed.length})'),
                    Tab(text: 'Cancelled (${cancelled.length})'),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab Bar Views ──────────────────────────────────────────────
          Expanded(
            child: _buildTabContent(
              reservationsState,
              upcoming,
              completed,
              cancelled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    AsyncValue<List<Reservation>> state,
    List<Reservation> upcoming,
    List<Reservation> completed,
    List<Reservation> cancelled,
  ) {
    if (state.isLoading && !state.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _buildErrorState(state.error.toString());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReservationList(upcoming, 'upcoming'),
        _buildReservationList(completed, 'completed'),
        _buildReservationList(cancelled, 'cancelled'),
      ],
    );
  }

  Widget _buildReservationList(
    List<Reservation> reservations,
    String emptyType,
  ) {
    final anywhereStays = emptyType == 'upcoming'
        ? ref.watch(anywhereStaysProvider)
        : const <AnywhereStay>[];

    if (reservations.isEmpty && anywhereStays.isEmpty) {
      if (emptyType == 'upcoming') {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildEmptyState(emptyType),
              const SizedBox(height: AppSpacing.md),
              _AddStayRow(onTap: () => context.push(AppRoutes.anywhereFind)),
            ],
          ),
        );
      }
      return _buildEmptyState(emptyType);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(reservationListProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final reservation in reservations) ...[
            _ReservationCard(
              reservation: reservation,
              onTap: () => context.push(
                '/reservations/${reservation.id}',
                extra: {'reservation': reservation},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (emptyType == 'upcoming') ...[
            for (final stay in anywhereStays) ...[
              _AnywhereCard(stay: stay),
              const SizedBox(height: AppSpacing.md),
            ],
            _AddStayRow(onTap: () => context.push(AppRoutes.anywhereFind)),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final colors = context.colors;
    final messages = {
      'upcoming': (
        'No upcoming trips',
        'Browse properties and book your next adventure!',
      ),
      'completed': ('No completed trips', 'Your past stays will appear here.'),
      'cancelled': (
        'No cancelled trips',
        'You haven\'t cancelled any reservations.',
      ),
    };
    final (title, subtitle) = messages[type] ?? ('No trips', '');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.redTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.calendar,
                size: 36,
                color: colors.brandPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: TypeScale.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            if (type == 'upcoming') ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.ezStays),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: colors.textOnAction,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.fullRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                icon: const Icon(AppIcons.search, size: 16),
                label: const Text(
                  'Explore Properties',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.circleX, size: 40, color: colors.brandPrimary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load reservations',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: TypeScale.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => ref
                  .read(reservationListProvider.notifier)
                  .fetchReservations(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: colors.textOnAction,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reservation Card ──────────────────────────────────────────────

class _ReservationCard extends ConsumerWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _ReservationCard({required this.reservation, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
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
      borderRadius: AppRadius.cardRadius,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: colors.cardBorderSoft),
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
              height: 130,
              imageUrl: reservation.propertySummary.heroImageUrl,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              iconSize: 32,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          reservation.propertySummary.name,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: TypeScale.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StatusPill(
                        label: reservation.status.displayLabel,
                        state: pillState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (reservation.propertySummary.locationString.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: 12,
                          color: colors.inkTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reservation.propertySummary.locationString,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const Divider(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        AppIcons.calendar,
                        size: 13,
                        color: colors.brandPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(reservation.checkInDate)} – ${dateFormat.format(reservation.checkOutDate)}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: TypeScale.semiBold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${reservation.nights} night(s)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        AppIcons.receipt,
                        size: 13,
                        color: colors.inkTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reservation.confirmationCode,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: TypeScale.medium,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.status.isUpcoming ||
                      reservation.status == ReservationStatus.checkedIn) ...[
                    const SizedBox(height: AppSpacing.md),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.redTint,
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              reservation.status == ReservationStatus.checkedIn
                                  ? AppIcons.qrcode
                                  : AppIcons.doorEnter,
                              size: 14,
                              color: colors.brandPrimary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                reservation.status ==
                                        ReservationStatus.checkedIn
                                    ? 'Digital pass ready · Show pass'
                                    : 'Check in online · Open now · Start',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: TypeScale.semiBold,
                                  color: colors.brandPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              AppIcons.chevronRight,
                              size: 13,
                              color: colors.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (dispute != null && dispute.status == 'holding') ...[
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.push(
                          AppRoutes.disputeStatusPath(reservation.id),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.statusWarningBackground,
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: colors.statusWarningForeground.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.shieldAlert,
                              size: 14,
                              color: colors.statusWarningForeground,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment on hold',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: TypeScale.bold,
                                      color: colors.statusWarningForeground,
                                    ),
                                  ),
                                  Text(
                                    'Dispute active · Raised ${dispute.raisedAt}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10,
                                      color: colors.statusWarningForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              AppIcons.chevronRight,
                              size: 13,
                              color: colors.statusWarningForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (dispute != null &&
                      dispute.status == 'withdrawn') ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.checkCircle,
                            size: 12,
                            color: colors.inkTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Dispute withdrawn · Payment released to hotel',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
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
                    const SizedBox(height: AppSpacing.sm),
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
                            size: 12,
                            color: colors.inkTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Something wrong with this stay? Report issue',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: TypeScale.medium,
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

// ─── Anywhere Card ──────────────────────────────────────────────────

class _AnywhereCard extends StatelessWidget {
  const _AnywhereCard({required this.stay});

  final AnywhereStay stay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (pillLabel, pillState) = switch (stay.status) {
      AnywhereStatus.sent => ('Sent to hotel', StatusPillState.awaiting),
      AnywhereStatus.noted => ('Noted by hotel', StatusPillState.confirmed),
      AnywhereStatus.desk => ('Check-in at desk', StatusPillState.completed),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.cardBorderSoft),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  borderRadius: AppRadius.smRadius,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.globe,
                    size: 18,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stay.hotel,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: 12,
                          color: colors.inkTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            stay.place,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusPill(label: pillLabel, state: pillState),
            ],
          ),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Icon(AppIcons.calendar, size: 13, color: colors.brandPrimary),
              const SizedBox(width: 6),
              Text(
                stay.dates,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: TypeScale.semiBold,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${stay.guests} guest${stay.guests > 1 ? 's' : ''}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                stay.route == AnywhereRoute.byEmail
                    ? AppIcons.mail
                    : AppIcons.shieldCheck,
                size: 13,
                color: colors.inkTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  stay.route == AnywhereRoute.byEmail
                      ? 'Delivered to ${stay.hotelEmail}'
                      : 'TRVLez connected direct check-in',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.smRadius,
            ),
            child: Row(
              children: [
                Icon(AppIcons.info, size: 12, color: colors.inkTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Check-in Anywhere pass · Show passport upon arrival',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: TypeScale.medium,
                      color: colors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Stay Row ───────────────────────────────────────────────────

class _AddStayRow extends StatelessWidget {
  const _AddStayRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: colors.cardBorderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.plus,
                    size: 16,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in Anywhere',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Staying at a hotel not on TRVLez? Check in online here.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(AppIcons.chevronRight, size: 16, color: colors.inkTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
