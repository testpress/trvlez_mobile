import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Label above a pill-shaped picker field or multiline note input.
class CheckInField extends StatelessWidget {
  const CheckInField({
    super.key,
    required this.label,
    required this.value,
    this.filled = true,
    this.tall = false,
    this.onTap,
    this.controller,
    this.hint,
  });

  final String label;
  final String value;
  final bool filled;
  final bool tall;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: space.stackFormField,
            bottom: space.stackTight,
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.brandSecondary,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: tall ? sizes.thumbPhotoSm : sizes.controlXl,
            padding: EdgeInsets.symmetric(
              horizontal: space.insetCard.left,
              vertical: tall ? space.stackFormField : 0,
            ),
            alignment: tall ? Alignment.topLeft : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: colors.brandFieldBackground,
              borderRadius: tall ? shape.radiusControl : shape.radiusPill,
            ),
            child: Row(
              crossAxisAlignment: tall
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: tall && controller != null
                      ? TextField(
                          controller: controller,
                          maxLines: 3,
                          minLines: 3,
                          cursorColor: colors.brandOnSurface,
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.brandOnSurface,
                            height: 1.25,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: colors.transparent,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: hint,
                            hintStyle: context.text.bodyMedium?.copyWith(
                              color: colors.brandSecondaryPlaceholder,
                              height: 1.25,
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: context.text.bodyMedium?.copyWith(
                            color: filled
                                ? colors.brandOnSurface
                                : colors.brandSecondaryPlaceholder,
                            height: 1.25,
                          ),
                        ),
                ),
                if (!tall) ...[
                  SizedBox(width: space.inlineIconLabel),
                  Icon(
                    AppIcons.chevronDown,
                    size: sizes.iconXs,
                    color: colors.brandSecondaryPlaceholder,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
