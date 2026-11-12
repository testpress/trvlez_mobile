import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.symmetric(vertical: space.stackItem),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.line,
                  width: shape.borderDefault,
                ),
              ),
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
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: total ? FontWeight.bold : FontWeight.normal,
                    color: colors.ink,
                  ),
                ),
                if (note != null) ...[
                  SizedBox(height: space.stackText),
                  Text(
                    note ?? '',
                    style: context.text.labelMedium?.copyWith(
                      color: noteAmber ? colors.waitInk : colors.inkTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
