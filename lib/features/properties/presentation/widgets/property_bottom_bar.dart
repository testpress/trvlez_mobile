import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Pinned bottom bar displaying selected room rate and action button.
class PropertyBottomBar extends StatelessWidget {
  final Property property;
  final bool isLoading;
  final String? selectedRoomTypeId;

  const PropertyBottomBar({
    super.key,
    required this.property,
    this.isLoading = false,
    this.selectedRoomTypeId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final RoomType? selectedRoom = selectedRoomTypeId != null
        ? property.roomTypes
            .where((r) => r.id == selectedRoomTypeId)
            .firstOrNull
        : null;

    final String priceLabel;
    final String priceDisplay;
    final bool canBook;

    if (selectedRoom != null) {
      priceLabel = 'Selected Room';
      if (selectedRoom.hasValidPrice) {
        priceDisplay =
            '${PriceFormatter.formatPrice(selectedRoom.pricePerNight!, currencyCode: selectedRoom.currencyCode ?? property.currencyCode)} / night';
        canBook = !isLoading;
      } else {
        priceDisplay = 'Pricing unavailable';
        canBook = false;
      }
    } else {
      priceLabel = 'Pricing';
      final validRooms = property.roomTypes
          .where((r) => r.isActive && r.hasValidPrice)
          .toList();
      if (validRooms.isNotEmpty) {
        final minPrice = validRooms
            .map((r) => r.pricePerNight!)
            .reduce((a, b) => a < b ? a : b);
        priceDisplay =
            'From ${PriceFormatter.formatPrice(minPrice, currencyCode: property.currencyCode)} / night';
        canBook = !isLoading;
      } else if (property.pricePerNight != null && property.pricePerNight! > 0) {
        priceDisplay =
            '${PriceFormatter.formatPrice(property.pricePerNight!, currencyCode: property.currencyCode)} / night';
        canBook = !isLoading;
      } else {
        priceDisplay = 'Pricing unavailable';
        canBook = false;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    priceLabel,
                    style: GoogleFonts.cabin(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    priceDisplay,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: canBook ? colors.actionPrimary : colors.feedbackError,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.icon(
              onPressed: canBook
                  ? () {
                      context.push(
                        AppRoutes.createReservation,
                        extra: {
                          'property': property,
                          'selectedRoomTypeId': selectedRoomTypeId,
                        },
                      );
                    }
                  : null,
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.textOnAction,
                        ),
                      ),
                    )
                  : const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                isLoading ? 'Loading...' : 'Book Now',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.actionPrimary,
                foregroundColor: colors.textOnAction,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
