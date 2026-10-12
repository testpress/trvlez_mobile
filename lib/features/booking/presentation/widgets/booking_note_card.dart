import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Card displaying important policy words such as cancellation terms or split notes.
class BookingNoteCard extends StatelessWidget {
  const BookingNoteCard({
    super.key,
    required this.title,
    required this.body,
    this.amber = false,
    this.marginTop = AppSpacing.sm,
  });

  final String title;
  final String body;
  final bool amber;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md,
        marginTop,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: amber
          ? BoxDecoration(
              color: colors.waitFill,
              borderRadius: AppRadius.cardRadius,
            )
          : BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: colors.line),
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
          const SizedBox(height: 4),
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
