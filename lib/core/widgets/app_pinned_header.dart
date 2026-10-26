import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Pinned white header cap with curved bottom corners that extends into the status bar.
class AppPinnedHeader extends StatelessWidget {
  const AppPinnedHeader({
    super.key,
    required this.child,
    this.paddingTop,
    this.paddingBottom,
    this.horizontalPadding,
  });

  final Widget child;
  final double? paddingTop;
  final double? paddingBottom;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final topInset = MediaQuery.viewPaddingOf(context).top;

    final effectiveTop = (paddingTop ?? space.insetCard.top) + topInset;
    final effectiveBottom = paddingBottom ?? space.insetCard.bottom;
    final effectiveHorizontal = horizontalPadding ?? space.insetCard.left;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          bottom: shape.radiusCard.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        effectiveHorizontal,
        effectiveTop,
        effectiveHorizontal,
        effectiveBottom,
      ),
      child: child,
    );
  }
}
