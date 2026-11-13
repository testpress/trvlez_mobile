import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Primary full-width button on a light surface.
///
/// **Contract:**
/// - **Owner:** Feature adapter delegating to canonical [AppButton] (`lib/features/booking/presentation/widgets/booking_app_button.dart`).
/// - **Role:** Primary pill CTA in booking and reservation flows.
/// - **Validation Owner:** `test/core/core_widgets_test.dart`.
class BookingAppButton extends StatelessWidget {
  const BookingAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.paddingVertical,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? paddingVertical;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      borderRadius: context.shape.radiusPill,
    );
  }
}
