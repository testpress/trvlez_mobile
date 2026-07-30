import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.0,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            // Placeholder for image
            Positioned.fill(
              child: property.heroImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        property.heroImageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: colorScheme.surfaceContainer,
                      ),
                    ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, 
                      colorScheme.scrim.withAlpha(180), // 0.7 * 255 ≈ 180
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Favorite button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(50), // 0.2 * 255
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: colorScheme.surface,
                  size: 20,
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '4N/5D',
                      style: GoogleFonts.inter(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.name,
                    style: GoogleFonts.inter(
                      color: colorScheme.surface, 
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: colorScheme.primary, size: 16), 
                      const SizedBox(width: 4),
                      Text(
                        property.rating.toString(),
                        style: GoogleFonts.inter(
                          color: colorScheme.surface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, color: colorScheme.surface.withAlpha(180), size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.locationString,
                          style: GoogleFonts.inter(
                            color: colorScheme.surface.withAlpha(180),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.0,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(13), // 0.05 * 255 ≈ 13
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image placeholder
            property.heroImageUrl.isNotEmpty
                ? Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        property.heroImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceContainer,
                    ),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      property.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.locationString,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withAlpha(153), // 0.6 * 255
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: colorScheme.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          property.rating.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: colorScheme.outline,
                    size: 20,
                  ),
                  Text(
                    '\$${property.pricePerNight.toInt()}/N',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
