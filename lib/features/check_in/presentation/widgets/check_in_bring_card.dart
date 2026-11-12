import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Single item in "Take with you" list.
class CheckInBringLine {
  const CheckInBringLine({
    required this.icon,
    required this.lead,
    required this.strong,
  });

  final IconData icon;
  final String lead;
  final String strong;
}

/// What to bring to the reception desk if online check-in is declined.
class CheckInBringCard extends StatelessWidget {
  const CheckInBringCard({
    super.key,
    required this.title,
    required this.lines,
    this.marginTop,
  });

  final String title;
  final List<CheckInBringLine> lines;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      margin: EdgeInsets.only(top: marginTop ?? space.stackFormField),
      padding: space.insetCardCompact,
      decoration: BoxDecoration(
        color: colors.checkInStepPanel,
        borderRadius: shape.radiusControl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.brandOnSurface,
            ),
          ),
          SizedBox(height: space.stackItem),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) SizedBox(height: space.stackItem),
            Row(
              children: [
                Icon(
                  lines[i].icon,
                  size: sizes.iconXs,
                  color: colors.brandSecondary,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: lines[i].lead,
                          style: context.text.labelMedium?.copyWith(
                            color: colors.brandSecondaryBody,
                          ),
                        ),
                        TextSpan(
                          text: lines[i].strong,
                          style: context.text.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
