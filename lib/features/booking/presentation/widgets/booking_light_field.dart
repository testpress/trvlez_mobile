import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Form text field with label and pill styling on a light surface.
class BookingLightField extends StatelessWidget {
  const BookingLightField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

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
              color: colors.inkSecondary,
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(minHeight: sizes.controlXl),
          padding: EdgeInsets.symmetric(
            horizontal: space.insetCard.left,
            vertical: space.stackItem,
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line, width: shape.borderDefault),
            borderRadius: shape.radiusPill,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            cursorColor: colors.brandPrimary,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.ink,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              fillColor: colors.transparent,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: context.text.bodyMedium?.copyWith(
                color: colors.textDisabled,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
