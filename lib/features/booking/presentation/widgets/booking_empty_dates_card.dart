import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Card displayed in the rooms section when dates have not yet been selected.
class BookingEmptyDatesCard extends StatelessWidget {
  const BookingEmptyDatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Add dates to see what's available",
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.0,
              fontWeight: TypeScale.bold,
              color: colors.inkTertiary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Rooms and prices depend on the nights chosen, so there is nothing truthful to show here yet.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              color: colors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
