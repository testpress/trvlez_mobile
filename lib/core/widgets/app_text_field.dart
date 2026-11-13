import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Standard form input field adhering to design system tokens.
///
/// **Contract:**
/// - **Owner:** Core design system input component (`lib/core/widgets/app_text_field.dart`).
/// - **Variants:** Standard rounded rectangle and custom pill shape (via [borderRadius]),
///   single-line and multi-line ([maxLines]), text, password ([obscureText]), and numbers.
/// - **States:** Idle, focused, error (validation message), disabled ([enabled] = false), read-only ([readOnly]).
/// - **Accessibility:** Uses native [TextFormField] with semantic labels, clear error styles, and min 48dp height.
/// - **Validation Owner:** `test/core/core_widgets_test.dart` and `test/core/widgets/app_text_field_test.dart`.
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
    this.borderRadius,
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
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final effectiveRadius = borderRadius ?? shape.radiusControl;

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
      style: context.text.bodyMedium?.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.text.bodyMedium?.copyWith(
          color: colors.textDisabled,
        ),
        filled: true,
        fillColor: colors.surfaceSubtle,
        contentPadding: space.insetInput,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: BorderSide(
            color: colors.borderSubtle,
            width: shape.borderDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: BorderSide(
            color: colors.borderSubtle,
            width: shape.borderDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: BorderSide(
            color: colors.borderFocused,
            width: shape.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: BorderSide(
            color: colors.feedbackError,
            width: shape.borderDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: effectiveRadius,
          borderSide: BorderSide(
            color: colors.feedbackError,
            width: shape.borderMedium,
          ),
        ),
        errorStyle: context.text.labelMedium?.copyWith(
          color: colors.feedbackError,
        ),
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
          style: context.text.titleSmall?.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: space.stackText),
        field,
      ],
    );
  }
}
