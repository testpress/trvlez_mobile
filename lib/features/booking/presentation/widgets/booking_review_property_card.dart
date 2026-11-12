import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';

/// Card showing thumbnail photo, property name, and location on the Review screen.
class BookingReviewPropertyCard extends StatelessWidget {
  const BookingReviewPropertyCard({super.key, required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: EdgeInsets.all(space.stackItem),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          PhotoBox(
            width: sizes.controlMd,
            height: sizes.controlMd,
            borderRadius: shape.radiusControl,
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  draft.propertyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.ink,
                  ),
                ),
                SizedBox(height: space.stackText),
                Text(
                  draft.propertyPlace,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
