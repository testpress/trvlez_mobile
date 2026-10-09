import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Compact property header card shown at top of the booking flow.
class BookingPropertyHeaderCard extends StatelessWidget {
  final Property property;

  const BookingPropertyHeaderCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdRadius,
            child: property.heroImageUrl.isNotEmpty
                ? Image.network(
                    property.heroImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: colors.surfaceSubtle,
                      child: Icon(Icons.hotel, color: colors.textSecondary),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: colors.surfaceSubtle,
                    child: Icon(Icons.hotel, color: colors.textSecondary),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  property.locationString,
                  style: GoogleFonts.cabin(
                    fontSize: 13,
                    color: colors.textSecondary,
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
