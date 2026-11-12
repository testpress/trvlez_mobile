import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
      backgroundColor: context.colors.transparent,
      builder: (context) => LocationPickerSheet(
        currentLocation: currentLocation,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
      ),
      padding: EdgeInsets.fromLTRB(
        space.stackSection,
        space.stackItem,
        space.stackSection,
        MediaQuery.viewPaddingOf(context).bottom + space.inlineItem,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: sizes.controlSm,
              height: sizes.indicatorProgressHeight,
              margin: EdgeInsets.symmetric(vertical: space.stackItem),
              decoration: BoxDecoration(
                color: colors.cardBorderSoft,
                borderRadius: shape.radiusPill,
              ),
            ),
          ),
          SizedBox(height: space.stackItem),
          Text(
            'Select city',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackItem),
          ...availableLocations.map((city) {
            final isSelected = city == currentLocation;
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: sizes.touchTargetMin),
              child: InkWell(
                borderRadius: shape.radiusControl,
                onTap: () {
                  onLocationSelected(city);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: space.stackFormField,
                    horizontal: space.inlineMicro,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.mapPin,
                        size: sizes.iconSm,
                        color: isSelected
                            ? colors.brandPrimary
                            : colors.inkTertiary,
                      ),
                      SizedBox(width: space.inlineItem),
                      Expanded(
                        child: Text(
                          city,
                          style: context.text.labelLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? colors.brandPrimary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          AppIcons.check,
                          size: sizes.iconSm,
                          color: colors.brandPrimary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
