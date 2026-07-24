import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
/// A context-aware banner that displays the current verification status.
///
/// Adapts its color, icon, message, and action based on the
/// [TravelerVerificationState]. Shown on the home screen for every state
/// except [TravelerVerificationState.verified].
class VerificationBanner extends StatelessWidget {
  final TravelerVerificationState state;
  final VoidCallback? onActionTap;

  const VerificationBanner({super.key, required this.state, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    if (!state.shouldShowBanner) return const SizedBox.shrink();

    final config = BannerConfig.from(state);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.backgroundColor,
            config.backgroundColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: config.backgroundColor.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                buildIcon(config),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: config.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.subtitle,
                        style: GoogleFonts.cabin(
                          fontSize: 13,
                          color: config.foregroundColor.withAlpha(200),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: config.foregroundColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        config.actionLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: config.foregroundColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: config.foregroundColor,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIcon(BannerConfig config) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config.foregroundColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(config.icon, color: config.foregroundColor, size: 24),
    );
  }
}

/// Internal configuration for banner appearance based on verification state.
class BannerConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;

  const BannerConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  factory BannerConfig.from(TravelerVerificationState state) {
    return switch (state) {
      // ── Pre-submission states (link to /onboarding) ────────────
      TravelerVerificationState.profilePending => const BannerConfig(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF1565C0),
        icon: Icons.verified_user_outlined,
        title: 'Verify Your Identity',
        subtitle: 'Upload your passport to get started with TrvlEz.',
        actionLabel: 'Start',
      ),
      TravelerVerificationState.profileComplete => const BannerConfig(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF1565C0),
        icon: Icons.upload_file_rounded,
        title: 'Upload Your Documents',
        subtitle: 'Passport and selfie video are required for verification.',
        actionLabel: 'Start',
      ),
      TravelerVerificationState.verificationStarted => const BannerConfig(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF1565C0),
        icon: Icons.upload_file_rounded,
        title: 'Continue Document Upload',
        subtitle: 'You have pending document uploads to complete.',
        actionLabel: 'Continue',
      ),
      TravelerVerificationState.passportReviewed => const BannerConfig(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF1565C0),
        icon: Icons.videocam_rounded,
        title: 'Record Selfie Video',
        subtitle: 'Your passport is verified. Now record a short selfie.',
        actionLabel: 'Continue',
      ),
      TravelerVerificationState.documentsUploaded => const BannerConfig(
        backgroundColor: Color(0xFFE8F5E9),
        foregroundColor: Color(0xFF2E7D32),
        icon: Icons.send_rounded,
        title: 'Ready to Submit',
        subtitle: 'Your documents are uploaded. Submit them for verification.',
        actionLabel: 'Submit',
      ),
      // ── Post-submission states (link to /verification/status) ──
      TravelerVerificationState.submitted => const BannerConfig(
        backgroundColor: Color(0xFFFFF3E0),
        foregroundColor: Color(0xFFE65100),
        icon: Icons.hourglass_top_rounded,
        title: 'Verification In Progress',
        subtitle: 'Your documents are being reviewed. Usually 1–2 days.',
        actionLabel: 'Details',
      ),
      TravelerVerificationState.failed => const BannerConfig(
        backgroundColor: Color(0xFFFFEBEE),
        foregroundColor: Color(0xFFC62828),
        icon: Icons.error_outline_rounded,
        title: 'Verification Unsuccessful',
        subtitle: 'Please re-submit your documents to try again.',
        actionLabel: 'Fix Now',
      ),
      // Verified — should not render, but included for exhaustiveness
      TravelerVerificationState.verified => const BannerConfig(
        backgroundColor: Color(0xFFE8F5E9),
        foregroundColor: Color(0xFF2E7D32),
        icon: Icons.check_circle_outline_rounded,
        title: 'Verified',
        subtitle: 'You have full access.',
        actionLabel: 'View',
      ),
    };
  }
}
