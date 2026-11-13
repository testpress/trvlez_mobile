import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Standard card container adhering to design system tokens.
///
/// **Contract:**
/// - **Owner:** Core design system surface component (`lib/core/widgets/app_card.dart`).
/// - **Variants:** Standard card with optional border, custom radius, and optional [onTap].
/// - **States:** Default (static) and Interactive (Material ripple on tap).
/// - **Accessibility:** Uses [Material] with [InkWell] for touch feedback and [Semantics].
/// - **Validation Owner:** `test/core/widgets/app_card_golden_test.dart` and `test/core/core_widgets_test.dart`.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    final radius = borderRadius ?? shape.radiusSurface;
    final cardColor = color ?? colors.surface;
    final cardBorder =
        border ??
        Border.all(color: colors.borderSubtle, width: shape.borderDefault);

    Widget content;
    if (onTap != null) {
      content = Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: cardBorder is Border ? cardBorder.top : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding ?? space.insetCard, child: child),
        ),
      );
    } else {
      content = Container(
        padding: padding ?? space.insetCard,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: radius,
          border: cardBorder,
        ),
        child: child,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
