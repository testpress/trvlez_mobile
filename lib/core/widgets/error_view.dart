import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Standard error state view displaying an error message and a retry action.
///
/// Component Contract (Playbook 04):
/// - Owner & Role: Core UI shared error state surface with actionable recovery.
/// - Variants: Default full/inline error state.
/// - Applicable States: Error message with optional retry callback.
/// - Accessibility: Scalable typography (1.0-2.0), accessible retry button (≥ 48dp).
/// - Validation Owner: [test/core/widgets/error_view_test.dart].
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Try Again',
    super.key,
  });

  /// Factory creating an [ErrorView] extracting a user-safe message from any error.
  factory ErrorView.fromError({
    required Object? error,
    String title = 'Something went wrong',
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    Key? key,
  }) {
    return ErrorView(
      key: key,
      title: title,
      message: AppException.userMessage(error),
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

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
            Icon(
              Icons.error_outline_rounded,
              size: sizes.controlXl,
              color: colors.feedbackError,
            ),
            SizedBox(height: space.stackFormField),
            Text(
              title,
              style: context.text.headlineSmall?.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: space.stackItem),
            Text(
              message,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: space.stackSection),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
