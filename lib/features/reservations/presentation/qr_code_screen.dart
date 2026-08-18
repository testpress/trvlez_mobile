import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

/// Full-screen QR code display for hotel check-in.
///
/// The traveler taps "Generate QR Code" to request a token, then shows
/// the resulting QR to the front desk scanner.
class QrCodeScreen extends ConsumerStatefulWidget {
  final Reservation reservation;

  const QrCodeScreen({
    super.key,
    required this.reservation,
  });

  @override
  ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _generateToken() {
    ref.read(checkInTokenProvider(widget.reservation.id).notifier).generateCheckInToken();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Check-in QR Code',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Property name summary
              _buildPropertyBanner(colorScheme),
              const SizedBox(height: 32),

              // QR content area
              Expanded(
                child: _buildQrContent(colorScheme),
              ),

              const SizedBox(height: 24),

              // Generate / Regenerate button
              _buildGenerateButton(colorScheme),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.hotel, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reservation.propertySummary.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.reservation.confirmationCode,
                  style: GoogleFonts.cabin(
                    fontSize: 12,
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

  Widget _buildQrContent(ColorScheme colorScheme) {
    final tokenState = ref.watch(checkInTokenProvider(widget.reservation.id));
    final token = tokenState.value;
    final isLoading = tokenState.isLoading;
    final error = tokenState.hasError ? tokenState.error.toString() : null;

    if (isLoading && !tokenState.hasValue) {
      return _buildLoadingState(colorScheme);
    }

    if (error != null) {
      return _buildErrorState(colorScheme, error);
    }

    if (token == null) {
      return _buildInitialState(colorScheme);
    }

    return _buildQrDisplay(colorScheme, token);
  }

  Widget _buildInitialState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to check in?',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap the button below to generate a QR code. Show it to the front desk to check in.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Generating QR code...',
            style: GoogleFonts.cabin(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to generate QR code',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again.',
            style: GoogleFonts.cabin(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplay(ColorScheme colorScheme, CheckInToken token) {
    final now = DateTime.now();
    final isExpired = now.isAfter(token.expiresAt);
    final remaining = token.expiresAt.difference(now);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: token.token,
              version: QrVersions.auto,
              size: 220,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1A1A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Expiry info
          if (isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.error.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_off, size: 16, color: colorScheme.error),
                  const SizedBox(width: 6),
                  Text(
                    'Expired — tap below to regenerate',
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'Valid for ${remaining.inMinutes} min ${remaining.inSeconds % 60} sec',
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Instructions
          Text(
            'Show this QR code to the front desk',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The staff will scan it to verify your identity',
            style: GoogleFonts.cabin(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(ColorScheme colorScheme) {
    final tokenState = ref.watch(checkInTokenProvider(widget.reservation.id));
    final token = tokenState.value;
    final hasToken = token != null;
    final isExpired = hasToken &&
        DateTime.now().isAfter(token.expiresAt);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed:
            tokenState.isLoading ? null : _generateToken,
        icon: Icon(hasToken ? Icons.refresh : Icons.qr_code_2),
        label: Text(
          hasToken
              ? (isExpired ? 'Regenerate QR Code' : 'Generate New QR Code')
              : 'Generate QR Code',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
