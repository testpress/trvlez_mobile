import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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

    final badgeLabel =
        (property.propertyType != null && property.propertyType!.isNotEmpty)
        ? property.propertyType!.toUpperCase()
        : 'HOTEL';

    return Semantics(
      button: true,
      label:
          '${property.name}, £${property.pricePerNight?.toInt() ?? 120} per night',
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: onTap,
        child: Container(
          width: 220.0,
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            color: colors.surface,
            border: Border.all(color: colors.cardBorderSoft),
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
                    height: 125,
                    imageUrl: property.heroImageUrl,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    iconSize: 28,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandPrimary,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: TypeScale.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: HeartButton(
                      saved: isSaved,
                      onPhoto: true,
                      size: 28,
                      onTap: onSaveToggle,
                    ),
                  ),
                ],
              ),
              // Body info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: 11,
                          color: colors.inkTertiary,
                        ),
                        const SizedBox(width: 3),
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
                    const SizedBox(height: 6),
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
                        const SizedBox(width: 2),
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
                            size: 11,
                            color: colors.brandPrimary,
                          ),
                          const SizedBox(width: 2),
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

    return Semantics(
      button: true,
      label:
          '${property.name}, £${property.pricePerNight?.toInt() ?? 120} per night',
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            color: colors.surface,
            border: Border.all(color: colors.cardBorderSoft),
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
                width: 90,
                height: 90,
                imageUrl: property.heroImageUrl,
                borderRadius: AppRadius.mdRadius,
                iconSize: 24,
              ),
              const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: 11,
                          color: colors.inkTertiary,
                        ),
                        const SizedBox(width: 3),
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
                    const SizedBox(height: 6),
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
                        const SizedBox(width: 2),
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
                          size: 26,
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
