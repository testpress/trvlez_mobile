import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
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
                  style: context.text.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: space.stackItem),
                TabBar(
                  controller: _tabController,
                  indicatorColor: colors.brandPrimary,
                  indicatorWeight: shape.borderMedium,
                  labelColor: colors.brandPrimary,
                  unselectedLabelColor: colors.inkTertiary,
                  labelStyle: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: context.text.titleSmall,
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
    final space = context.space;
    final anywhereStays = emptyType == 'upcoming'
        ? ref.watch(anywhereStaysProvider)
        : const <AnywhereStay>[];

    if (reservations.isEmpty && anywhereStays.isEmpty) {
      if (emptyType == 'upcoming') {
        return SingleChildScrollView(
          padding: space.insetCard,
          child: Column(
            children: [
              _buildEmptyState(emptyType),
              SizedBox(height: space.stackFormField),
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
        padding: space.insetCard,
        children: [
          for (final reservation in reservations) ...[
            _ReservationCard(
              reservation: reservation,
              onTap: () => context.push(
                '/reservations/${reservation.id}',
                extra: {'reservation': reservation},
              ),
            ),
            SizedBox(height: space.stackFormField),
          ],
          if (emptyType == 'upcoming') ...[
            for (final stay in anywhereStays) ...[
              _AnywhereCard(stay: stay),
              SizedBox(height: space.stackFormField),
            ],
            _AddStayRow(onTap: () => context.push(AppRoutes.anywhereFind)),
            SizedBox(height: space.stackFormField),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
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
        padding: EdgeInsets.all(space.stackHero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: space.insetDialog,
              decoration: BoxDecoration(
                color: colors.redTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.calendar,
                size: sizes.avatarMd,
                color: colors.brandPrimary,
              ),
            ),
            SizedBox(height: space.stackFormField),
            Text(
              title,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.text.titleSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (type == 'upcoming') ...[
              SizedBox(height: space.stackSection),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.ezStays),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: colors.textOnAction,
                  shape: RoundedRectangleBorder(borderRadius: shape.radiusPill),
                  padding: space.insetControlLg,
                ),
                icon: Icon(AppIcons.search, size: sizes.iconSm),
                label: Text(
                  'Explore Properties',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(space.stackHero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.circleX,
              size: sizes.iconFeature,
              color: colors.brandPrimary,
            ),
            SizedBox(height: space.stackFormField),
            Text(
              'Failed to load reservations',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              error,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: space.stackSection),
            ElevatedButton(
              onPressed: () => ref
                  .read(reservationListProvider.notifier)
                  .fetchReservations(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: colors.textOnAction,
                shape: RoundedRectangleBorder(borderRadius: shape.radiusPill),
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
                  Row(
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
                      const Spacer(),
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
                      child: Container(
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
                              reservation.status == ReservationStatus.checkedIn
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

// ─── Anywhere Card ──────────────────────────────────────────────────

class _AnywhereCard extends StatelessWidget {
  const _AnywhereCard({required this.stay});

  final AnywhereStay stay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final (pillLabel, pillState) = switch (stay.status) {
      AnywhereStatus.sent => ('Sent to hotel', StatusPillState.awaiting),
      AnywhereStatus.noted => ('Noted by hotel', StatusPillState.confirmed),
      AnywhereStatus.desk => ('Check-in at desk', StatusPillState.completed),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: space.insetCard,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizes.avatarMd,
                height: sizes.avatarMd,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.globe,
                    size: sizes.iconSm,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stay.hotel,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: space.stackText),
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
                            stay.place,
                            style: context.text.labelMedium?.copyWith(
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
              SizedBox(width: space.inlineIconLabel),
              StatusPill(label: pillLabel, state: pillState),
            ],
          ),
          Divider(height: space.stackFormField),
          Row(
            children: [
              Icon(
                AppIcons.calendar,
                size: sizes.iconXs,
                color: colors.brandPrimary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Text(
                stay.dates,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${stay.guests} guest${stay.guests > 1 ? 's' : ''}',
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackTight),
          Row(
            children: [
              Icon(
                stay.route == AnywhereRoute.byEmail
                    ? AppIcons.mail
                    : AppIcons.shieldCheck,
                size: sizes.iconXs,
                color: colors.inkTertiary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  stay.route == AnywhereRoute.byEmail
                      ? 'Delivered to ${stay.hotelEmail}'
                      : 'TRVLez connected direct check-in',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackItem),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: space.inlineIconLabel,
              vertical: space.stackTight,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: shape.radiusControlSm,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.info,
                  size: sizes.iconXs,
                  color: colors.inkTertiary,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    'Check-in Anywhere pass · Show passport upon arrival',
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Material(
      color: colors.transparent,
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.cardBorderSoft,
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: sizes.controlSm,
                height: sizes.controlSm,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.plus,
                    size: sizes.iconSm,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in Anywhere',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      'Staying at a hotel not on TRVLez? Check in online here.',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Icon(
                AppIcons.chevronRight,
                size: sizes.iconSm,
                color: colors.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
