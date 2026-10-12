import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Modal bottom sheet allowing travellers to select their active location.
class LocationPickerSheet extends StatelessWidget {
  const LocationPickerSheet({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  final String currentLocation;
  final ValueChanged<String> onLocationSelected;

  static const List<String> availableLocations = [
    'Edinburgh, UK',
    'London, UK',
    'Paris, France',
    'Rome, Italy',
    'Tokyo, Japan',
    'New York, USA',
    'Honolulu, USA',
  ];

  static Future<void> show(
    BuildContext context, {
    required String currentLocation,
    required ValueChanged<String> onLocationSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        currentLocation: currentLocation,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.viewPaddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.cardBorderSoft,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select city',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...availableLocations.map((city) {
            final isSelected = city == currentLocation;
            return InkWell(
              borderRadius: AppRadius.mdRadius,
              onTap: () {
                onLocationSelected(city);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.mapPin,
                      size: 16,
                      color: isSelected
                          ? colors.brandPrimary
                          : colors.inkTertiary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        city,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? TypeScale.semiBold
                              : TypeScale.regular,
                          color: isSelected
                              ? colors.brandPrimary
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        AppIcons.check,
                        size: 16,
                        color: colors.brandPrimary,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
