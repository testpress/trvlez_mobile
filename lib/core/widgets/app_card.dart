import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Standard card container adhering to design system tokens.
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
    final radius = borderRadius ?? AppRadius.card;
    final cardColor = color ?? colors.surface;
    final cardBorder = border ?? Border.all(color: colors.borderSubtle);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: cardBorder,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
