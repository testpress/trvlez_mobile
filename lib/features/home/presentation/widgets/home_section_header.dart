import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Clean section header widget with an optional action link.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        if (action != null)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: sizes.touchTargetMin),
            child: InkWell(
              onTap: onAction,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: space.inlineMicro,
                  vertical: space.stackText,
                ),
                child: Text(
                  action!,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
