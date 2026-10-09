import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';

class PropertiesListingScreen extends ConsumerStatefulWidget {
  const PropertiesListingScreen({super.key});

  @override
  ConsumerState<PropertiesListingScreen> createState() =>
      _PropertiesListingScreenState();
}

class _PropertiesListingScreenState
    extends ConsumerState<PropertiesListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  int _selectedCategoryIndex = 0;

  static const List<String> _categories = [
    'All',
    'Hotels',
    'Resorts',
    'Villas',
    'Boutique',
  ];

  static const Map<String, String?> _categoryToType = {
    'All': null,
    'Hotels': 'hotel',
    'Resorts': 'resort',
    'Villas': 'villa',
    'Boutique': 'boutique',
  };

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      ref.read(propertiesProvider.notifier).search(query);
    });
  }

  void _onSearchSubmitted(String query) {
    _debounceTimer?.cancel();
    ref.read(propertiesProvider.notifier).search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(propertiesProvider.notifier).search('');
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    final selectedCategory = _categories[index];
    final propertyType = _categoryToType[selectedCategory];
    ref.read(propertiesProvider.notifier).filterByPropertyType(propertyType);
  }

  void _resetAllFilters() {
    _searchController.clear();
    setState(() => _selectedCategoryIndex = 0);
    ref
        .read(propertiesProvider.notifier)
        .fetchProperties(search: '', propertyType: 'all');
  }

  Future<void> _onRefresh() async {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final propertyType = _categoryToType[selectedCategory];
    await ref
        .read(propertiesProvider.notifier)
        .fetchProperties(
          search: _searchController.text,
          propertyType: propertyType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertiesState = ref.watch(propertiesProvider);
    final properties = propertiesState.value ?? [];
    final isLoading = propertiesState.isLoading;
    final error = propertiesState.error;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _PropertiesHeader(),
                    const SizedBox(height: 20),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      onClear: _clearSearch,
                    ),
                    const SizedBox(height: 20),
                    _CategorySelector(
                      categories: _categories,
                      selectedIndex: _selectedCategoryIndex,
                      onSelected: _onCategorySelected,
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
              if (isLoading && properties.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingView(),
                )
              else if (error != null && properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    error: error.toString(),
                    onRetry: () =>
                        ref.read(propertiesProvider.notifier).fetchProperties(),
                  ),
                )
              else if (properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyView(onResetFilters: _resetAllFilters),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PopularSection(properties: properties.take(5).toList()),
                      const SizedBox(height: 32),
                      _RecommendedSection(
                        properties: properties.length > 5
                            ? properties.skip(5).toList()
                            : properties,
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
            ],
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                text: 'Trvl',
                style: GoogleFonts.inter(
                  fontSize: 24,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Explore Stays',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.inter(color: colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          hintText: 'Search properties or cities',
          hintStyle: GoogleFonts.inter(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          border: InputBorder.none,
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: widget.onClear,
                )
              : null,
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
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: GoogleFonts.inter(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

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

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

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

class _EmptyView extends StatelessWidget {
  final VoidCallback onResetFilters;

  const _EmptyView({required this.onResetFilters});

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
