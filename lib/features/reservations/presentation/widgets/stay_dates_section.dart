import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: TypeScale.bold,
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
                icon: AppIcons.calendar,
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
                icon: AppIcons.calendar,
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
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colors.actionPrimary,
              fontWeight: TypeScale.semiBold,
            ),
          ),
        ],
      ],
    );
  }
}
