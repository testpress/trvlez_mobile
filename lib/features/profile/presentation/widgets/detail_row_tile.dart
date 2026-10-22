import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Row tile displaying a labeled detail with an edit action button.
class DetailRowTile extends StatelessWidget {
  const DetailRowTile({
    super.key,
    required this.label,
    required this.value,
    required this.actionText,
    required this.onAction,
  });

  final String label;
  final String value;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final text = context.text;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: space.insetCard.horizontal / 2,
        vertical: space.stackItem,
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: sizes.touchTargetMin * 2),
            child: Text(
              label,
              style: text.labelMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: text.titleSmall?.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: text.labelLarge?.copyWith(color: colors.brandPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
