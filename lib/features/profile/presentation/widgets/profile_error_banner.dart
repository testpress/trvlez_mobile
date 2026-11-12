import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Error banner widget displaying validation or network failure messages in profile flows.
class ProfileErrorBanner extends StatelessWidget {
  const ProfileErrorBanner({required this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackFormField),
      child: Container(
        width: double.infinity,
        padding: space.insetControlMd,
        decoration: BoxDecoration(
          color: colors.feedbackError.withAlpha(20),
          borderRadius: shape.radiusControl,
          border: Border.all(
            color: colors.feedbackError.withAlpha(60),
            width: shape.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colors.feedbackError,
              size: sizes.iconMd,
            ),
            SizedBox(width: space.inlineIconLabel),
            Expanded(
              child: Text(
                errorMessage!,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.feedbackError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
