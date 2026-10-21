import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';

/// Pinned bottom bar on the Property Screen displaying total price and Review CTA.
class PropertyFootBar extends StatelessWidget {
  const PropertyFootBar({super.key, required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.fromLTRB(
        space.insetCard.left,
        space.stackItem,
        space.insetCard.right,
        space.insetCard.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.line, width: shape.borderDefault),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (draft.chosen.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: space.stackItem),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.0,
                        color: colors.ink,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      PriceFormatter.formatPrice(
                        draft.total.toDouble(),
                        currencyCode: draft.currencyCode,
                      ),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 18.0,
                        fontWeight: TypeScale.bold,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            BookingAppButton(
              label: draft.chosen.isEmpty ? 'Select a room' : 'Review booking',
              onPressed: draft.canReview
                  ? () => context.push(AppRoutes.bookingReview)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
