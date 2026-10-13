import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Card displaying details, pricing, and book action for a single room type.
class PropertyRoomTypeCard extends StatelessWidget {
  final RoomType roomType;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? propertyCurrency;
  final VoidCallback? onBookNow;

  const PropertyRoomTypeCard({
    super.key,
    required this.roomType,
    this.isSelected = false,
    this.onTap,
    this.propertyCurrency,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBookable = roomType.hasValidPrice && roomType.isActive;

    return GestureDetector(
      onTap: isBookable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.actionPrimary.withValues(alpha: 0.08)
              : colors.surfaceSubtle,
          borderRadius: AppRadius.cardSm,
          border: Border.all(
            color: isSelected ? colors.actionPrimary : colors.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: colors.actionPrimary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          roomType.name,
                          style: AppTypography.heading.copyWith(
                            fontSize: 15,
                            color: isBookable
                                ? colors.textPrimary
                                : colors.textDisabled,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.actionPrimary
                        : colors.actionPrimary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: isSelected
                            ? colors.textOnAction
                            : colors.actionPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Max ${roomType.maxOccupancy}',
                        style: AppTypography.label.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? colors.textOnAction
                              : colors.actionPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isBookable)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: PriceFormatter.formatPrice(
                        roomType.pricePerNight!,
                        currencyCode: roomType.currencyCode ?? propertyCurrency,
                      ),
                      style: AppTypography.heading.copyWith(
                        fontSize: 16,
                        color: colors.actionPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' / night',
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.feedbackError.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Text(
                  'Pricing unavailable',
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    color: colors.feedbackError,
                  ),
                ),
              ),
            if (roomType.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                roomType.description,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Adults: ${roomType.maxAdults}',
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (roomType.maxChildren > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Children: ${roomType.maxChildren}',
                        style: AppTypography.body.copyWith(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  !isBookable
                      ? 'Unavailable'
                      : isSelected
                      ? 'Selected'
                      : 'Tap to select',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: !isBookable
                        ? colors.feedbackError
                        : isSelected
                        ? colors.actionPrimary
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSelected && isBookable && onBookNow != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onBookNow,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(
                    'Book This Room',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.actionPrimary,
                    foregroundColor: colors.textOnAction,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
