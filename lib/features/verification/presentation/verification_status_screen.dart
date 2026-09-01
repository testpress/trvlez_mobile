import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/step_checklist.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_info_card.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_score_indicator.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_config.dart';

/// Displays the full verification journey with step-by-step progress.
///
/// Shows a large animated status icon, a descriptive title, individual
/// step completion states, and contextual actions (re-submit for failed, contact support).
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
      final notifier = ref.read(verificationNotifierProvider.notifier);
      if (widget.verificationJobId != null &&
          widget.verificationJobId!.isNotEmpty) {
        notifier.send(SubmissionAccepted(widget.verificationJobId!));
      } else {
        notifier.send(const ReconcileRequested());
      }
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
    ref
        .read(verificationNotifierProvider.notifier)
        .send(const ReconcileRequested(force: true));
  }

  /// Derives the effective verification state.
  TravelerVerificationState get effectiveState {
    final profile = ref.read(currentProfileProvider).value;
    final profileState =
        profile?.verificationState ?? TravelerVerificationState.submitted;
    return ref
        .read(verificationNotifierProvider.notifier)
        .effectiveState(profileState);
  }

  double? get activeVerificationScore {
    final state = ref.read(verificationNotifierProvider);
    if (state is VerificationStateVerified) {
      return state.verificationScore ?? state.jobResult?.verificationScore;
    }
    if (state is VerificationStateProcessing) {
      return state.interimScore ?? state.jobResult?.verificationScore;
    }
    return null;
  }

  String? get failedStep {
    final state = ref.read(verificationNotifierProvider);
    if (state is VerificationStateFailed) {
      return state.failedStep ?? state.verificationStatus?.failedStep;
    }
    return null;
  }

  String? get errorReason {
    final state = ref.read(verificationNotifierProvider);
    if (state is VerificationStateFailed) {
      final reason = state.errorReason ?? state.errorMessage;
      if (reason == uiMitigation) return null;
      return reason;
    }
    return null;
  }

  String? get uiMitigation {
    final state = ref.read(verificationNotifierProvider);
    if (state is VerificationStateFailed) {
      return state.uiMitigation ?? state.verificationStatus?.uiMitigation;
    }
    return null;
  }

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // ── Score Indicator (when verified) ───────────
                          if (state == TravelerVerificationState.verified &&
                              activeVerificationScore != null) ...[
                            const SizedBox(height: 24),
                            VerificationScoreIndicator(
                              score: activeVerificationScore!,
                              isVerified: true,
                            ),
                          ],

                          // ── Mitigation Guidance (when failed) ─────────
                          if (state == TravelerVerificationState.failed &&
                              uiMitigation != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: colorScheme.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      uiMitigation!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: colorScheme.error,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── Error Reason Details (when failed) ────────
                          if (state == TravelerVerificationState.failed &&
                              errorReason != null) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                errorReason!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Step Checklist ────────────────────────────
                          StepChecklist(state: state),
                          const SizedBox(height: 32),

                          // ── Actions ───────────────────────────────────
                          buildActions(context, state, colorScheme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Info Cards ──────────────────────────────────────
                    ...buildInfoCards(state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildStatusIcon(StatusConfig config, TravelerVerificationState state) {
    final color = config.iconGradient.first;
    if (state == TravelerVerificationState.submitted) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: pulseAnimation.value, child: child);
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(config.icon, color: color, size: 40),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(config.icon, color: color, size: 40),
    );
  }

  Widget buildActions(
    BuildContext context,
    TravelerVerificationState state,
    ColorScheme colorScheme,
  ) {
    switch (state) {
      case TravelerVerificationState.verified:
        return ElevatedButton(
          onPressed: () => context.go(AppRoutes.home),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onSurface,
            foregroundColor: colorScheme.surface,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 0,
          ),
          child: Text(
            'Explore properties',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        );

      case TravelerVerificationState.failed:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(verificationNotifierProvider.notifier)
                    .send(const ResetRequested());
                context.go(AppRoutes.passportCapture);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
                foregroundColor: colorScheme.surface,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              child: Text(
                'Re-submit Verification',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Future MVP: open support chat
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'Contact Support',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );

      case TravelerVerificationState.submitted:
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Processing...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );

      default:
        return ElevatedButton(
          onPressed: () => context.go(AppRoutes.home),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onSurface,
            foregroundColor: colorScheme.surface,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 0,
          ),
          child: Text(
            'Go to Home',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        );
    }
  }

  List<Widget> buildInfoCards(TravelerVerificationState state) {
    return [
      InfoCard(
        state: state,
        failedStep: failedStep,
        errorReason: errorReason,
        uiMitigation: uiMitigation,
      ),
    ];
  }
}
