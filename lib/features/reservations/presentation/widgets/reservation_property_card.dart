import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Hero image and property details header card for reservation details.
class ReservationPropertyCard extends StatelessWidget {
  final ReservationPropertySummary property;

  const ReservationPropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: (property.heroImageUrl ?? '').isNotEmpty
                ? Image.network(
                    property.heroImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      width: double.infinity,
                      color: colors.surfaceSubtle,
                      child: Icon(
                        Icons.hotel,
                        size: 48,
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: colors.surfaceSubtle,
                    child: Icon(
                      Icons.hotel,
                      size: 48,
                      color: colors.textSecondary,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (property.locationString.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              property.locationString,
                              style: GoogleFonts.cabin(
                                fontSize: 13,
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
