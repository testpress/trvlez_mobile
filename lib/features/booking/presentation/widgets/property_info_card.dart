import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
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
          SizedBox(height: space.stackText),
          Row(
            children: [
              Icon(
                AppIcons.mapPin,
                size: sizes.iconXs,
                color: colors.inkSecondary,
              ),
              SizedBox(width: space.inlineMicro),
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
          SizedBox(height: space.stackItem),
          Container(
            padding: space.insetTag,
            decoration: BoxDecoration(
              color: colors.redTint,
              borderRadius: shape.radiusPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.circleCheck,
                  size: sizes.iconXs,
                  color: colors.brandPrimary,
                ),
                SizedBox(width: space.inlineMicro),
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
            margin: EdgeInsets.only(top: space.stackFormField),
            padding: EdgeInsets.only(top: space.stackItem),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.line, width: shape.borderDefault),
              ),
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
