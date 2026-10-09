import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';

class StatusConfig {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;

  const StatusConfig({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
  });

  factory StatusConfig.from(
    TravelerVerificationState state,
    BuildContext context,
  ) {
    final colors = context.colors;
    return switch (state) {
      TravelerVerificationState.submitted => StatusConfig(
        icon: Icons.hourglass_top_rounded,
        iconGradient: [
          colors.feedbackWarning,
          colors.feedbackWarning.withAlpha(200),
        ],
        title: 'Verifying Your Identity',
        subtitle:
            'Our system is reviewing your documents. This usually takes less than a minute.',
      ),
      TravelerVerificationState.verified => StatusConfig(
        icon: Icons.verified_rounded,
        iconGradient: [
          colors.feedbackSuccess,
          colors.feedbackSuccess.withAlpha(200),
        ],
        title: 'You\'re Verified!',
        subtitle: 'Your identity has been successfully verified.',
      ),
      TravelerVerificationState.failed => StatusConfig(
        icon: Icons.error_outline_rounded,
        iconGradient: [
          colors.feedbackError,
          colors.feedbackError.withAlpha(200),
        ],
        title: 'Verification Failed',
        subtitle:
            'Unfortunately, we were unable to verify your identity. Please review and re-submit.',
      ),
      _ => StatusConfig(
        icon: Icons.pending_rounded,
        iconGradient: [colors.feedbackInfo, colors.feedbackInfo.withAlpha(200)],
        title: 'Verification Status',
        subtitle: 'Your current verification progress.',
      ),
    };
  }
}
