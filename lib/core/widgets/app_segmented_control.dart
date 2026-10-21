import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.all(space.stackText),
      decoration: BoxDecoration(
        color: colors.page,
        borderRadius: shape.radiusPill,
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
                    padding: EdgeInsets.symmetric(vertical: space.stackItem),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? colors.surface
                          : Colors.transparent,
                      borderRadius: shape.radiusPill,
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
