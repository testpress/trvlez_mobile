import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/step_checklist.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_info_card.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_score_indicator.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_actions.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_config.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_icon.dart';

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

  const VerificationStatusScreen({super.key, this.verificationJobId});

  @override
  ConsumerState<VerificationStatusScreen> createState() =>
      VerificationStatusScreenState();
}

class VerificationStatusScreenState
    extends ConsumerState<VerificationStatusScreen>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reconcile with backend to recover state after process death,
      // resume polling if processing, and update verification status.
      ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
    });
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  Future<void> handleRefresh() async {
    final _ = await ref.refresh(currentProfileProvider.future);
    await ref.read(authNotifierProvider.notifier).refreshVerificationState();
    await ref
        .read(verificationNotifierProvider.notifier)
        .fetchVerificationStatus();
  }

  /// Derives the effective verification state.
  TravelerVerificationState get effectiveState {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    final profileState =
        profile?.verificationState ?? TravelerVerificationState.submitted;
    return ref
        .read(verificationNotifierProvider.notifier)
        .effectiveState(profileState);
  }

  double? get activeVerificationScore {
    final state = ref.read(verificationNotifierProvider);
    return state.jobResult?.verificationScore ??
        state.submitResult?.verificationScore;
  }

  String? get failedStep =>
      ref.read(verificationNotifierProvider).verificationStatus?.failedStep;

  String? get errorReason {
    final state = ref.read(verificationNotifierProvider);
    final reason = state.verificationStatus?.errorReason ?? state.errorMessage;
    if (reason == uiMitigation) return null;
    return reason;
  }

  String? get uiMitigation =>
      ref.read(verificationNotifierProvider).verificationStatus?.uiMitigation;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = effectiveState;
    final config = StatusConfig.from(state, context);

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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
      ),
      body: profileState.isLoading && profileState.valueOrNull == null
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: AppRadius.sm10Radius,
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
                          Center(
                            child: VerificationStatusIcon(
                              config: config,
                              state: state,
                              pulseAnimation: pulseAnimation,
                            ),
                          ),
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // ── Verification Score ───────────────────────
                          if (activeVerificationScore != null) ...[
                            const SizedBox(height: 16),
                            VerificationScoreIndicator(
                              score: activeVerificationScore!,
                              isVerified:
                                  state == TravelerVerificationState.verified,
                            ),
                          ],
                          const SizedBox(height: 32),
                          // ── Step Checklist ────────────────────────────
                          StepChecklist(
                            state: state,
                            isNfcSkipped: ref
                                .read(verificationNotifierProvider)
                                .isNfcSkipped,
                            hasNfcResult:
                                ref
                                    .read(verificationNotifierProvider)
                                    .nfcResult !=
                                null,
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
                          VerificationStatusActions(state: state),
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'If you are facing any difficulties, please get in touch with us on ',
                              ),
                              TextSpan(
                                text: 'Whatsapp',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.feedbackSuccess,
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
}
