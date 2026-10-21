import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Card displaying important policy words such as cancellation terms or split notes.
class BookingNoteCard extends StatelessWidget {
  const BookingNoteCard({
    super.key,
    required this.title,
    required this.body,
    this.amber = false,
    this.marginTop,
  });

  final String title;
  final String body;
  final bool amber;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      margin: EdgeInsets.fromLTRB(
        space.insetCard.left,
        marginTop ?? space.stackItem,
        space.insetCard.right,
        0,
      ),
      padding: space.insetCard,
      decoration: amber
          ? BoxDecoration(
              color: colors.waitFill,
              borderRadius: shape.radiusSurface,
            )
          : BoxDecoration(
              color: colors.surface,
              borderRadius: shape.radiusSurface,
              border: Border.all(
                color: colors.line,
                width: shape.borderDefault,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.0,
              fontWeight: TypeScale.bold,
              color: amber ? colors.waitInk : colors.ink,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            body,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              height: 1.35,
              color: amber ? colors.waitInk : colors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
