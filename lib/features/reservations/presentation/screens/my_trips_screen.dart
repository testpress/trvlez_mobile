import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/empty_view.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/anywhere/domain/entities/anywhere_stay.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/my_trips_add_stay_row.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/my_trips_anywhere_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/my_trips_reservation_card.dart';

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
    final sizes = context.sizes;
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
                    Tab(
                      height: sizes.touchTargetMin,
                      text: 'Upcoming (${upcoming.length})',
                    ),
                    Tab(
                      height: sizes.touchTargetMin,
                      text: 'Completed (${completed.length})',
                    ),
                    Tab(
                      height: sizes.touchTargetMin,
                      text: 'Cancelled (${cancelled.length})',
                    ),
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
      return const LoadingView(message: 'Loading trips...');
    }

    if (state.hasError) {
      return _buildErrorState(state.error);
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
              MyTripsAddStayRow(
                onTap: () => context.push(AppRoutes.anywhereFind),
              ),
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
            MyTripsReservationCard(
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
              MyTripsAnywhereCard(stay: stay),
              SizedBox(height: space.stackFormField),
            ],
            MyTripsAddStayRow(
              onTap: () => context.push(AppRoutes.anywhereFind),
            ),
            SizedBox(height: space.stackFormField),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
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

    return EmptyView(
      icon: AppIcons.calendar,
      title: title,
      subtitle: subtitle,
      actionLabel: type == 'upcoming' ? 'Explore Properties' : null,
      onAction: type == 'upcoming'
          ? () => context.push(AppRoutes.ezStays)
          : null,
    );
  }

  Widget _buildErrorState(Object? error) {
    return ErrorView.fromError(
      error: error,
      title: 'Failed to load reservations',
      onRetry: () =>
          ref.read(reservationListProvider.notifier).fetchReservations(),
      retryLabel: 'Retry',
    );
  }
}
