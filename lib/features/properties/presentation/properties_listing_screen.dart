import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';
import 'package:trvlez_mobile/app/routes.dart';

class PropertiesListingScreen extends StatefulWidget {
  final PropertiesNotifier notifier;

  const PropertiesListingScreen({super.key, required this.notifier});

  @override
  State<PropertiesListingScreen> createState() => _PropertiesListingScreenState();
}

class _PropertiesListingScreenState extends State<PropertiesListingScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> categories = ['Location', 'Hotels', 'Food', 'Adventure'];

  @override
  void initState() {
    super.initState();
    widget.notifier.fetchProperties();
    widget.notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final properties = widget.notifier.properties;

    // Slice properties for UI sections
    final popularProperties = properties.take(5).toList();
    final recommendedProperties = properties.skip(5).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: widget.notifier.isLoading && properties.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : widget.notifier.error != null && properties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${widget.notifier.error}', style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: widget.notifier.fetchProperties,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: widget.notifier.fetchProperties,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PropertiesHeader(),
                        const SizedBox(height: 24),
                        const _SearchBar(),
                        const SizedBox(height: 24),
                        _CategorySelector(
                          categories: categories,
                          selectedIndex: _selectedCategoryIndex,
                          onSelected: _onCategorySelected,
                        ),
                        const SizedBox(height: 32),
                        _PopularSection(properties: popularProperties),
                        const SizedBox(height: 32),
                        _RecommendedSection(properties: recommendedProperties),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PropertiesHeader extends StatelessWidget {
  const _PropertiesHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                text: 'Trvl',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'Ez',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(13), // 0.05 * 255 ≈ 13
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                'Aspen, USA',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 16, color: colorScheme.onSurfaceVariant),
            ],
          ),
        )
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          hintText: 'Find things to do',
          hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: GoogleFonts.inter(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PopularSection extends StatelessWidget {
  final List<Property> properties;

  const _PopularSection({required this.properties});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'See all',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: properties.isEmpty
              ? Center(
                  child: Text(
                    'No popular properties available.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return PropertyCard(
                      property: property,
                      isHorizontal: true,
                      onTap: () {
                        context.push(AppRoutes.propertyDetailPath(property.id), extra: property);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  final List<Property> properties;

  const _RecommendedSection({required this.properties});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        properties.isEmpty
            ? Center(
                child: Text(
                  'No recommended properties available.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return PropertyCard(
                    property: property,
                    isHorizontal: false,
                    onTap: () {
                      context.push(AppRoutes.propertyDetailPath(property.id), extra: property);
                    },
                  );
                },
              ),
      ],
    );
  }
}
