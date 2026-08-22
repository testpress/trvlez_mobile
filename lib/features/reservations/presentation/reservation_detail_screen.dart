import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

/// Detailed view of a single reservation.
///
/// Shows property summary, dates, guest info, status, and action buttons
/// (QR generation, cancel).
class ReservationDetailScreen extends ConsumerStatefulWidget {
  final Reservation reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  ConsumerState<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState
    extends ConsumerState<ReservationDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCancel(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Cancel Reservation?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to cancel this reservation at ${reservation.propertySummary.name}?',
            style: GoogleFonts.cabin(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep it'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Cancel Reservation'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(reservationListProvider.notifier)
          .cancelReservation(reservation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    final reservationsState = ref.watch(reservationListProvider);
    final updated = reservationsState.value
        ?.where((r) => r.id == widget.reservation.id)
        .firstOrNull;
    final reservation = updated ?? widget.reservation;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reservation Details',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property summary
            _buildPropertyCard(colorScheme, reservation),
            const SizedBox(height: 20),

            // Status & Confirmation
            _buildStatusSection(colorScheme, reservation),
            const SizedBox(height: 20),

            // Dates
            _buildInfoCard(
              colorScheme,
              title: 'Stay Details',
              children: [
                _InfoRow(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: dateFormat.format(reservation.checkInDate),
                ),
                _InfoRow(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: dateFormat.format(reservation.checkOutDate),
                ),
                _InfoRow(
                  icon: Icons.nights_stay_outlined,
                  label: 'Duration',
                  value: '${reservation.nights} night(s)',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Guest info
            _buildInfoCard(
              colorScheme,
              title: 'Guest Information',
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Guest Name',
                  value: reservation.guestName,
                ),
                _InfoRow(
                  icon: Icons.group_outlined,
                  label: 'Guests',
                  value: '${reservation.numberOfGuests}',
                ),
                _InfoRow(
                  icon: Icons.bed_outlined,
                  label: 'Rooms',
                  value: reservation.rooms.map((r) => r.roomNumber).join(', '),
                ),
                if (reservation.guestEmail != null)
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: reservation.guestEmail!,
                  ),
                if (reservation.guestPhone != null)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: reservation.guestPhone!,
                  ),
              ],
            ),

            // Special requests
            if (reservation.specialRequests != null &&
                reservation.specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildInfoCard(
                colorScheme,
                title: 'Special Requests',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      reservation.specialRequests!,
                      style: GoogleFonts.cabin(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            _buildActions(colorScheme, reservation),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(ColorScheme colorScheme, Reservation reservation) {
    final property = reservation.propertySummary;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: (property.heroImageUrl ?? '').isNotEmpty
                ? Image.network(
                    property.heroImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.hotel,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (property.locationString.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.locationString,
                              style: GoogleFonts.cabin(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ColorScheme colorScheme, Reservation reservation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _buildStatusIndicator(colorScheme, reservation),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.status.displayLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reservation.confirmationCode,
                  style: GoogleFonts.cabin(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
    ColorScheme colorScheme,
    Reservation reservation,
  ) {
    Color indicatorColor = colorScheme.primary;
    IconData icon = Icons.info;

    switch (reservation.status) {
      case ReservationStatus.pending:
        indicatorColor = const Color(0xFFE65100);
        icon = Icons.hourglass_top;
      case ReservationStatus.confirmed:
        indicatorColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
      case ReservationStatus.checkedIn:
        indicatorColor = colorScheme.primary;
        icon = Icons.door_front_door;
      case ReservationStatus.checkedOut:
        indicatorColor = const Color(0xFF1565C0);
        icon = Icons.flag;
      case ReservationStatus.cancelled:
      case ReservationStatus.noShow:
        indicatorColor = const Color(0xFFC62828);
        icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: indicatorColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: indicatorColor, size: 24),
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme, Reservation reservation) {
    // Determine form button text and behavior based on form status
    String? formButtonText;
    IconData formButtonIcon = Icons.assignment_outlined;
    bool isFormComplete = false;

    if (reservation.propertySummary.requiresPrearrivalForm) {
      if (reservation.formStatus == null || reservation.formStatus == 'draft' || reservation.formStatus == 'resubmission_requested') {
        formButtonText = reservation.formStatus == 'draft' ? 'Continue Pre-Arrival Form' : 'Complete Pre-Arrival Form';
        formButtonIcon = Icons.edit_document;
      } else {
        formButtonText = 'View Pre-Arrival Form';
        formButtonIcon = Icons.assignment_turned_in;
        isFormComplete = true;
      }
    }

    return Column(
      children: [
        // Form Action Button
        if (formButtonText != null) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                context.push(
                  '/reservations/${reservation.id}/form',
                  extra: {'reservation': reservation},
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: isFormComplete ? colorScheme.secondary : colorScheme.primary,
              ),
              icon: Icon(formButtonIcon),
              label: Text(
                formButtonText,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // QR Code button — only for confirmed reservations
        if (reservation.status.canGenerateQr)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => context.push(
                '/reservations/${reservation.id}/qr',
                extra: {'reservation': reservation},
              ),
              icon: const Icon(Icons.qr_code_2),
              label: Text(
                'Generate QR Code',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // Cancel button — only for upcoming reservations
        if (reservation.status.canCancel) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _handleCancel(reservation),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error.withAlpha(128)),
              ),
              child: Text(
                'Cancel Reservation',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Info Row ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.cabin(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cabin(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
