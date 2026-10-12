import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Accessible pill segmented filter control adhering to the brand design system.
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.count,
    required this.selected,
    required this.label,
    this.onSelect,
  });

  final int count;
  final int selected;
  final Widget Function(BuildContext context, int index, bool active) label;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.page,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSelect == null ? null : () => onSelect!(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? colors.surface
                          : Colors.transparent,
                      borderRadius: AppRadius.fullRadius,
                      boxShadow: i == selected
                          ? [
                              BoxShadow(
                                color: colors.cardShadow,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: label(context, i, i == selected),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
