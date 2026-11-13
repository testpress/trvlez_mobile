import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Secondary full-width outline button on a light surface.
///
/// **Contract:**
/// - **Owner:** Feature adapter delegating to canonical [AppButton] (`lib/features/booking/presentation/widgets/booking_app_outline.dart`).
/// - **Role:** Secondary pill outline button in booking and reservation flows.
/// - **Validation Owner:** `test/core/core_widgets_test.dart`.
class BookingAppOutline extends StatelessWidget {
  const BookingAppOutline({
    super.key,
    required this.label,
    required this.onPressed,
    this.marginTop,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final button = AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      borderRadius: context.shape.radiusPill,
    );

    if (marginTop != null) {
      return Padding(
        padding: EdgeInsets.only(top: marginTop!),
        child: button,
      );
    }
    return button;
  }
}
