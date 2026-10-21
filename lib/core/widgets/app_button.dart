import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Style variants for [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  destructive,

  /// White pill button on a red brand surface. Turns from translucent white to solid white.
  brandWhite,

  /// Translucent outline button on a red brand surface.
  brandOutline,
}

/// Standard reusable button adhering to design system tokens.
///
/// Supports [primary], [secondary], [destructive], [brandWhite], and [brandOutline] variants,
/// an [isLoading] spinner state, custom icons, and full-width sizing.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.isFullWidth = true,
    this.icon,
    this.height,
    this.borderRadius,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final bool isFullWidth;
  final Widget? icon;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    final Color backgroundColor;
    final Color foregroundColor;
    final Color disabledBackgroundColor;
    final Color disabledForegroundColor;
    BorderSide? borderSide;
    BorderRadius effectiveRadius = borderRadius ?? shape.radiusControl;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.actionPrimary;
        foregroundColor = colors.textOnAction;
        disabledBackgroundColor = backgroundColor.withValues(alpha: 0.4);
        disabledForegroundColor = foregroundColor.withValues(alpha: 0.6);
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.surfaceSubtle;
        foregroundColor = colors.textPrimary;
        disabledBackgroundColor = backgroundColor.withValues(alpha: 0.5);
        disabledForegroundColor = colors.textDisabled;
        borderSide = BorderSide(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        );
        break;
      case AppButtonVariant.destructive:
        backgroundColor = colors.feedbackError;
        foregroundColor = colors.textOnAction;
        disabledBackgroundColor = backgroundColor.withValues(alpha: 0.4);
        disabledForegroundColor = foregroundColor.withValues(alpha: 0.6);
        break;
      case AppButtonVariant.brandWhite:
        backgroundColor = colors.brandOnSurface;
        foregroundColor = colors.brandActionLabel;
        disabledBackgroundColor = colors.brandButtonDisabledBackground;
        disabledForegroundColor = colors.brandButtonDisabledForeground;
        effectiveRadius = borderRadius ?? shape.radiusPill;
        break;
      case AppButtonVariant.brandOutline:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.brandOnSurface;
        disabledBackgroundColor = Colors.transparent;
        disabledForegroundColor = colors.brandButtonDisabledForeground;
        borderSide = BorderSide(
          color: colors.verificationOutlineButton,
          width: shape.borderDefault,
        );
        effectiveRadius = borderRadius ?? shape.radiusPill;
        break;
    }

    final effectiveOnPressed = (isLoading || !enabled) ? null : onPressed;

    Widget child;
    if (isLoading) {
      child = SizedBox.square(
        dimension: sizes.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: shape.strokeProgress,
          valueColor: AlwaysStoppedAnimation<Color>(
            effectiveOnPressed != null
                ? foregroundColor
                : disabledForegroundColor,
          ),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          SizedBox(width: space.inlineIconLabel),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: TypeScale.semiBold,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      child = Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: TypeScale.semiBold,
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final effectiveHeight = height ?? sizes.controlLg;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      elevation: 0,
      minimumSize: Size(
        isFullWidth ? double.infinity : sizes.avatarXl,
        effectiveHeight,
      ),
      padding: space.insetControlMd,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: borderSide ?? BorderSide.none,
      ),
    );

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: buttonStyle,
      child: child,
    );
  }
}
