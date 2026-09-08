import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Screen displayed immediately after a successful reservation creation.
///
/// Shows confirmation code, property summary, dates, guest details,
/// and direct actions to view the Check-in QR code or manage the trip.
class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String reservationId;
  final Reservation? reservation;
  final ReservationRepository repository;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  BookingConfirmationScreen({
    super.key,
    String? reservationId,
    this.reservation,
    required this.repository,
    this.isKycVerified,
    this.verificationState,
  }) : reservationId = reservationId ?? reservation?.id ?? '';

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  late Future<Reservation> _reservationFuture;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  void _loadReservation() {
    _reservationFuture = widget.repository.getReservation(widget.reservationId);
  }

  void _retry() {
    setState(() {
      _loadReservation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Reservation>(
        future: _reservationFuture,
        builder: (context, snapshot) {
          final displayReservation = snapshot.data ?? widget.reservation;

          if (displayReservation == null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const _ConfirmationLoadingView();
          }

          if (displayReservation == null && snapshot.hasError) {
            return _ConfirmationErrorView(
              errorMessage: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          if (displayReservation == null) {
            return _ConfirmationErrorView(
              errorMessage: 'Reservation not found.',
              onRetry: _retry,
            );
          }

          final TravelerVerificationState verificationState =
              widget.verificationState ??
                  ref.watch(travelerVerificationStateProvider);
          final isVerified =
              widget.isKycVerified ?? verificationState.isVerified;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SuccessHeader(),
                  const SizedBox(height: 24),
                  _ConfirmationCodeCard(reservation: displayReservation),
                  const SizedBox(height: 20),
                  _PropertySummaryCard(
                    propertySummary: displayReservation.propertySummary,
                  ),
                  const SizedBox(height: 20),
                  _StayDetailsCard(reservation: displayReservation),
                  const SizedBox(height: 20),
                  if (!isVerified) ...[
                    _KycNoticeBanner(
                      verificationState: verificationState,
                      propertyName: displayReservation.propertySummary.name,
                      onVerifyTap: () {
                        if (verificationState.needsOnboarding) {
                          context.push(AppRoutes.onboarding);
                        } else {
                          context.push(AppRoutes.verificationStatus);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  _ActionButtons(
                    reservation: displayReservation,
                    isKycVerified: isVerified,
                    verificationState: verificationState,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Booking Confirmed!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your stay has been officially reserved and confirmed.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ConfirmationCodeCard extends StatelessWidget {
  final Reservation reservation;

  const _ConfirmationCodeCard({required this.reservation});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: reservation.confirmationCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Confirmation code copied to clipboard!',
          style: GoogleFonts.inter(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONFIRMATION CODE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              _StatusBadge(status: reservation.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reservation.confirmationCode,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy_rounded, size: 20),
                tooltip: 'Copy Code',
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            status.displayLabel.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertySummaryCard extends StatelessWidget {
  final ReservationPropertySummary propertySummary;

  const _PropertySummaryCard({required this.propertySummary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 72,
              height: 72,
              color: colorScheme.surfaceContainerHighest,
              child: (propertySummary.heroImageUrl ?? '').isNotEmpty
                  ? Image.network(
                      propertySummary.heroImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.hotel_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    )
                  : Icon(
                      Icons.hotel_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertySummary.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (propertySummary.locationString.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          propertySummary.locationString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StayDetailsCard extends StatelessWidget {
  final Reservation reservation;

  const _StayDetailsCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    final checkInStr = dateFormat.format(reservation.checkInDate);
    final checkOutStr = dateFormat.format(reservation.checkOutDate);
    final nights = reservation.nights > 0 ? reservation.nights : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay Details',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            title: 'Dates',
            subtitle: '$checkInStr – $checkOutStr ($nights ${nights == 1 ? 'Night' : 'Nights'})',
          ),
          const Divider(height: 24),
          _DetailRow(
            icon: Icons.person_outline,
            title: 'Lead Guest',
            subtitle: reservation.guestName,
          ),
          const Divider(height: 24),
          _DetailRow(
            icon: Icons.meeting_room_outlined,
            title: 'Accommodations',
            subtitle:
                '${reservation.numberOfGuests} ${reservation.numberOfGuests == 1 ? 'Guest' : 'Guests'} • ${reservation.rooms.length} ${reservation.rooms.length == 1 ? 'Room' : 'Rooms'}',
          ),
          if (reservation.specialRequests != null &&
              reservation.specialRequests!.isNotEmpty) ...[
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.notes_outlined,
              title: 'Special Requests',
              subtitle: reservation.specialRequests!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Reservation reservation;
  final bool isKycVerified;
  final TravelerVerificationState verificationState;

  const _ActionButtons({
    required this.reservation,
    required this.isKycVerified,
    required this.verificationState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isKycVerified)
          FilledButton.icon(
            onPressed: () {
              context.push(
                AppRoutes.reservationQrPath(reservation.id),
                extra: {'reservation': reservation},
              );
            },
            icon: const Icon(Icons.qr_code_rounded, size: 20),
            label: const Text(
              'View Check-in QR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        else ...[
          FilledButton.icon(
            onPressed: () {
              if (verificationState.needsOnboarding) {
                context.push(AppRoutes.onboarding);
              } else {
                context.push(AppRoutes.verificationStatus);
              }
            },
            icon: const Icon(Icons.shield_outlined, size: 20),
            label: Text(
              verificationState.needsOnboarding
                  ? 'Verify Identity to Check In'
                  : 'Check Verification Status',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              context.push(
                AppRoutes.reservationQrPath(reservation.id),
                extra: {'reservation': reservation},
              );
            },
            icon: const Icon(Icons.qr_code_rounded, size: 20),
            label: const Text(
              'Check-in Pass Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.myTrips),
          icon: const Icon(Icons.luggage_outlined, size: 20),
          label: const Text(
            'View in My Trips',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text(
            'Back to Home',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _KycNoticeBanner extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final String propertyName;
  final VoidCallback onVerifyTap;

  const _KycNoticeBanner({
    required this.verificationState,
    required this.propertyName,
    required this.onVerifyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title;
    final String description;
    final String buttonLabel;
    final Color bannerBg;
    final Color bannerBorder;
    final Color iconColor;
    final IconData icon;

    if (verificationState.needsOnboarding) {
      title = 'Identity Verification Required';
      description =
          'To generate your contactless check-in pass at $propertyName, complete your identity verification before your arrival.';
      buttonLabel = 'Verify Identity Now';
      bannerBg = Colors.amber.shade50;
      bannerBorder = Colors.amber.shade300;
      iconColor = Colors.amber.shade800;
      icon = Icons.shield_outlined;
    } else if (verificationState.isProcessing) {
      title = 'Verification Under Review';
      description =
          'Your identity documents are currently under review. Once approved, your digital check-in QR pass will become active.';
      buttonLabel = 'Check Status';
      bannerBg = Colors.blue.shade50;
      bannerBorder = Colors.blue.shade200;
      iconColor = Colors.blue.shade700;
      icon = Icons.hourglass_top_rounded;
    } else if (verificationState.isFailed) {
      title = 'Verification Unsuccessful';
      description =
          'Your identity verification needs to be re-submitted before a check-in QR code can be generated for this reservation.';
      buttonLabel = 'Re-submit Documents';
      bannerBg = colorScheme.errorContainer.withAlpha(70);
      bannerBorder = colorScheme.error.withAlpha(120);
      iconColor = colorScheme.error;
      icon = Icons.error_outline_rounded;
    } else {
      title = 'Identity Verification Needed';
      description =
          'Complete identity verification to enable digital check-in for this stay.';
      buttonLabel = 'Verify Now';
      bannerBg = Colors.amber.shade50;
      bannerBorder = Colors.amber.shade300;
      iconColor = Colors.amber.shade800;
      icon = Icons.verified_user_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerifyTap,
              icon: Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
              label: Text(
                buttonLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bannerBorder),
                backgroundColor: colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationLoadingView extends StatelessWidget {
  const _ConfirmationLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading booking confirmation...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ConfirmationErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Unable to load confirmation',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
