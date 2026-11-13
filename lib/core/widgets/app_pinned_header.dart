import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Pinned white header cap with curved bottom corners that extends into the status bar.
///
/// **Contract:**
/// - **Owner:** Core screen navigation header shell (`lib/core/widgets/app_pinned_header.dart`).
/// - **Variants:** Pinned surface header with drop shadow and rounded bottom corners.
/// - **States:** Responsive to system status bar insets (safe area).
/// - **Accessibility:** Ensures minimum height [sizes.controlLg] (48dp); supports flexible title/action content.
/// - **Validation Owner:** `test/core/widgets/app_pinned_header_test.dart`.
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
    final sizes = context.sizes;
    final topPadding = MediaQuery.paddingOf(context).top;
    final viewPadding = MediaQuery.viewPaddingOf(context).top;
    final topInset = math.max(topPadding, viewPadding);

    final effectiveTop =
        (paddingTop ?? (topInset > 0 ? space.stackItem : space.insetCard.top)) +
        topInset;
    final effectiveBottom = paddingBottom ?? space.stackItem;
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
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizes.controlLg),
        child: child,
      ),
    );
  }
}
