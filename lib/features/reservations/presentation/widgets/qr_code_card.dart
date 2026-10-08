import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Card containing QR code display, live countdown, and check-in instructions.
class QrCodeCard extends StatelessWidget {
  final CheckInToken token;
  final bool isExpired;

  const QrCodeCard({
    super.key,
    required this.token,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final remaining = token.expiresAt.difference(now);
    final isStillValid = !isExpired && remaining > Duration.zero;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withAlpha(20),
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
            const SizedBox(height: AppSpacing.lg),
            if (isStillValid)
              _CountdownBadge(remaining: remaining)
            else
              const _ExpiredBadge(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Show this QR to the front desk',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Hotel staff will scan to confirm check-in',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.textSecondary,
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
    final colors = context.colors;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.feedbackSuccess.withAlpha(25),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: colors.feedbackSuccess.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: colors.feedbackSuccess),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Valid for $timeString',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.feedbackSuccess,
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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.feedbackError.withAlpha(25),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: colors.feedbackError.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_outlined, size: 16, color: colors.feedbackError),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Token Expired',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.feedbackError,
            ),
          ),
        ],
      ),
    );
  }
}
