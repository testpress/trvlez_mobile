import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/date_picker_tile.dart';

/// Form section for selecting stay check-in and check-out dates.
class StayDatesSection extends StatelessWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final VoidCallback onSelectCheckIn;
  final VoidCallback onSelectCheckOut;

  const StayDatesSection({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
    required this.onSelectCheckIn,
    required this.onSelectCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stay Dates',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: DatePickerTile(
                label: 'Check-in',
                value: checkInDate != null
                    ? dateFormat.format(checkInDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: Theme.of(context).colorScheme,
                onTap: onSelectCheckIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DatePickerTile(
                label: 'Check-out',
                value: checkOutDate != null
                    ? dateFormat.format(checkOutDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: Theme.of(context).colorScheme,
                onTap: onSelectCheckOut,
              ),
            ),
          ],
        ),
        if (checkInDate != null && checkOutDate != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${checkOutDate!.difference(checkInDate!).inDays} night(s)',
            style: GoogleFonts.cabin(
              fontSize: 13,
              color: colors.actionPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
