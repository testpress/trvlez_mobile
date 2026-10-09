import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/properties_listing_sections.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/properties_search_header.dart';

/// Screen displaying the curated and searchable properties catalog.
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
                    const PropertiesHeader(),
                    const SizedBox(height: 20),
                    PropertiesSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      onClear: _clearSearch,
                    ),
                    const SizedBox(height: 20),
                    PropertyCategorySelector(
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
                  child: PropertiesLoadingView(),
                )
              else if (error != null && properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: PropertiesErrorView(
                    error: error.toString(),
                    onRetry: () =>
                        ref.read(propertiesProvider.notifier).fetchProperties(),
                  ),
                )
              else if (properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: PropertiesEmptyView(onResetFilters: _resetAllFilters),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      PropertiesPopularSection(
                        properties: properties.take(5).toList(),
                      ),
                      const SizedBox(height: 32),
                      PropertiesRecommendedSection(
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
