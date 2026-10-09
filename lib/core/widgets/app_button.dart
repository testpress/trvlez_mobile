import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Style variants for [AppButton].
enum AppButtonVariant { primary, secondary, destructive }

/// Standard reusable button adhering to design system tokens.
///
/// Supports [primary], [secondary], and [destructive] variants,
/// an [isLoading] spinner state, custom icons, and full-width sizing.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 54,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color backgroundColor;
    final Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.actionPrimary;
        foregroundColor = colors.textOnAction;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.surfaceSubtle;
        foregroundColor = colors.textPrimary;
        borderSide = BorderSide(color: colors.borderSubtle);
        break;
      case AppButtonVariant.destructive:
        backgroundColor = colors.feedbackError;
        foregroundColor = colors.textOnAction;
        break;
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child;
    if (isLoading) {
      child = SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
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
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      );
    } else {
      child = Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
      elevation: 0,
      minimumSize: Size(isFullWidth ? double.infinity : 88, height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.button,
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
