import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';

/// Horizontal carousel section for featured properties.
class PropertiesPopularSection extends StatelessWidget {
  final List<Property> properties;

  const PropertiesPopularSection({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Properties',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                isHorizontal: true,
                onTap: () {
                  context.push(
                    AppRoutes.propertyDetailPath(property.id),
                    extra: property,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Vertical listing section for all available properties.
class PropertiesRecommendedSection extends StatelessWidget {
  final List<Property> properties;

  const PropertiesRecommendedSection({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Available Properties',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return PropertyCard(
              property: property,
              isHorizontal: false,
              onTap: () {
                context.push(
                  AppRoutes.propertyDetailPath(property.id),
                  extra: property,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Centered loading indicator for property discovery.
class PropertiesLoadingView extends StatelessWidget {
  const PropertiesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Discovering bookable properties...',
            style: GoogleFonts.inter(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state view with retry action button.
class PropertiesErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const PropertiesErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load properties',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty search results state view with reset filters action.
class PropertiesEmptyView extends StatelessWidget {
  final VoidCallback onResetFilters;

  const PropertiesEmptyView({super.key, required this.onResetFilters});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withAlpha(160),
            ),
            const SizedBox(height: 16),
            Text(
              'No properties match your criteria',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different keyword or select another category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
