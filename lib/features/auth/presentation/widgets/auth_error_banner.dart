import 'package:flutter/material.dart';
import 'package:trvlez_mobile/core/widgets/app_error_banner.dart';

/// Reusable dismissible error banner for authentication screens.
///
/// **Contract:**
/// - **Owner:** Feature adapter delegating to canonical [AppErrorBanner] (`lib/features/auth/presentation/widgets/auth_error_banner.dart`).
/// - **Role:** Red brand card error banner with dismiss action in auth screens.
/// - **Validation Owner:** `test/core/widgets/app_error_banner_test.dart`.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.errorMessage,
    required this.onDismiss,
  });

  final String? errorMessage;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppErrorBanner(
      message: errorMessage,
      variant: AppErrorBannerVariant.brand,
      onDismiss: onDismiss,
    );
  }
}
