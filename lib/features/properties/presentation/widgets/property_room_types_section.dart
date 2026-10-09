import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_room_type_card.dart';

/// Available room types section in the property details sheet.
class PropertyRoomTypesSection extends StatelessWidget {
  final Property? property;
  final List<RoomType> roomTypes;
  final bool isLoading;
  final String? selectedRoomTypeId;
  final ValueChanged<String>? onRoomTypeSelected;
  final String? propertyCurrency;

  const PropertyRoomTypesSection({
    super.key,
    this.property,
    required this.roomTypes,
    this.isLoading = false,
    this.selectedRoomTypeId,
    this.onRoomTypeSelected,
    this.propertyCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Rooms',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.actionPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (roomTypes.isEmpty && !isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.cardSm,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Direct room booking available at check-in.',
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...roomTypes.map(
            (rt) => PropertyRoomTypeCard(
              roomType: rt,
              isSelected: selectedRoomTypeId == rt.id,
              onTap: onRoomTypeSelected != null
                  ? () => onRoomTypeSelected!(rt.id)
                  : null,
              propertyCurrency: propertyCurrency,
              onBookNow: property != null && rt.hasValidPrice && rt.isActive
                  ? () {
                      context.push(
                        AppRoutes.createReservation,
                        extra: {
                          'property': property!,
                          'selectedRoomTypeId': rt.id,
                        },
                      );
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}
