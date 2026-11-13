import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Style variants for [AppErrorBanner].
enum AppErrorBannerVariant { standard, brand }

/// Standard reusable error banner adhering to design system tokens.
///
/// **Contract:**
/// - **Owner:** Core design system error surface (`lib/core/widgets/app_error_banner.dart`).
/// - **Variants:** [AppErrorBannerVariant.standard] (light/surface) and [AppErrorBannerVariant.brand] (brand red).
/// - **States:** Hidden (null/empty message), visible (error message), dismissible ([onDismiss] provided).
/// - **Accessibility:** Semantics live region for error announcement; dismiss button has minimum 48x48 touch target.
/// - **Validation Owner:** `test/core/widgets/app_error_banner_test.dart`.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.variant = AppErrorBannerVariant.standard,
    this.onDismiss,
  });

  final String? message;
  final AppErrorBannerVariant variant;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final isBrand = variant == AppErrorBannerVariant.brand;
    final bgColor = isBrand
        ? colors.brandCardBackground
        : colors.feedbackError.withAlpha(25);
    final borderColor = isBrand
        ? colors.brandButtonDisabledBackground
        : colors.feedbackError.withAlpha(70);
    final iconColor = isBrand ? colors.brandSecondary : colors.feedbackError;
    final textColor = isBrand ? colors.brandOnSurface : colors.textPrimary;
    final iconData = isBrand
        ? AppIcons.alertCircle
        : Icons.error_outline_rounded;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackFormField),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: space.insetControlMd,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: shape.radiusControl,
            border: Border.all(color: borderColor, width: shape.borderDefault),
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: sizes.iconSm),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  message!,
                  style: context.text.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  tooltip: 'Dismiss error',
                  icon: Icon(
                    AppIcons.close,
                    size: sizes.iconSm,
                    color: isBrand ? colors.brandSecondarySmall : textColor,
                  ),
                  constraints: BoxConstraints(
                    minWidth: sizes.touchTargetMin,
                    minHeight: sizes.touchTargetMin,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
