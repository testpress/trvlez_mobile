import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Full-screen QR code display for hotel check-in.
///
/// Automatically generates or retrieves a check-in token on screen load,
/// ticks a live countdown timer, and allows easy regeneration upon expiry.
/// If traveler is not KYC verified, renders identity verification guidance.
class QrCodeScreen extends ConsumerStatefulWidget {
  final String reservationId;
  final Reservation? reservation;
  final ReservationRepository? repository;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  QrCodeScreen({
    super.key,
    String? reservationId,
    this.reservation,
    this.repository,
    this.isKycVerified,
    this.verificationState,
  }) : reservationId = reservationId ?? reservation?.id ?? '';

  @override
  ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  Timer? _countdownTimer;
  Future<Reservation>? _reservationFuture;

  @override
  void initState() {
    super.initState();
    if (widget.reservation == null) {
      _loadReservation();
    }

    // Live countdown ticker
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Auto-generate token on load if none exists or if expired
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateTokenIfNeeded();
    });
  }

  void _loadReservation() {
    final ReservationRepository repo =
        widget.repository ?? ref.read(reservationRepositoryProvider);
    _reservationFuture = repo.getReservation(widget.reservationId);
  }

  void _retryLoadReservation() {
    setState(() {
      _loadReservation();
    });
  }

  void _autoGenerateTokenIfNeeded() {
    final TravelerVerificationState verificationState =
        widget.verificationState ?? ref.read(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verificationState.isVerified;
    if (!isVerified) return;

    final tokenState = ref.read(checkInTokenProvider(widget.reservationId));
    final token = tokenState.value;
    if (token == null || DateTime.now().isAfter(token.expiresAt)) {
      _generateToken();
    }
  }

  void _generateToken() {
    final TravelerVerificationState verificationState =
        widget.verificationState ?? ref.read(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verificationState.isVerified;
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Identity verification (KYC) is required to generate a check-in pass.',
          ),
          action: SnackBarAction(
            label: 'Verify Now',
            onPressed: () {
              if (verificationState.needsOnboarding) {
                context.push(AppRoutes.onboarding);
              } else {
                context.push(AppRoutes.verificationStatus);
              }
            },
          ),
        ),
      );
      return;
    }

    ref
        .read(checkInTokenProvider(widget.reservationId).notifier)
        .generateCheckInToken();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokenState = ref.watch(checkInTokenProvider(widget.reservationId));

    if (widget.reservation != null) {
      return _buildScaffold(context, colorScheme, widget.reservation!, tokenState);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Check-in QR Code',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Reservation>(
        future: _reservationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _QrLoadingView(
              message: 'Loading reservation details...',
            );
          }

          if (snapshot.hasError) {
            return _QrErrorView(
              errorMessage: snapshot.error.toString(),
              onRetry: _retryLoadReservation,
            );
          }

          if (!snapshot.hasData) {
            return _QrErrorView(
              errorMessage: 'Reservation not found.',
              onRetry: _retryLoadReservation,
            );
          }

          return _buildBody(context, colorScheme, snapshot.data!, tokenState);
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ColorScheme colorScheme,
    Reservation reservation,
    AsyncValue<CheckInToken?> tokenState,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Check-in QR Code',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _buildBody(context, colorScheme, reservation, tokenState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colorScheme,
    Reservation reservation,
    AsyncValue<CheckInToken?> tokenState,
  ) {
    final TravelerVerificationState verificationState =
        widget.verificationState ?? ref.watch(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verificationState.isVerified;

    final token = tokenState.value;
    final isLoading = tokenState.isLoading;
    final isExpired = token != null && DateTime.now().isAfter(token.expiresAt);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _PropertyHeader(reservation: reservation),
            const SizedBox(height: 24),
            Expanded(
              child: isVerified
                  ? _buildQrSection(colorScheme, tokenState, token, isExpired)
                  : _KycVerificationRequiredView(
                      verificationState: verificationState,
                      onActionPressed: () =>
                          _handleKycAction(context, verificationState),
                    ),
            ),
            const SizedBox(height: 20),
            if (isVerified)
              _GenerateActionButton(
                isLoading: isLoading,
                hasToken: token != null,
                isExpired: isExpired,
                onPressed: _generateToken,
              )
            else
              _KycActionButton(
                verificationState: verificationState,
                onPressed: () => _handleKycAction(context, verificationState),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleKycAction(
    BuildContext context,
    TravelerVerificationState verificationState,
  ) {
    if (verificationState.needsOnboarding) {
      context.push(AppRoutes.onboarding);
    } else {
      context.push(AppRoutes.verificationStatus);
    }
  }

  Widget _buildQrSection(
    ColorScheme colorScheme,
    AsyncValue<CheckInToken?> tokenState,
    CheckInToken? token,
    bool isExpired,
  ) {
    if (tokenState.isLoading && !tokenState.hasValue) {
      return const _QrLoadingView(message: 'Generating secure QR token...');
    }

    if (tokenState.hasError && token == null) {
      return _QrErrorView(
        errorMessage: tokenState.error.toString(),
        onRetry: _generateToken,
      );
    }

    if (token == null) {
      return _InitialQrView(onGenerate: _generateToken);
    }

    return _QrDisplayView(
      token: token,
      isExpired: isExpired,
    );
  }
}

class _PropertyHeader extends StatelessWidget {
  final Reservation reservation;

  const _PropertyHeader({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.hotel_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.propertySummary.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reservation.confirmationCode,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

class _QrDisplayView extends StatelessWidget {
  final CheckInToken token;
  final bool isExpired;

  const _QrDisplayView({
    required this.token,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final remaining = token.expiresAt.difference(now);
    final isStillValid = !isExpired && remaining > Duration.zero;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Opacity(
                opacity: isStillValid ? 1.0 : 0.25,
                child: QrImageView(
                  data: token.token,
                  version: QrVersions.auto,
                  size: 210,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF111827),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Countdown or Expired Badge
            if (isStillValid)
              _CountdownBadge(remaining: remaining)
            else
              const _ExpiredBadge(),

            const SizedBox(height: 16),
            Text(
              'Show this QR to the front desk',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hotel staff will scan to confirm check-in',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final Duration remaining;

  const _CountdownBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final text = minutes > 0
        ? '$minutes min ${seconds.toString().padLeft(2, '0')} sec remaining'
        : '$seconds sec remaining';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 16,
            color: Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withAlpha(150)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_outlined, size: 16, color: colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'Token expired • Tap below to regenerate',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateActionButton extends StatelessWidget {
  final bool isLoading;
  final bool hasToken;
  final bool isExpired;
  final VoidCallback onPressed;

  const _GenerateActionButton({
    required this.isLoading,
    required this.hasToken,
    required this.isExpired,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;

    if (isExpired) {
      label = 'Regenerate QR Code';
      icon = Icons.refresh_rounded;
    } else if (hasToken) {
      label = 'Generate New QR Code';
      icon = Icons.refresh_rounded;
    } else {
      label = 'Generate QR Code';
      icon = Icons.qr_code_2_rounded;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          isLoading ? 'Generating Token...' : label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _InitialQrView extends StatelessWidget {
  final VoidCallback onGenerate;

  const _InitialQrView({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 56,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to check in?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Generate a digital pass to check in smoothly at the front desk.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrLoadingView extends StatelessWidget {
  final String message;

  const _QrLoadingView({required this.message});

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
            message,
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

class _QrErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _QrErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Unable to generate QR code',
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
            const SizedBox(height: 20),
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

class _KycVerificationRequiredView extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final VoidCallback onActionPressed;

  const _KycVerificationRequiredView({
    required this.verificationState,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String statusLabel;
    final Color statusColor;
    final Color statusBg;
    final String statusDescription;
    final IconData statusIcon;

    if (verificationState.needsOnboarding) {
      statusLabel = 'Identity Verification Required';
      statusColor = Colors.amber.shade800;
      statusBg = Colors.amber.shade50;
      statusIcon = Icons.shield_outlined;
      statusDescription =
          'To generate a check-in QR pass and access your room, you must complete your passport and identity verification.';
    } else if (verificationState.isProcessing) {
      statusLabel = 'Verification Under Review';
      statusColor = Colors.blue.shade700;
      statusBg = Colors.blue.shade50;
      statusIcon = Icons.hourglass_top_rounded;
      statusDescription =
          'Your submitted documents are currently being verified. Your check-in pass will automatically be unlocked once approved.';
    } else if (verificationState.isFailed) {
      statusLabel = 'Verification Unsuccessful';
      statusColor = colorScheme.error;
      statusBg = colorScheme.errorContainer.withAlpha(80);
      statusIcon = Icons.error_outline_rounded;
      statusDescription =
          'Your identity verification could not be approved. Please review the guidance and re-submit your documents.';
    } else {
      statusLabel = 'Verification Required';
      statusColor = Colors.amber.shade800;
      statusBg = Colors.amber.shade50;
      statusIcon = Icons.verified_user_outlined;
      statusDescription =
          'Identity verification is required before a digital check-in QR code can be generated.';
    }

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  size: 48,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                statusLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                statusDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      'Check-in pass is locked until verified',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KycActionButton extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final VoidCallback onPressed;

  const _KycActionButton({
    required this.verificationState,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;

    if (verificationState.needsOnboarding) {
      label = 'Complete Identity Verification';
      icon = Icons.verified_user_outlined;
    } else if (verificationState.isProcessing) {
      label = 'Check Verification Status';
      icon = Icons.hourglass_top_rounded;
    } else if (verificationState.isFailed) {
      label = 'Review & Re-submit Documents';
      icon = Icons.refresh_rounded;
    } else {
      label = 'Verify Identity to Check In';
      icon = Icons.shield_outlined;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0D7377),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
