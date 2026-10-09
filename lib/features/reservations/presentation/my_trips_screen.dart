import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_status_badge.dart';

/// Displays the traveler's reservations organized by status tabs.
///
/// Replaces the old "Tickets Coming Soon" placeholder.
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
    final colorScheme = Theme.of(context).colorScheme;
    final reservationsState = ref.watch(reservationListProvider);
    final reservations = reservationsState.valueOrNull ?? [];

    final upcoming = reservations.where((r) => r.status.isUpcoming).toList();
    final completed = reservations.where((r) => r.status.isCompleted).toList();
    final cancelled = reservations.where((r) => r.status.isCancelled).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            _buildTabBar(
              colorScheme,
              upcoming.length,
              completed.length,
              cancelled.length,
            ),
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
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'My Trips',
        style: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTabBar(
    ColorScheme colorScheme,
    int upcomingCount,
    int completedCount,
    int cancelledCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        controller: _tabController,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: 'Upcoming ($upcomingCount)'),
          Tab(text: 'Completed ($completedCount)'),
          Tab(text: 'Cancelled ($cancelledCount)'),
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
        padding: const EdgeInsets.all(24),
        itemCount: reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    final colorScheme = Theme.of(context).colorScheme;
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
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.luggage_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (type == 'upcoming') ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.search, size: 18),
                label: const Text(
                  'Explore Properties',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load reservations',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.nunito(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(reservationListProvider.notifier).fetchReservations(),
            child: const Text('Retry'),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: _buildImage(colorScheme),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reservation.propertySummary.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ReservationStatusBadge(status: reservation.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (reservation.propertySummary.locationString.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reservation.propertySummary.locationString,
                          style: GoogleFonts.cabin(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Divider(color: colorScheme.outlineVariant, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(reservation.checkInDate)} – ${dateFormat.format(reservation.checkOutDate)}',
                        style: GoogleFonts.cabin(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${reservation.nights} night(s)',
                        style: GoogleFonts.cabin(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reservation.confirmationCode,
                        style: GoogleFonts.cabin(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    final imageUrl = reservation.propertySummary.heroImageUrl ?? '';
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 140,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.hotel, size: 40, color: colorScheme.onSurfaceVariant),
    );
  }
}
