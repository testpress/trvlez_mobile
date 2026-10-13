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
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
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
    if (reservations.isEmpty) {
      return _buildEmptyState(emptyType);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(reservationListProvider.future),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: reservations.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _ReservationCard(
          reservation: reservations[index],
          onTap: () => context.push(
            '/reservations/${reservations[index].id}',
            extra: {'reservation': reservations[index]},
          ),
        ),
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
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandPrimary,
                  foregroundColor: Colors.white,
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
                foregroundColor: Colors.white,
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

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _ReservationCard({required this.reservation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('MMM d');

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
                                reservation.status == ReservationStatus.checkedIn
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
