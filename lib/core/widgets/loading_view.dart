import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Full-screen or centered loading state indicator.
class LoadingView extends StatelessWidget {
  const LoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.actionPrimary),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
