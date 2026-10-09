import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Card showing confirmation code, property summary, and stay details.
class BookingSummaryCard extends StatelessWidget {
  final Reservation reservation;

  const BookingSummaryCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      children: [
        // Confirmation Code Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONFIRMATION CODE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    reservation.confirmationCode,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: colors.actionPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: reservation.confirmationCode),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Confirmation code copied!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Property Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child:
                    (reservation.propertySummary.heroImageUrl ?? '').isNotEmpty
                    ? Image.network(
                        reservation.propertySummary.heroImageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: colors.surfaceSubtle,
                          child: Icon(Icons.hotel, color: colors.textSecondary),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: colors.surfaceSubtle,
                        child: Icon(Icons.hotel, color: colors.textSecondary),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.propertySummary.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (reservation
                        .propertySummary
                        .locationString
                        .isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        reservation.propertySummary.locationString,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stay Details Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Check-in',
                value: dateFormat.format(reservation.checkInDate),
              ),
              const Divider(height: AppSpacing.md),
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'Check-out',
                value: dateFormat.format(reservation.checkOutDate),
              ),
              const Divider(height: AppSpacing.md),
              _DetailRow(
                icon: Icons.people_outline,
                label: 'Guests',
                value:
                    '${reservation.numberOfGuests} Guest${reservation.numberOfGuests > 1 ? 's' : ''}',
              ),
              if (reservation.rooms.isNotEmpty) ...[
                const Divider(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.meeting_room_outlined,
                  label: 'Rooms',
                  value: reservation.rooms
                      .map((r) => r.roomTypeName ?? r.roomNumber)
                      .join(', '),
                ),
              ],
              if (reservation.totalAmount != null) ...[
                const Divider(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.payment_outlined,
                  label: 'Total Amount',
                  value: PriceFormatter.formatTotal(
                    reservation.totalAmount!,
                    currencyCode: reservation.currencyCode,
                  ),
                  isBold: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
