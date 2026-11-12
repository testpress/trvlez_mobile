import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    final externalController = widget.controller;
    if (externalController != null) {
      _controller = externalController;
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final isFilled = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: space.inlineMicro,
            bottom: space.stackItem,
          ),
          child: Text(
            widget.label,
            style: context.text.titleSmall?.copyWith(
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
          onFieldSubmitted: (_) => widget.onSubmitted,
          validator: widget.validator,
          cursorColor: colors.brandOnSurface,
          cursorWidth: shape.borderMedium,
          cursorHeight: sizes.iconMd,
          style: context.text.bodyLarge?.copyWith(
            color: colors.brandOnSurface,
            height: 1.25,
          ),
          decoration: InputDecoration(
            isDense: false,
            filled: true,
            fillColor: colors.brandFieldBackground,
            constraints: BoxConstraints(minHeight: sizes.controlXl),
            border: OutlineInputBorder(
              borderRadius: shape.radiusPill,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: shape.radiusPill,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: shape.radiusPill,
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: shape.radiusPill,
              borderSide: BorderSide(
                color: colors.brandSecondary,
                width: shape.borderMedium,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: shape.radiusPill,
              borderSide: BorderSide(
                color: colors.brandSecondary,
                width: shape.borderMedium,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: space.insetControlXl.left,
              vertical: space.insetControlXl.top,
            ),
            hintText: widget.placeholder,
            hintStyle: context.text.bodyLarge?.copyWith(
              color: colors.brandSecondaryPlaceholder,
              height: 1.25,
            ),
            errorStyle: context.text.labelMedium?.copyWith(
              color: colors.brandSecondary,
              height: 1.3,
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: sizes.touchTargetMin,
              minHeight: sizes.touchTargetMin,
            ),
            suffixIcon: widget.obscurable
                ? Semantics(
                    button: true,
                    label: _obscured ? 'Show password' : 'Hide password',
                    child: InkWell(
                      borderRadius: shape.radiusPill,
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: space.insetControlLg.left,
                        ),
                        child: Icon(
                          _obscured ? AppIcons.eye : AppIcons.eyeOff,
                          size: sizes.iconSm,
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
