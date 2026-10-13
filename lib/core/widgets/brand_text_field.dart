import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The pill text field designed specifically for brand red screens.
///
/// Complies with anti-slop guidelines: tap targets ≥ 48dp, explicit autofill hints,
/// sensible keyboard actions, and error visibility.
class BrandTextField extends StatefulWidget {
  const BrandTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.validator,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscurable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final VoidCallback? onSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  State<BrandTextField> createState() => _BrandTextFieldState();
}

class _BrandTextFieldState extends State<BrandTextField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFilled = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 6),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.medium,
              color: colors.brandSecondaryBody,
            ),
          ),
        ),
        TextFormField(
          controller: _controller,
          obscureText: widget.obscurable && _obscured,
          obscuringCharacter: '•',
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          validator: widget.validator,
          cursorColor: colors.brandOnSurface,
          cursorWidth: 1.5,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: TypeScale.regular,
            color: colors.brandOnSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.brandFieldBackground,
            border: OutlineInputBorder(
              borderRadius: AppRadius.pillRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.pillRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.pillRadius,
              borderSide: BorderSide(
                color: colors.brandOnSurface.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.pillRadius,
              borderSide: BorderSide(color: colors.brandSecondary, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.pillRadius,
              borderSide: BorderSide(color: colors.brandSecondary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: TypeScale.regular,
              color: colors.brandSecondaryPlaceholder,
            ),
            errorStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.medium,
              color: colors.brandSecondary,
              height: 1.3,
            ),
            suffixIcon: widget.obscurable
                ? Semantics(
                    button: true,
                    label: _obscured ? 'Show password' : 'Hide password',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Icon(
                          _obscured ? AppIcons.eye : AppIcons.eyeOff,
                          size: 16,
                          color: isFilled
                              ? colors.brandOnSurface
                              : colors.brandSecondaryPlaceholder,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
