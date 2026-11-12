import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    this.borderRadius,
  });

  final List<VerifyStatusItem> rows;
  final bool dimCompleted;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: space.stackTight,
        horizontal: space.inlineItem,
      ),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: borderRadius ?? shape.radiusCard,
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final isWaiting = item.status == VerifyRowStatus.running;

    return Container(
      padding: EdgeInsets.symmetric(vertical: space.stackItem),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.verificationDivider,
                  width: shape.borderDefault,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: sizes.iconDefault,
            height: sizes.iconDefault,
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
              size: sizes.iconXs,
              color: (isWaiting || isDimmed)
                  ? colors.brandOnSurface
                  : colors.brandPrimary,
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Text(
              item.label,
              style: context.text.labelMedium?.copyWith(
                color: isDimmed
                    ? colors.verificationStepInactiveText
                    : colors.brandOnSurface,
              ),
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Container(
            padding: space.insetTagSm,
            decoration: BoxDecoration(
              color: isWaiting ? colors.transparent : colors.brandOnSurface,
              border: isWaiting
                  ? Border.all(
                      color: colors.verificationStepRing,
                      width: shape.borderDefault,
                    )
                  : null,
              borderRadius: shape.radiusPill,
            ),
            child: Text(
              switch (item.status) {
                VerifyRowStatus.done => 'Done',
                VerifyRowStatus.running => 'Running',
                VerifyRowStatus.redo => 'Redo',
              },
              style: context.text.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
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
