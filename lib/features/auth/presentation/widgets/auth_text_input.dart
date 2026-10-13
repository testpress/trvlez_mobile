import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';

/// Reusable stylized text field for authentication forms.
class AuthTextInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool autocorrect;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  const AuthTextInput({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autocorrect = false,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTypography.body.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIconConstraints: suffixIcon != null
                ? const BoxConstraints(minHeight: 40, minWidth: 40)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
