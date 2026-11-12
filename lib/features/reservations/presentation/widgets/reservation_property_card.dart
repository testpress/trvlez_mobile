import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Hero image and property details header card for reservation details.
class ReservationPropertyCard extends StatelessWidget {
  final ReservationPropertySummary property;

  const ReservationPropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: shape.radiusSurface.topLeft,
            ),
            child: (property.heroImageUrl ?? '').isNotEmpty
                ? Image.network(
                    property.heroImageUrl!,
                    height: sizes.thumbPhotoLg,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: sizes.thumbPhotoLg,
                      width: double.infinity,
                      color: colors.surfaceSubtle,
                      child: Icon(
                        Icons.hotel,
                        size: sizes.iconHero,
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : Container(
                    height: sizes.thumbPhotoLg,
                    width: double.infinity,
                    color: colors.surfaceSubtle,
                    child: Icon(
                      Icons.hotel,
                      size: sizes.iconHero,
                      color: colors.textSecondary,
                    ),
                  ),
          ),
          Padding(
            padding: space.insetCard,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: context.text.headlineSmall?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (property.locationString.isNotEmpty) ...[
                        SizedBox(height: space.stackText),
                        Row(
                          children: [
                            Icon(
                              AppIcons.mapPin,
                              size: sizes.iconXs,
                              color: colors.textSecondary,
                            ),
                            SizedBox(width: space.inlineMicro),
                            Text(
                              property.locationString,
                              style: context.text.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
