import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

enum VerifyRowStatus { done, running, redo }

typedef StatusRowState = VerifyRowStatus;

class VerifyStatusItem {
  const VerifyStatusItem(this.label, this.status);
  const VerifyStatusItem.named({required this.label, required this.status});
  final String label;
  final VerifyRowStatus status;
}

/// Convenience sub-type allowing `VerifyStatusRow(title: '...', state: ...)` syntax.
class VerifyStatusRow extends VerifyStatusItem {
  const VerifyStatusRow({required String title, required VerifyRowStatus state})
    : super(title, state);
}

/// Checklist rows indicating completion states across passport, selfie, chip, and final check.
class VerifyStatusRows extends StatelessWidget {
  const VerifyStatusRows({
    super.key,
    required this.rows,
    this.dimCompleted = false,
  });

  final List<VerifyStatusItem> rows;
  final bool dimCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rows.length; i++)
            _StatusRowTile(
              item: rows[i],
              last: i == rows.length - 1,
              isDimmed: dimCompleted && rows[i].status == VerifyRowStatus.done,
            ),
        ],
      ),
    );
  }
}

class _StatusRowTile extends StatelessWidget {
  const _StatusRowTile({
    required this.item,
    required this.last,
    required this.isDimmed,
  });

  final VerifyStatusItem item;
  final bool last;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWaiting = item.status == VerifyRowStatus.running;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: last
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
          Container(
            width: 18.0,
            height: 18.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isWaiting || isDimmed)
                  ? colors.verificationCardIconFill
                  : colors.brandOnSurface,
            ),
            child: Icon(
              switch (item.status) {
                VerifyRowStatus.done => AppIcons.check,
                VerifyRowStatus.running => AppIcons.dots,
                VerifyRowStatus.redo => AppIcons.refresh,
              },
              size: 11.0,
              color: (isWaiting || isDimmed)
                  ? colors.brandOnSurface
                  : colors.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.0,
                fontWeight: TypeScale.medium,
                color: isDimmed
                    ? colors.verificationStepInactiveText
                    : colors.brandOnSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: isWaiting ? Colors.transparent : colors.brandOnSurface,
              border: isWaiting
                  ? Border.all(color: colors.verificationStepRing, width: 1.0)
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              switch (item.status) {
                VerifyRowStatus.done => 'Done',
                VerifyRowStatus.running => 'Running',
                VerifyRowStatus.redo => 'Redo',
              },
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10.0,
                fontWeight: TypeScale.semiBold,
                color: isWaiting
                    ? colors.brandOnSurface
                    : colors.brandActionLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
