import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';

/// Form text field with label and pill styling on a light surface.
///
/// **Contract:**
/// - **Owner:** Feature adapter delegating to canonical [AppTextField] (`lib/features/booking/presentation/widgets/booking_light_field.dart`).
/// - **Role:** Pill-shaped text input for booking payment cards and forms.
/// - **Validation Owner:** `test/core/core_widgets_test.dart`.
class BookingLightField extends StatelessWidget {
  const BookingLightField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hintText: hint,
      controller: controller,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      borderRadius: context.shape.radiusPill,
    );
  }
}
