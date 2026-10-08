import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Detailed view of a single reservation.
///
/// Shows property summary, dates, guest info, status, and action buttons
/// (QR generation, cancel). Supports deep linking by reservation ID.
class ReservationDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState
    extends ConsumerState<ReservationDetailScreen> {
  Future<Reservation>? _reservationFuture;

  @override
  void initState() {
    super.initState();
    if (widget.reservation == null) {
      _loadReservation();
    }
  }

  void _loadReservation() {
    final ReservationRepository repo =
        widget.repository ?? ref.read(reservationRepositoryProvider);
    setState(() {
      _reservationFuture = repo.getReservation(widget.reservationId);
    });
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
      try {
        final success = await ref
            .read(reservationListProvider.notifier)
            .cancelReservation(reservation.id);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reservation cancelled successfully.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Failed to cancel reservation. Please try again.',
                ),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel reservation: ${e.toString()}'),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reservation != null) {
      final reservationsState = ref.watch(reservationListProvider);
      final updated = reservationsState.valueOrNull
          ?.where((r) => r.id == widget.reservationId)
          .firstOrNull;
      final reservation = updated ?? widget.reservation!;
      return _buildScaffold(context, reservation);
    }

    return FutureBuilder<Reservation>(
      future: _reservationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
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
                ),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
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
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load reservation',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error?.toString() ?? 'Reservation not found',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _loadReservation,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final reservationsState = ref.watch(reservationListProvider);
        final updated = reservationsState.valueOrNull
            ?.where((r) => r.id == widget.reservationId)
            .firstOrNull;
        final reservation = updated ?? snapshot.data!;
        return _buildScaffold(context, reservation);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Reservation reservation) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

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
      body: RefreshIndicator(
        onRefresh: () async {
          _loadReservation();
          ref.invalidate(reservationListProvider);
          await ref.read(reservationListProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                if (reservation.totalAmount != null)
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total Amount',
                    value: PriceFormatter.formatTotal(
                      reservation.totalAmount!,
                      currencyCode: reservation.currencyCode,
                    ),
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.hotel,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
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
    final verificationState = ref.watch(travelerVerificationStateProvider);
    final isKycVerified = verificationState.isVerified;

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
        if (reservation.status.canGenerateQr) ...[
          if (!isKycVerified) ...[
            _KycNoticeCard(
              verificationState: verificationState,
              onTap: () {
                if (verificationState.needsOnboarding) {
                  context.push(AppRoutes.onboarding);
                } else {
                  context.push(AppRoutes.verificationStatus);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => context.push(
                '/reservations/${reservation.id}/qr',
                extra: {'reservation': reservation},
              ),
              icon: Icon(isKycVerified ? Icons.qr_code_2 : Icons.shield_outlined),
              label: Text(
                isKycVerified
                    ? 'Generate QR Code'
                    : 'Check-in QR (Verification Required)',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],

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

class _KycNoticeCard extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final VoidCallback onTap;

  const _KycNoticeCard({
    required this.verificationState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title;
    final String body;
    final String cta;

    if (verificationState.needsOnboarding) {
      title = 'Identity Verification Required';
      body = 'Complete KYC verification to generate your digital check-in pass.';
      cta = 'Verify Now';
    } else if (verificationState.isProcessing) {
      title = 'Verification Under Review';
      body = 'Your documents are currently being reviewed. Pass will unlock upon approval.';
      cta = 'Check Status';
    } else if (verificationState.isFailed) {
      title = 'Verification Unsuccessful';
      body = 'Please re-submit your documents to unlock check-in.';
      cta = 'Re-submit';
    } else {
      title = 'Verification Needed';
      body = 'Complete identity verification to enable check-in QR.';
      cta = 'Verify';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.amber.shade800, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              cta,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.amber.shade900,
            ),
          ],
        ),
      ),
    );
  }
}
