import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Reusable property card with horizontal (popular) and vertical (recommended) variants.
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final bool isHorizontal;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isHorizontal = false,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildPopularCard(context);
    } else {
      return _buildRecommendedCard(context);
    }
  }

  Widget _buildPopularCard(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final badgeLabel =
        (property.propertyType != null && property.propertyType!.isNotEmpty)
        ? property.propertyType!.toUpperCase()
        : 'HOTEL';

    return Semantics(
      button: true,
      label:
          '${property.name}, £${property.pricePerNight?.toInt() ?? 120} per night',
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          width: sizes.cardWidthCarousel,
          margin: EdgeInsets.only(right: space.inlineItem),
          decoration: BoxDecoration(
            borderRadius: shape.radiusSurface,
            color: colors.surface,
            border: Border.all(
              color: colors.cardBorderSoft,
              width: shape.borderDefault,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo area with heart and badge
              Stack(
                children: [
                  PhotoBox(
                    height: sizes.thumbPhotoMd,
                    imageUrl: property.heroImageUrl,
                    borderRadius: BorderRadius.vertical(
                      top: shape.radiusSurface.topLeft,
                    ),
                    iconSize: sizes.iconLg,
                  ),
                  Positioned(
                    top: space.stackItem,
                    left: space.inlineIconLabel,
                    child: Container(
                      padding: space.insetTag,
                      decoration: BoxDecoration(
                        color: colors.brandPrimary,
                        borderRadius: shape.radiusPill,
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: colors.textOnAction,
                          fontSize: 9,
                          fontWeight: TypeScale.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: shape.strokeProgress,
                    right: shape.strokeProgress,
                    child: HeartButton(
                      saved: isSaved,
                      onPhoto: true,
                      size: sizes.iconLg,
                      onTap: onSaveToggle,
                    ),
                  ),
                ],
              ),
              // Body info
              Padding(
                padding: space.insetCardCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: shape.strokeProgress),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: sizes.iconXs,
                          color: colors.inkTertiary,
                        ),
                        SizedBox(width: space.inlineMicro),
                        Expanded(
                          child: Text(
                            property.locationString,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: space.stackTight),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '£${property.pricePerNight?.toInt() ?? 120}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: TypeScale.extraBold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(width: shape.strokeProgress),
                        Text(
                          '/night',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (property.rating != null) ...[
                          Icon(
                            AppIcons.starFilled,
                            size: sizes.iconXs,
                            color: colors.brandPrimary,
                          ),
                          SizedBox(width: shape.strokeProgress),
                          Text(
                            property.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: TypeScale.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildRecommendedCard(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label:
          '${property.name}, £${property.pricePerNight?.toInt() ?? 120} per night',
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: space.stackFormField),
          padding: space.insetCardCompact,
          decoration: BoxDecoration(
            borderRadius: shape.radiusSurface,
            color: colors.surface,
            border: Border.all(
              color: colors.cardBorderSoft,
              width: shape.borderDefault,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              PhotoBox(
                width: sizes.thumbPhotoSm,
                height: sizes.thumbPhotoSm,
                imageUrl: property.heroImageUrl,
                borderRadius: shape.radiusControl,
                iconSize: sizes.iconDefault,
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: space.inlineMicro),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: sizes.iconXs,
                          color: colors.inkTertiary,
                        ),
                        SizedBox(width: space.inlineMicro),
                        Expanded(
                          child: Text(
                            property.locationString,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: space.stackTight),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '£${property.pricePerNight?.toInt() ?? 120}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: TypeScale.extraBold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(width: shape.strokeProgress),
                        Text(
                          '/night',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        HeartButton(
                          saved: isSaved,
                          size: sizes.iconLg,
                          onTap: onSaveToggle,
                        ),
                      ],
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
