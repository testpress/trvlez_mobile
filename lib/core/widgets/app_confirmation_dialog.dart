import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Standard confirmation and destructive-action dialog.
///
/// **Contract:**
/// - **Owner:** Core modal dialog surface (`lib/core/widgets/app_confirmation_dialog.dart`).
/// - **Variants:** Standard confirmation ([isDestructive] = false) and destructive warning ([isDestructive] = true).
/// - **States:** Modal surface with positive and negative actions.
/// - **Accessibility:** Uses semantic dialog role, clear action labels, and high-contrast destructive styling.
/// - **Validation Owner:** `test/core/widgets/app_confirmation_dialog_test.dart`.
class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: shape.radiusSurface),
      backgroundColor: colors.surface,
      title: Text(
        title,
        style: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: context.text.labelLarge?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive
                ? colors.feedbackError
                : colors.actionPrimary,
            foregroundColor: colors.textOnAction,
            shape: RoundedRectangleBorder(borderRadius: shape.radiusControl),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Helper function to show [AppConfirmationDialog] and return user choice.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AppConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );
  return result ?? false;
}
