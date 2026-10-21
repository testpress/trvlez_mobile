import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/app_segmented_control.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';

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
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

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
              borderRadius: BorderRadius.vertical(
                bottom: shape.radiusSurface.topLeft,
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
              space.insetCard.left,
              space.insetCard.top + MediaQuery.viewPaddingOf(context).top,
              space.insetCard.right,
              space.insetCard.bottom,
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
                SizedBox(height: space.stackFormField),
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
                      padding: space.insetDialog,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: sizes.controlXl,
                            height: sizes.controlXl,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.redTint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              AppIcons.heart,
                              size: sizes.iconLg,
                              color: colors.brandPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackFormField),
                          Text(
                            'Nothing saved yet',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: TypeScale.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackText),
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
                    padding: space.insetCard,
                    itemCount: savedProperties.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: space.stackFormField),
                    itemBuilder: (context, index) {
                      final property = savedProperties[index];
                      return InkWell(
                        borderRadius: shape.radiusSurface,
                        onTap: () => context.push(
                          AppRoutes.propertyDetailPath(property.id),
                        ),
                        child: Container(
                          padding: space.insetCardCompact,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: shape.radiusSurface,
                            border: Border.all(
                              color: colors.cardBorderSoft,
                              width: shape.borderDefault,
                            ),
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
                                width: sizes.thumbPhotoSm,
                                height: sizes.thumbPhotoSm,
                                imageUrl: property.heroImageUrl,
                                borderRadius: shape.radiusControl,
                              ),
                              SizedBox(width: space.inlineItem),
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
                                    SizedBox(height: space.stackText),
                                    Row(
                                      children: [
                                        Icon(
                                          AppIcons.mapPin,
                                          size: sizes.iconXs,
                                          color: colors.inkTertiary,
                                        ),
                                        SizedBox(width: space.inlineMicro),
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
                                    SizedBox(height: space.stackText),
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
                                          SizedBox(width: space.inlineMicro),
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
