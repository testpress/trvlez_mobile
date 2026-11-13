import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Standard empty state view displaying an icon, title, description, and optional action.
///
/// **Contract:**
/// - **Owner:** Core design system empty surface (`lib/core/widgets/empty_view.dart`).
/// - **Variants:** Centered empty view with optional icon, subtitle, and primary action CTA.
/// - **States:** Static empty illustration and text; interactive when [onAction] provided.
/// - **Accessibility:** Uses semantic headings and readable contrast; ensures minimum touch target on action.
/// - **Validation Owner:** `test/core/widgets/empty_view_test.dart`.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Center(
      child: Padding(
        padding: space.insetDialog,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: space.insetDialog,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: sizes.avatarMd,
                  color: colors.brandPrimary,
                ),
              ),
              SizedBox(height: space.stackFormField),
            ],
            Text(
              title,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: space.stackTight),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: space.stackSection),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
