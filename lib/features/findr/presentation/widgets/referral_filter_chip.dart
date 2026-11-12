import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Semantic, accessible filter chip with active ink feedback.
class ReferralFilterChip extends StatelessWidget {
  const ReferralFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;
    final space = context.space;

    return InkWell(
      onTap: onTap,
      borderRadius: shape.radiusPill,
      child: Container(
        padding: space.insetTag,
        decoration: BoxDecoration(
          color: isSelected ? colors.brandPrimary : colors.surface,
          borderRadius: shape.radiusPill,
          border: Border.all(
            color: isSelected ? colors.brandPrimary : colors.cardBorder,
            width: shape.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: context.text.labelSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colors.textOnAction : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
