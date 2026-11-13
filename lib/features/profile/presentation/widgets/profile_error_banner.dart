import 'package:flutter/material.dart';
import 'package:trvlez_mobile/core/widgets/app_error_banner.dart';

/// Error banner widget displaying validation or network failure messages in profile flows.
///
/// **Contract:**
/// - **Owner:** Feature adapter delegating to canonical [AppErrorBanner] (`lib/features/profile/presentation/widgets/profile_error_banner.dart`).
/// - **Role:** Surface error banner for profile forms and settings.
/// - **Validation Owner:** `test/core/widgets/app_error_banner_test.dart`.
class ProfileErrorBanner extends StatelessWidget {
  const ProfileErrorBanner({super.key, required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AppErrorBanner(
      message: errorMessage,
      variant: AppErrorBannerVariant.standard,
    );
  }
}
