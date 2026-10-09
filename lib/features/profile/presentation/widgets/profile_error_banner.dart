import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: colors.feedbackError.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.feedbackError.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colors.feedbackError,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                errorMessage!,
                style: GoogleFonts.cabin(
                  fontSize: 14,
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
