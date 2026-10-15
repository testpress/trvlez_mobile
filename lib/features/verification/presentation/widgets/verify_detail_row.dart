import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Key-value detail row with bottom hairline divider (for Confirm Details / Chip Data).
class VerifyDetailRow extends StatelessWidget {
  const VerifyDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.last = false,
    this.isLast,
  });

  final String label;
  final String value;
  final bool last;
  final bool? isLast;

  bool get _effectiveLast => isLast ?? last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        border: _effectiveLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.verificationDivider,
                  width: 1.0,
                ),
              ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
