import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/step_checklist.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_info_card.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_score_indicator.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_config.dart';
import 'package:trvlez_mobile/app/routes.dart';
/// Displays the full verification journey with step-by-step progress.
///
/// Shows a large animated status icon, a descriptive title, individual
/// step completion states, and contextual actions (re-submit for failed,
/// contact support).
///
/// When [verificationJobId] is provided, polls the backend for real-time
/// verification pipeline progress.
class VerificationStatusScreen extends ConsumerStatefulWidget {
  final String? verificationJobId;
  final VerificationNotifier? verificationNotifier;

  const VerificationStatusScreen({
    super.key,
    this.verificationJobId,
    this.verificationNotifier,
  });

  @override
  ConsumerState<VerificationStatusScreen> createState() =>
      VerificationStatusScreenState();
}

class VerificationStatusScreenState extends ConsumerState<VerificationStatusScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulseController;
  late final Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    widget.verificationNotifier?.fetchVerificationStatus();
    widget.verificationNotifier?.addListener(onNotifierChanged);
  }

  @override
  void dispose() {
    widget.verificationNotifier?.removeListener(onNotifierChanged);
    pulseController.dispose();
    super.dispose();
  }

  void onNotifierChanged() {
    if (mounted) setState(() {});
  }

  Future<void> handleRefresh() async {
    final _ = await ref.refresh(currentProfileProvider.future);
    await ref.read(authNotifierProvider.notifier).refreshVerificationState();
    await widget.verificationNotifier?.fetchVerificationStatus();
  }

  /// Derives the effective verification state.
  TravelerVerificationState get effectiveState {
    final profile = ref.read(currentProfileProvider).value;
    final profileState = profile?.verificationState ?? TravelerVerificationState.submitted;
    return widget.verificationNotifier?.effectiveState(profileState) ?? profileState;
  }

  double? get activeVerificationScore {
    return widget.verificationNotifier?.jobResult?.verificationScore ??
        widget.verificationNotifier?.submitResult?.verificationScore;
  }

  String? get failedStep => widget.verificationNotifier?.verificationStatus?.failedStep;

  String? get errorReason {
    final reason = widget.verificationNotifier?.verificationStatus?.errorReason ??
        widget.verificationNotifier?.errorMessage;
    if (reason == uiMitigation) return null;
    return reason;
  }

  String? get uiMitigation => widget.verificationNotifier?.verificationStatus?.uiMitigation;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = effectiveState;
    final config = StatusConfig.from(state);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'KYC',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
      ),
      body: profileState.isLoading && profileState.value == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Horizontal Stepper Progress Indicator - Step 4 (All completed)
                    const KycProgressStepper(progressIndex: 4),
                    const SizedBox(height: 24),

                    // Central Card Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Status Icon ────────────────────────────────
                          Center(child: buildStatusIcon(config, state)),
                          const SizedBox(height: 24),
                          // ── Title & Subtitle ──────────────────────────
                          Text(
                            config.title,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            config.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // ── Verification Score ───────────────────────
                          if (activeVerificationScore != null) ...[
                            const SizedBox(height: 16),
                            VerificationScoreIndicator(
                              score: activeVerificationScore!,
                              isVerified: state == TravelerVerificationState.verified,
                            ),
                          ],
                          const SizedBox(height: 32),
                          // ── Step Checklist ────────────────────────────
                          StepChecklist(
                            state: state, 
                            isNfcSkipped: widget.verificationNotifier?.isNfcSkipped ?? false,
                            hasNfcResult: widget.verificationNotifier?.nfcResult != null,
                          ),
                          const SizedBox(height: 24),
                          // ── Info Card ─────────────────────────────────
                          InfoCard(
                            state: state,
                            failedStep: failedStep,
                            errorReason: errorReason,
                            uiMitigation: uiMitigation,
                          ),
                          const SizedBox(height: 24),
                          // ── Actions ───────────────────────────────────
                          if (state.isFailed) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                widget.verificationNotifier?.reset();
                                context.go(AppRoutes.passportCapture);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(
                                'Re-submit Documents',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onSurface,
                                foregroundColor: colorScheme.surface,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                // Future: open support chat/email
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Support — coming soon!'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.support_agent_rounded),
                              label: Text(
                                'Contact Support',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                                minimumSize: const Size(double.infinity, 44),
                              ),
                            ),
                          ],
                          if (state.isVerified) ...[
                            ElevatedButton.icon(
                              onPressed: () => context.go(AppRoutes.home),
                              icon: const Icon(Icons.explore_rounded),
                              label: Text(
                                'Start Exploring',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onSurface,
                                foregroundColor: colorScheme.surface,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Footer text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                            children: [
                              const TextSpan(
                                text: 'If you are facing any difficulties, please get in touch with us on ',
                              ),
                              TextSpan(
                                text: 'Whatsapp',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF25D366),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildStatusIcon(StatusConfig config, TravelerVerificationState state) {
    final icon = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.iconGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.iconGradient.first.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(config.icon, color: Colors.white, size: 44),
    );

    // Only pulse the icon when processing
    if (state.isProcessing) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: pulseAnimation.value, child: child);
        },
        child: icon,
      );
    }

    return icon;
  }
}
