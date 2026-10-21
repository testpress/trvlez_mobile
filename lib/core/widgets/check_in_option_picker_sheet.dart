import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Opens a bottom sheet for choosing an option (e.g. arrival time or guest count).
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
    barrierColor: Colors.black54,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
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
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: TypeScale.bold,
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(sheetContext, option),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: space.insetCard.left,
                            vertical: space.inlineButtonGroup,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 14,
                                    fontWeight: option == current
                                        ? TypeScale.semiBold
                                        : TypeScale.regular,
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
