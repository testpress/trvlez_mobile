import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Card displayed in the rooms section when dates have not yet been selected.
class BookingEmptyDatesCard extends StatelessWidget {
  const BookingEmptyDatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: space.insetCard.left),
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line, width: shape.borderDefault),
        borderRadius: shape.radiusSurface,
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
          SizedBox(height: space.stackText),
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
