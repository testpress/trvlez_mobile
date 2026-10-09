import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';

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

    final colors = context.colors;
    final config = BannerConfig.from(state, colors: colors);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.backgroundColor,
            config.backgroundColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                buildIcon(config),
                const SizedBox(width: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.xs),
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
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: config.foregroundColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      const SizedBox(width: AppSpacing.xs),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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

  factory BannerConfig.from(
    TravelerVerificationState state, {
    required AppColors colors,
  }) {
    return switch (state) {
      // ── Pre-submission states (link to /onboarding) ────────────
      TravelerVerificationState.profilePending => BannerConfig(
        backgroundColor: colors.feedbackInfo.withAlpha(30),
        foregroundColor: colors.feedbackInfo,
        icon: Icons.verified_user_outlined,
        title: 'Verify Your Identity',
        subtitle: 'Upload your passport to get started with TrvlEz.',
        actionLabel: 'Start',
      ),
      TravelerVerificationState.profileComplete => BannerConfig(
        backgroundColor: colors.feedbackInfo.withAlpha(30),
        foregroundColor: colors.feedbackInfo,
        icon: Icons.upload_file_rounded,
        title: 'Upload Your Documents',
        subtitle: 'Passport and selfie video are required for verification.',
        actionLabel: 'Start',
      ),
      TravelerVerificationState.verificationStarted => BannerConfig(
        backgroundColor: colors.feedbackInfo.withAlpha(30),
        foregroundColor: colors.feedbackInfo,
        icon: Icons.upload_file_rounded,
        title: 'Continue Document Upload',
        subtitle: 'You have pending document uploads to complete.',
        actionLabel: 'Continue',
      ),
      TravelerVerificationState.passportReviewed => BannerConfig(
        backgroundColor: colors.feedbackInfo.withAlpha(30),
        foregroundColor: colors.feedbackInfo,
        icon: Icons.videocam_rounded,
        title: 'Record Selfie Video',
        subtitle: 'Your passport is verified. Now record a short selfie.',
        actionLabel: 'Continue',
      ),
      TravelerVerificationState.documentsUploaded => BannerConfig(
        backgroundColor: colors.feedbackSuccess.withAlpha(30),
        foregroundColor: colors.feedbackSuccess,
        icon: Icons.send_rounded,
        title: 'Ready to Submit',
        subtitle: 'Your documents are uploaded. Submit them for verification.',
        actionLabel: 'Submit',
      ),
      // ── Post-submission states (link to /verification/status) ──
      TravelerVerificationState.submitted => BannerConfig(
        backgroundColor: colors.feedbackWarning.withAlpha(30),
        foregroundColor: colors.feedbackWarning,
        icon: Icons.hourglass_top_rounded,
        title: 'Verification In Progress',
        subtitle: 'Your documents are being reviewed. Usually 1–2 days.',
        actionLabel: 'Details',
      ),
      TravelerVerificationState.failed => BannerConfig(
        backgroundColor: colors.feedbackError.withAlpha(30),
        foregroundColor: colors.feedbackError,
        icon: Icons.error_outline_rounded,
        title: 'Verification Unsuccessful',
        subtitle: 'Please re-submit your documents to try again.',
        actionLabel: 'Fix Now',
      ),
      // Verified — should not render, but included for exhaustiveness
      TravelerVerificationState.verified => BannerConfig(
        backgroundColor: colors.feedbackSuccess.withAlpha(30),
        foregroundColor: colors.feedbackSuccess,
        icon: Icons.check_circle_outline_rounded,
        title: 'Verified',
        subtitle: 'You have full access.',
        actionLabel: 'View',
      ),
    };
  }
}
