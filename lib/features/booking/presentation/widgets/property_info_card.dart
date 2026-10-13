import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';

/// Card showing property name, location, verified badge, and starting price.
class PropertyInfoCard extends StatelessWidget {
  const PropertyInfoCard({super.key, required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            draft.propertyName,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18.0,
              fontWeight: TypeScale.bold,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(AppIcons.mapPin, size: 14.0, color: colors.inkSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  draft.propertyPlace,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.0,
                    color: colors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: colors.redTint,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.circleCheck,
                  size: 13.0,
                  color: colors.brandPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified partner',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.0,
                    fontWeight: TypeScale.semiBold,
                    color: colors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'from ',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.0,
                    color: colors.inkSecondary,
                  ),
                ),
                Text(
                  PriceFormatter.formatPrice(
                    draft.propertyNightly.toDouble(),
                    currencyCode: draft.currencyCode,
                  ),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18.0,
                    fontWeight: TypeScale.bold,
                    color: colors.brandPrimary,
                  ),
                ),
                Text(
                  ' / night',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.0,
                    color: colors.inkSecondary,
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
