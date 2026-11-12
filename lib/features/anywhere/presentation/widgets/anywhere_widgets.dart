import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(
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
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.brandOnSurface,
              ),
            ),
            if (hint != null)
              TextSpan(
                text: ' · $hint',
                style: context.text.bodySmall?.copyWith(
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
        style: context.text.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colors.brandOnSurface,
          height: 1.25,
        ),
        cursorColor: colors.brandOnSurface,
        cursorHeight: sizes.iconMd,
        decoration: InputDecoration(
          filled: false,
          fillColor: colors.transparent,
          hintText: hint,
          hintStyle: context.text.labelLarge?.copyWith(
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
