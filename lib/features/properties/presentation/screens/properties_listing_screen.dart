import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';

/// Screen displaying the curated and searchable ezStays properties catalog.
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
  final Set<String> _savedPropertyIds = {};

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
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(propertiesProvider.notifier).search(query);
    });
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
    final colors = context.colors;
    final propertiesState = ref.watch(propertiesProvider);
    final properties = propertiesState.valueOrNull ?? [];
    final isLoading = propertiesState.isLoading;
    final error = propertiesState.error;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (canPop) ...[
                      Semantics(
                        button: true,
                        label: 'Back',
                        child: InkWell(
                          borderRadius: AppRadius.fullRadius,
                          onTap: () => Navigator.maybePop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              AppIcons.arrowLeft,
                              size: 20,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    EzWord(
                      rest: 'Stays',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: TypeScale.bold,
                        letterSpacing: -0.3,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Search box
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.page,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.search,
                        size: 16,
                        color: colors.brandPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          cursorColor: colors.brandPrimary,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search properties or cities',
                            hintStyle: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Semantics(
                          button: true,
                          label: 'Clear search',
                          child: InkWell(
                            onTap: _clearSearch,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                AppIcons.circleX,
                                size: 16,
                                color: colors.inkTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Category filter chips
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(index),
                        selectedColor: colors.brandPrimary,
                        backgroundColor: colors.surface,
                        labelStyle: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? TypeScale.bold
                              : TypeScale.medium,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? colors.brandPrimary
                              : colors.cardBorderSoft,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.fullRadius,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Catalog ─────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: isLoading && properties.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : error != null && properties.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.circleX,
                              size: 40,
                              color: colors.brandPrimary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Unable to load properties',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 16,
                                fontWeight: TypeScale.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(propertiesProvider.notifier)
                                  .fetchProperties(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.brandPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.fullRadius,
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : properties.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.search,
                              size: 36,
                              color: colors.inkTertiary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Nothing matches that',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 15,
                                fontWeight: TypeScale.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search terms or filters.',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: _resetAllFilters,
                              child: Text(
                                'Reset filters',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  fontWeight: TypeScale.bold,
                                  color: colors.brandPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Featured Stays Horizontal Rail
                          Text(
                            'Popular now',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: TypeScale.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            height: 226,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: properties.length,
                              itemBuilder: (context, index) {
                                final property = properties[index];
                                return PropertyCard(
                                  property: property,
                                  isHorizontal: true,
                                  isSaved: _savedPropertyIds.contains(
                                    property.id,
                                  ),
                                  onSaveToggle: () {
                                    setState(() {
                                      if (_savedPropertyIds.contains(
                                        property.id,
                                      )) {
                                        _savedPropertyIds.remove(property.id);
                                      } else {
                                        _savedPropertyIds.add(property.id);
                                      }
                                    });
                                  },
                                  onTap: () => context.push(
                                    AppRoutes.propertyDetailPath(property.id),
                                    extra: property,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // All properties vertical list
                          Text(
                            'All Stays',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: TypeScale.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...properties.map(
                            (property) => PropertyCard(
                              property: property,
                              isHorizontal: false,
                              isSaved: _savedPropertyIds.contains(property.id),
                              onSaveToggle: () {
                                setState(() {
                                  if (_savedPropertyIds.contains(property.id)) {
                                    _savedPropertyIds.remove(property.id);
                                  } else {
                                    _savedPropertyIds.add(property.id);
                                  }
                                });
                              },
                              onTap: () => context.push(
                                AppRoutes.propertyDetailPath(property.id),
                                extra: property,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
