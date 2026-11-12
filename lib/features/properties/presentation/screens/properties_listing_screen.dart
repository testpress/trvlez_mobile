import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final propertiesState = ref.watch(propertiesProvider);
    final properties = propertiesState.valueOrNull ?? [];
    final isLoading = propertiesState.isLoading;
    final error = propertiesState.error;

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
                    Semantics(
                      button: true,
                      label: 'Back',
                      child: InkWell(
                        borderRadius: shape.radiusPill,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(space.inlineMicro),
                          child: Icon(
                            AppIcons.arrowLeft,
                            size: sizes.iconMd,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: space.inlineIconLabel),
                    EzWord(
                      rest: 'Stays',
                      style: context.text.headlineMedium?.copyWith(
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: space.stackFormField),
                // Search box
                Container(
                  height: sizes.controlMd,
                  padding: EdgeInsets.symmetric(
                    horizontal: space.insetCard.left,
                  ),
                  decoration: BoxDecoration(
                    color: colors.page,
                    borderRadius: shape.radiusPill,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.search,
                        size: sizes.iconSm,
                        color: colors.brandPrimary,
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          cursorColor: colors.brandPrimary,
                          style: context.text.titleSmall?.copyWith(
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search properties or cities',
                            hintStyle: context.text.titleSmall?.copyWith(
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
                              padding: EdgeInsets.all(space.inlineMicro),
                              child: Icon(
                                AppIcons.circleX,
                                size: sizes.iconSm,
                                color: colors.inkTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: space.stackFormField),
                // Category filter chips
                SizedBox(
                  height: sizes.iconXl,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: space.inlineMicro),
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(index),
                        selectedColor: colors.brandPrimary,
                        backgroundColor: colors.surface,
                        labelStyle: context.text.labelMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? colors.textOnAction
                              : colors.textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? colors.brandPrimary
                              : colors.cardBorderSoft,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: shape.radiusPill,
                        ),
                        showCheckmark: false,
                        padding: space.insetTag,
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
                        padding: space.insetDialog,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.circleX,
                              size: sizes.iconFeature,
                              color: colors.brandPrimary,
                            ),
                            SizedBox(height: space.stackFormField),
                            Text(
                              'Unable to load properties',
                              style: context.text.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: space.stackSection),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(propertiesProvider.notifier)
                                  .fetchProperties(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.brandPrimary,
                                foregroundColor: colors.textOnAction,
                                shape: RoundedRectangleBorder(
                                  borderRadius: shape.radiusPill,
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
                        padding: space.insetDialog,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.search,
                              size: sizes.avatarMd,
                              color: colors.inkTertiary,
                            ),
                            SizedBox(height: space.stackFormField),
                            Text(
                              'Nothing matches that',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: space.stackText),
                            Text(
                              'Try adjusting your search terms or filters.',
                              style: context.text.labelMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: space.stackFormField),
                            TextButton(
                              onPressed: _resetAllFilters,
                              child: Text(
                                'Reset filters',
                                style: context.text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.brandPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: space.insetCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Featured Stays Horizontal Rail
                          Text(
                            'Popular now',
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackItem),
                          SizedBox(
                            height: sizes.cardHeightCarousel,
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
                          SizedBox(height: space.stackSection),

                          // All properties vertical list
                          Text(
                            'All Stays',
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackItem),
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
                          SizedBox(height: space.stackHero),
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
