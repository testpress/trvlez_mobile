import 'package:flutter/material.dart';

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

  factory StatusConfig.from(TravelerVerificationState state) {
    return switch (state) {
      TravelerVerificationState.submitted => const StatusConfig(
        icon: Icons.hourglass_top_rounded,
        iconGradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        title: 'Verifying Your Identity',
        subtitle:
            'Our system is reviewing your documents. This usually takes less than a minute.',
      ),
      TravelerVerificationState.verified => const StatusConfig(
        icon: Icons.verified_rounded,
        iconGradient: [Color(0xFF10B981), Color(0xFF34D399)],
        title: 'You\'re Verified!',
        subtitle: 'Your identity has been successfully verified.',
      ),
      TravelerVerificationState.failed => const StatusConfig(
        icon: Icons.error_outline_rounded,
        iconGradient: [Color(0xFFEF4444), Color(0xFFF87171)],
        title: 'Verification Failed',
        subtitle:
            'Unfortunately, we were unable to verify your identity. Please review and re-submit.',
      ),
      _ => const StatusConfig(
        icon: Icons.pending_rounded,
        iconGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        title: 'Verification Status',
        subtitle: 'Your current verification progress.',
      ),
    };
  }
}
