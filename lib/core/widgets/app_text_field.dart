import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Standard form input field adhering to design system tokens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onFieldSubmitted,
    super.key,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    final field = TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onFieldSubmitted: onFieldSubmitted,
      style: (context.text.bodyMedium ?? const TextStyle()).copyWith(
        color: colors.textPrimary,
        fontWeight: TypeScale.regular,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: (context.text.bodyMedium ?? const TextStyle()).copyWith(
          color: colors.textDisabled,
          fontWeight: TypeScale.regular,
        ),
        filled: true,
        fillColor: colors.surfaceSubtle,
        contentPadding: space.insetInput,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: shape.radiusControl,
          borderSide: BorderSide(
            color: colors.borderSubtle,
            width: shape.borderDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: shape.radiusControl,
          borderSide: BorderSide(
            color: colors.borderSubtle,
            width: shape.borderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: shape.radiusControl,
          borderSide: BorderSide(
            color: colors.borderFocused,
            width: shape.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: shape.radiusControl,
          borderSide: BorderSide(
            color: colors.feedbackError,
            width: shape.borderDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: shape.radiusControl,
          borderSide: BorderSide(
            color: colors.feedbackError,
            width: shape.borderMedium,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: TypeScale.regular,
        ).copyWith(color: colors.feedbackError),
      ),
    );

    if (label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: TypeScale.semiBold,
          ).copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: space.stackText),
        field,
      ],
    );
  }
}
