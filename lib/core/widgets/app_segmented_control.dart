import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Accessible pill segmented filter control adhering to the brand design system.
///
/// **Contract:**
/// - **Owner:** Core design system segmented filter component (`lib/core/widgets/app_segmented_control.dart`).
/// - **Variants:** Horizontal pill segment row with [count] items.
/// - **States:** Unselected, selected ([selected] index), disabled ([onSelect] == null).
/// - **Accessibility:** Uses [Material] and [InkWell] with pill ripple; announces button semantics with selected state;
///   guarantees minimum [sizes.touchTargetMin] (48dp) height per tab.
/// - **Validation Owner:** `test/core/widgets/app_segmented_control_test.dart`.
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
    final sizes = context.sizes;

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
                child: Material(
                  color: colors.transparent,
                  child: InkWell(
                    onTap: onSelect == null ? null : () => onSelect!(i),
                    borderRadius: shape.radiusPill,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                        minHeight: sizes.touchTargetMin,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: space.inlineMicro,
                        vertical: space.stackItem,
                      ),
                      decoration: BoxDecoration(
                        color: i == selected
                            ? colors.surface
                            : colors.transparent,
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
                      child: DefaultTextStyle.merge(
                        style: context.text.labelLarge?.copyWith(
                          color: colors.textPrimary,
                        ),
                        child: label(context, i, i == selected),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
