import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

/// Displays the traveler's reservations organized by status tabs.
///
/// Replaces the old "Tickets Coming Soon" placeholder.
class MyTripsScreen extends StatefulWidget {
  final ReservationsNotifier notifier;

  const MyTripsScreen({super.key, required this.notifier});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.notifier.fetchReservations();
    widget.notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            _buildTabBar(colorScheme),
            Expanded(child: _buildTabContent()),
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

  Widget _buildTabBar(ColorScheme colorScheme) {
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
          Tab(text: 'Upcoming (${widget.notifier.upcomingReservations.length})'),
          Tab(text: 'Completed (${widget.notifier.completedReservations.length})'),
          Tab(text: 'Cancelled (${widget.notifier.cancelledReservations.length})'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (widget.notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.notifier.error != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReservationList(widget.notifier.upcomingReservations, 'upcoming'),
        _buildReservationList(widget.notifier.completedReservations, 'completed'),
        _buildReservationList(widget.notifier.cancelledReservations, 'cancelled'),
      ],
    );
  }

  Widget _buildReservationList(
      List<Reservation> reservations, String emptyType) {
    if (reservations.isEmpty) {
      return _buildEmptyState(emptyType);
    }

    return RefreshIndicator(
      onRefresh: widget.notifier.fetchReservations,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _ReservationCard(
          reservation: reservations[index],
          onTap: () => context.push(
            '/reservations/${reservations[index].id}',
            extra: {
              'reservation': reservations[index],
              'notifier': widget.notifier,
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final colorScheme = Theme.of(context).colorScheme;
    final messages = {
      'upcoming': ('No upcoming trips', 'Browse properties and book your next adventure!'),
      'completed': ('No completed trips', 'Your past stays will appear here.'),
      'cancelled': ('No cancelled trips', 'You haven\'t cancelled any reservations.'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load trips',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: widget.notifier.fetchReservations,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                      _StatusBadge(status: reservation.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (reservation.propertySummary.locationString.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: colorScheme.onSurfaceVariant),
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
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: colorScheme.primary),
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
                      Icon(Icons.confirmation_number_outlined,
                          size: 14, color: colorScheme.primary),
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
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colorScheme),
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

// ─── Status Badge ──────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _statusColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fgColor,
        ),
      ),
    );
  }

  (Color, Color) _statusColors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ReservationStatus.pending:
        return (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
        );
      case ReservationStatus.confirmed:
        return (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        );
      case ReservationStatus.checkedIn:
        return (
          colorScheme.primary.withAlpha(26),
          colorScheme.primary,
        );
      case ReservationStatus.checkedOut:
        return (
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
        );
      case ReservationStatus.cancelled:
      case ReservationStatus.noShow:
        return (
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828),
        );
    }
  }
}
