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
import 'package:trvlez_mobile/core/widgets/app_segmented_control.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';

/// Session provider tracking IDs of properties saved by the traveler.
final savedPropertyIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

/// Screen displaying the traveler's saved properties, items, and chats across ezServices.
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int _selectedServiceIndex = 0;
  static const _services = ['Stays', 'Shop', 'Chat'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final propertiesState = ref.watch(propertiesProvider);
    final allProperties = propertiesState.valueOrNull ?? [];

    final savedIds = ref.watch(savedPropertyIdsProvider);
    final savedProperties = allProperties
        .where((p) => savedIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md + MediaQuery.viewPaddingOf(context).top,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saved',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: TypeScale.bold,
                    letterSpacing: -0.3,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSegmentedControl(
                  count: _services.length,
                  selected: _selectedServiceIndex,
                  onSelect: (index) =>
                      setState(() => _selectedServiceIndex = index),
                  label: (context, index, active) => EzWord(
                    rest: _services[index],
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: active ? TypeScale.bold : TypeScale.medium,
                      color: active ? colors.textPrimary : colors.inkTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Saved Content ──────────────────────────────────────────────
          Expanded(
            child: _selectedServiceIndex != 0 || savedProperties.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.redTint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              AppIcons.heart,
                              size: 26,
                              color: colors.brandPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Nothing saved yet',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: TypeScale.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedServiceIndex == 0
                                ? 'Tap the heart icon on any property to save it here.'
                                : 'ez${_services[_selectedServiceIndex]} saved items will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: savedProperties.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final property = savedProperties[index];
                      return InkWell(
                        borderRadius: AppRadius.cardRadius,
                        onTap: () => context.push(
                          AppRoutes.propertyDetailPath(property.id),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: AppRadius.cardRadius,
                            border: Border.all(color: colors.cardBorderSoft),
                            boxShadow: [
                              BoxShadow(
                                color: colors.cardShadow,
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              PhotoBox(
                                width: 80,
                                height: 80,
                                imageUrl: property.heroImageUrl,
                                borderRadius: AppRadius.mdRadius,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property.name,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: TypeScale.bold,
                                        color: colors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          AppIcons.mapPin,
                                          size: 11,
                                          color: colors.inkTertiary,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            property.city.isNotEmpty
                                                ? property.city
                                                : property.locationString,
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTypography.fontFamily,
                                              fontSize: 11,
                                              color: colors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        if (property.pricePerNight != null) ...[
                                          Text(
                                            '£${property.pricePerNight!.toInt()}',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTypography.fontFamily,
                                              fontSize: 13,
                                              fontWeight: TypeScale.bold,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '/night',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTypography.fontFamily,
                                              fontSize: 11,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        HeartButton(
                                          saved: true,
                                          onTap: () {
                                            ref
                                                .read(
                                                  savedPropertyIdsProvider
                                                      .notifier,
                                                )
                                                .update((state) {
                                                  final next = Set<String>.from(
                                                    state,
                                                  );
                                                  next.remove(property.id);
                                                  return next;
                                                });
                                          },
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
