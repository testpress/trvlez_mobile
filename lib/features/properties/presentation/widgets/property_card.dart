import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Reusable property card with horizontal (popular) and vertical (recommended) variants.
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final bool isHorizontal; // True for "Popular" list, false for "Recommended"

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isHorizontal = false,
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
        : (property.amenities.isNotEmpty
              ? property.amenities.first.toUpperCase()
              : 'VERIFIED');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.0,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.card,
          color: colors.surfaceSubtle,
        ),
        child: Stack(
          children: [
            // Image with fallback
            Positioned.fill(
              child: ClipRRect(
                borderRadius: AppRadius.card,
                child: property.heroImageUrl.isNotEmpty
                    ? Image.network(
                        property.heroImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(colors),
                      )
                    : _buildFallbackImage(colors),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.card,
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      colors.textPrimary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Badge (Property Type / Amenity)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.actionPrimary,
                  borderRadius: AppRadius.input,
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.nunito(
                    color: colors.textOnAction,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: GoogleFonts.nunito(
                      color: colors.textOnAction,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colors.textOnAction.withValues(alpha: 0.8),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.locationString.isNotEmpty
                              ? property.locationString
                              : 'Location available on detail',
                          style: GoogleFonts.cabin(
                            color: colors.textOnAction.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (property.amenities.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      property.amenities.take(2).join(' • '),
                      style: GoogleFonts.cabin(
                        color: colors.textOnAction.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (property.pricePerNight != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${property.pricePerNight!.toInt()} / night',
                      style: GoogleFonts.nunito(
                        color: colors.textOnAction,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.0,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surface,
          border: Border.all(color: colors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: AppRadius.cardSm,
                child: property.heroImageUrl.isNotEmpty
                    ? Image.network(
                        property.heroImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(colors),
                      )
                    : _buildFallbackImage(colors),
              ),
            ),
            // Property details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      property.name,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.locationString.isNotEmpty
                          ? property.locationString
                          : 'Location available on detail',
                      style: GoogleFonts.cabin(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (property.amenities.isNotEmpty)
                          Expanded(
                            child: Text(
                              property.amenities.take(2).join(' • '),
                              style: GoogleFonts.cabin(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colors.actionPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else if (property.shortDescription.isNotEmpty)
                          Expanded(
                            child: Text(
                              property.shortDescription,
                              style: GoogleFonts.cabin(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),
                        if (property.pricePerNight != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${property.pricePerNight!.toInt()}/nt',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.actionPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // View Details arrow
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colors.actionPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage(AppColors colors) {
    return Container(
      decoration: BoxDecoration(color: colors.surfaceSubtle),
      child: Center(
        child: Icon(
          Icons.hotel_outlined,
          color: colors.actionPrimary,
          size: 32,
        ),
      ),
    );
  }
}
