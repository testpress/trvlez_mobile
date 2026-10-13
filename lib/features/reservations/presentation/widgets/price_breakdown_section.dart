import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Price summary breakdown section calculating nights and selected room lines.
class PriceBreakdownSection extends StatelessWidget {
  final Property property;
  final Map<String, int> selectedRoomCounts;
  final int numberOfNights;
  final double totalEstimatedAmount;
  final bool hasInvalidPricingSelected;

  const PriceBreakdownSection({
    super.key,
    required this.property,
    required this.selectedRoomCounts,
    required this.numberOfNights,
    required this.totalEstimatedAmount,
    required this.hasInvalidPricingSelected,
  });

  int get _totalSelectedRooms =>
      selectedRoomCounts.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    if (_totalSelectedRooms == 0) return const SizedBox.shrink();

    final colors = context.colors;
    final selectedRoomsWithCounts = property.roomTypes
        .where((rt) => (selectedRoomCounts[rt.id] ?? 0) > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Summary',
          style: AppTypography.heading.copyWith(
            fontSize: 16,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            children: [
              ...selectedRoomsWithCounts.map((roomType) {
                final count = selectedRoomCounts[roomType.id] ?? 0;
                final isPriced = roomType.hasValidPrice;
                final lineTotal = isPriced
                    ? roomType.pricePerNight! * numberOfNights * count
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$count× ${roomType.name} ($numberOfNights night${numberOfNights > 1 ? 's' : ''})',
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        isPriced
                            ? PriceFormatter.formatTotal(
                                lineTotal!,
                                currencyCode:
                                    roomType.currencyCode ??
                                    property.currencyCode,
                              )
                            : 'Unpriced',
                        style: AppTypography.label.copyWith(
                          fontSize: 13,
                          color: isPriced
                              ? colors.textPrimary
                              : colors.feedbackError,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Total',
                    style: AppTypography.heading.copyWith(
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    hasInvalidPricingSelected
                        ? 'Pricing unavailable'
                        : PriceFormatter.formatTotal(
                            totalEstimatedAmount,
                            currencyCode: property.currencyCode,
                          ),
                    style: AppTypography.heading.copyWith(
                      fontSize: 16,
                      color: hasInvalidPricingSelected
                          ? colors.feedbackError
                          : colors.actionPrimary,
                    ),
                  ),
                ],
              ),
              if (hasInvalidPricingSelected) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pricing is unavailable for one or more selected rooms. Please choose a priced room type to proceed.',
                  style: AppTypography.body.copyWith(
                    fontSize: 11,
                    color: colors.feedbackError,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
