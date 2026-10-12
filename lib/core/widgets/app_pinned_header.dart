import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Pinned white header cap with curved bottom corners that extends into the status bar.
class AppPinnedHeader extends StatelessWidget {
  const AppPinnedHeader({
    super.key,
    required this.child,
    this.paddingTop = AppSpacing.md,
    this.paddingBottom = AppSpacing.md,
    this.horizontalPadding = AppSpacing.md,
  });

  final Widget child;
  final double paddingTop;
  final double paddingBottom;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        paddingTop + topInset,
        horizontalPadding,
        paddingBottom,
      ),
      child: child,
    );
  }
}
