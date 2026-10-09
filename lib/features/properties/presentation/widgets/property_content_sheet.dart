import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_amenities_section.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_bottom_bar.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_description_section.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_overview_section.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_room_types_section.dart';

/// Draggable/scrollable sheet containing property description, amenities, rooms, and bottom action bar.
class PropertyContentSheet extends StatelessWidget {
  final Property property;
  final bool isEnriching;
  final ScrollController scrollController;
  final String? selectedRoomTypeId;
  final ValueChanged<String> onRoomTypeSelected;

  const PropertyContentSheet({
    super.key,
    required this.property,
    required this.isEnriching,
    required this.scrollController,
    this.selectedRoomTypeId,
    required this.onRoomTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: screenHeight * 0.36,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PropertyOverviewSection(property: property),
                    const SizedBox(height: 20),
                    PropertyDescriptionSection(
                      description: property.longDescription.isNotEmpty
                          ? property.longDescription
                          : property.shortDescription,
                    ),
                    if (property.amenities.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      PropertyAmenitiesSection(facilities: property.amenities),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    PropertyRoomTypesSection(
                      property: property,
                      roomTypes: property.roomTypes,
                      isLoading: isEnriching,
                      selectedRoomTypeId: selectedRoomTypeId,
                      onRoomTypeSelected: onRoomTypeSelected,
                      propertyCurrency: property.currencyCode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            // Pinned Bottom Bar
            PropertyBottomBar(
              property: property,
              isLoading: isEnriching,
              selectedRoomTypeId: selectedRoomTypeId,
            ),
          ],
        ),
      ),
    );
  }
}
