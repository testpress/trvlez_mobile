import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Interactive result or action row on red surface.
class AnywhereRow extends StatelessWidget {
  const AnywhereRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.chevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(top: space.stackFormField),
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.checkInStepPanel,
            borderRadius: shape.radiusControl,
          ),
          child: Row(
            children: [
              Container(
                width: sizes.avatarSm,
                height: sizes.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.checkInRingPanel,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Icon(
                  icon,
                  size: sizes.iconXs,
                  color: colors.brandOnSurface,
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (tag != null) ...[
                SizedBox(width: space.inlineIconLabel),
                Container(
                  padding: space.insetTag,
                  decoration: BoxDecoration(
                    color: colors.checkInRingPanel,
                    borderRadius: shape.radiusPill,
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: TypeScale.bold,
                      color: colors.brandOnSurface,
                    ),
                  ),
                ),
              ] else if (chevron) ...[
                SizedBox(width: space.inlineIconLabel),
                Icon(
                  AppIcons.chevronRight,
                  size: sizes.iconSm,
                  color: colors.brandOnSurface,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Form field label on red surface.
class AnywhereLabel extends StatelessWidget {
  const AnywhereLabel({super.key, required this.text, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Padding(
      padding: EdgeInsets.only(
        top: space.stackFormField,
        bottom: space.stackText,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
              ),
            ),
            if (hint != null)
              TextSpan(
                text: ' · $hint',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: colors.brandSecondarySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Text input field on red surface with optional leading icon and clear button.
class AnywhereField extends StatelessWidget {
  const AnywhereField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.icon,
    this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final IconData? icon;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return Container(
      decoration: BoxDecoration(
        color: colors.brandFieldBackground,
        borderRadius: shape.radiusControl,
        border: Border.all(
          color: colors.brandBorderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14.5,
          fontWeight: TypeScale.medium,
          color: colors.brandOnSurface,
          height: 1.25,
        ),
        cursorColor: colors.brandOnSurface,
        cursorHeight: sizes.iconMd,
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14.5,
            color: colors.brandSecondaryPlaceholder,
            height: 1.25,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: sizes.iconSm, color: colors.brandSecondaryBody)
              : null,
          suffixIcon: onClear != null && controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    AppIcons.x,
                    size: sizes.iconXs,
                    color: colors.brandSecondaryBody,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: space.insetCard.left,
            vertical: space.stackFormField,
          ),
        ),
      ),
    );
  }
}
