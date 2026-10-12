import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Row inside summary cards displaying a label, optional sub-note, and formatted value.
class BookingSummaryRow extends StatelessWidget {
  const BookingSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.total = false,
    this.last = false,
    this.noteAmber = false,
  });

  final String label;
  final String value;
  final String? note;
  final bool total;
  final bool last;
  final bool noteAmber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.line)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: total ? 15.0 : 13.0,
                    fontWeight: total ? TypeScale.bold : TypeScale.regular,
                    color: colors.ink,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note ?? '',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.0,
                      color: noteAmber ? colors.waitInk : colors.inkTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: total ? 18.0 : 14.0,
                fontWeight: TypeScale.bold,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
