import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/counter_tile.dart';

/// Section allowing selection of rooms and showing capacity warnings.
class RoomSelectionSection extends StatelessWidget {
  final Property property;
  final Map<String, int> selectedRoomCounts;
  final ValueChanged<String> onIncrementRoom;
  final ValueChanged<String> onDecrementRoom;
  final bool isOccupancyExceeded;
  final int totalMaxCapacity;

  const RoomSelectionSection({
    super.key,
    required this.property,
    required this.selectedRoomCounts,
    required this.onIncrementRoom,
    required this.onDecrementRoom,
    required this.isOccupancyExceeded,
    required this.totalMaxCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Types',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (property.roomTypes.isEmpty)
          Text(
            'No rooms available for this property.',
            style: GoogleFonts.cabin(fontSize: 14, color: colors.feedbackError),
          )
        else
          ...property.roomTypes.map((roomType) {
            final currentSelected = selectedRoomCounts[roomType.id] ?? 0;
            final isPriced = roomType.hasValidPrice && roomType.isActive;
            final priceSubtitle = isPriced
                ? '${PriceFormatter.formatPrice(roomType.pricePerNight!, currencyCode: roomType.currencyCode ?? property.currencyCode)} / night'
                : 'Pricing unavailable';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CounterTile(
                label: roomType.name,
                subtitle: priceSubtitle,
                subtitleColor:
                    isPriced ? colors.actionPrimary : colors.feedbackError,
                icon: Icons.bed_outlined,
                value: currentSelected,
                colorScheme: Theme.of(context).colorScheme,
                onIncrement:
                    isPriced ? () => onIncrementRoom(roomType.id) : null,
                onDecrement:
                    currentSelected > 0
                        ? () => onDecrementRoom(roomType.id)
                        : null,
              ),
            );
          }),
        if (isOccupancyExceeded) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.feedbackError.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.feedbackError),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colors.feedbackError,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Selected rooms accommodate up to $totalMaxCapacity guests. Please add more rooms or adjust guest count to confirm reservation.',
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      color: colors.feedbackError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
