import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_motion.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';

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
    this.active,
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

  /// Optional visual active state (used on brand screens for grey -> white form state).
  final bool? active;

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
        final isButtonActive = active ?? true;
        backgroundColor = isButtonActive
            ? colors.brandOnSurface
            : colors.brandButtonDisabledBackground;
        foregroundColor = isButtonActive
            ? colors.brandActionLabel
            : colors.brandButtonDisabledForeground;
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

    final leadingIcon = icon;
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
    } else if (leadingIcon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon,
          SizedBox(width: space.inlineIconLabel),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.buttonLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      child = Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.buttonLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final effectiveHeight =
        height ??
        (variant == AppButtonVariant.brandWhite
            ? sizes.controlHero
            : sizes.controlLg);
    final effectivePadding = variant == AppButtonVariant.brandWhite
        ? space.insetControlLg
        : space.insetControlMd;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      elevation: 0,
      animationDuration: AppMotion.buttonFade,
      splashFactory: variant == AppButtonVariant.brandWhite
          ? NoSplash.splashFactory
          : null,
      minimumSize: Size(
        isFullWidth ? double.infinity : sizes.avatarXl,
        effectiveHeight,
      ),
      padding: effectivePadding,
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
