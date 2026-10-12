import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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
    this.isFullWidth = true,
    this.icon,
    this.height = 50,
    this.borderRadius,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color backgroundColor;
    final Color foregroundColor;
    final Color disabledBackgroundColor;
    final Color disabledForegroundColor;
    BorderSide? borderSide;
    BorderRadius effectiveRadius = borderRadius ?? AppRadius.button;

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
        borderSide = BorderSide(color: colors.borderSubtle);
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
        effectiveRadius = borderRadius ?? AppRadius.pillRadius;
        break;
      case AppButtonVariant.brandOutline:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.brandOnSurface;
        disabledBackgroundColor = Colors.transparent;
        disabledForegroundColor = colors.brandButtonDisabledForeground;
        borderSide = BorderSide(color: colors.verificationOutlineButton);
        effectiveRadius = borderRadius ?? AppRadius.pillRadius;
        break;
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child;
    if (isLoading) {
      child = SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            onPressed != null ? foregroundColor : disabledForegroundColor,
          ),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: AppSpacing.sm),
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

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      elevation: 0,
      minimumSize: Size(isFullWidth ? double.infinity : 88, height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
