import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Opens a bottom sheet for choosing an option (e.g. arrival time or guest count).
///
/// **Contract:**
/// - **Owner:** Core bottom sheet picker component (`lib/core/widgets/check_in_option_picker_sheet.dart`).
/// - **Variants:** Single selection option list bottom sheet.
/// - **States:** Option unselected, selected ([current]), scrollable when items overflow.
/// - **Accessibility:** Uses [Semantics] with `button: true, selected: ...`; uses [InkWell] for touch ripples;
///   guarantees minimum [sizes.touchTargetMin] (48dp) touch target height per row.
/// - **Validation Owner:** `test/core/widgets/check_in_option_picker_sheet_test.dart`.
Future<String?> showCheckInOptionPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
}) {
  final colors = context.colors;
  final space = context.space;
  final shape = context.shape;
  final sizes = context.sizes;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: colors.surface,
    barrierColor: colors.scrim,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: sizes.controlSm,
              height: sizes.indicatorProgressHeight,
              margin: EdgeInsets.only(top: space.stackItem),
              decoration: BoxDecoration(
                color: colors.line,
                borderRadius: shape.radiusPill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              space.insetCard.left,
              space.insetInput.bottom,
              space.insetCard.right,
              space.stackText,
            ),
            child: Text(
              title,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in options)
                    Semantics(
                      button: true,
                      selected: option == current,
                      child: Material(
                        color: colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(sheetContext, option),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: sizes.touchTargetMin,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: space.insetCard.left,
                                vertical: space.stackItem,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: context.text.labelLarge?.copyWith(
                                        fontWeight: option == current
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: option == current
                                            ? colors.textPrimary
                                            : colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  if (option == current)
                                    Icon(
                                      AppIcons.check,
                                      size: sizes.iconSm,
                                      color: colors.brandPrimary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: space.stackFormField),
        ],
      ),
    ),
  );
}
