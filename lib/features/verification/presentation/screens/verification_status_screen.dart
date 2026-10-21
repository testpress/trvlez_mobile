import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
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
      if (widget.verificationJobId != null) {
        ref
            .read(verificationNotifierProvider.notifier)
            .startPollingVerificationJob(widget.verificationJobId!);
      }
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(currentProfileProvider);
    final verificationState = ref.watch(verificationNotifierProvider);
    final state = ref.watch(travelerVerificationStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final config = StatusConfig.from(state, context);

    final activeVerificationScore =
        verificationState.jobResult?.verificationScore ??
        verificationState.submitResult?.verificationScore;
    final failedStep = verificationState.verificationStatus?.failedStep;
    final reason =
        verificationState.verificationStatus?.errorReason ??
        verificationState.errorMessage;
    final uiMitigation = verificationState.verificationStatus?.uiMitigation;
    final errorReason = reason == uiMitigation ? null : reason;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'KYC',
          style: AppTypography.heading.copyWith(
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
            size: sizes.iconSm,
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
                padding: EdgeInsets.symmetric(
                  horizontal: space.stackSection,
                  vertical: space.stackFormField,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Horizontal Stepper Progress Indicator - Step 4 (All completed)
                    const KycProgressStepper(progressIndex: 4),
                    SizedBox(height: space.stackSection),

                    // Central Card Container
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.insetCardComfortable.left,
                        vertical: space.stackSection,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: shape.radiusControlSm,
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
                          SizedBox(height: space.stackSection),
                          // ── Title & Subtitle ──────────────────────────
                          Text(
                            config.title,
                            style: AppTypography.heading.copyWith(
                              fontSize: 18,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: space.stackItem),
                          Text(
                            config.subtitle,
                            style: AppTypography.body.copyWith(
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
                            SizedBox(height: space.stackFormField),
                            VerificationScoreIndicator(
                              score: activeVerificationScore,
                              isVerified:
                                  state == TravelerVerificationState.verified,
                            ),
                          ],
                          SizedBox(height: space.stackHero),
                          // ── Step Checklist ────────────────────────────
                          StepChecklist(
                            state: state,
                            isNfcSkipped: verificationState.isNfcSkipped,
                            hasNfcResult: verificationState.nfcResult != null,
                          ),
                          SizedBox(height: space.stackSection),
                          // ── Info Card ─────────────────────────────────
                          InfoCard(
                            state: state,
                            failedStep: failedStep,
                            errorReason: errorReason,
                            uiMitigation: uiMitigation,
                          ),
                          SizedBox(height: space.stackSection),
                          // ── Actions ───────────────────────────────────
                          VerificationStatusActions(state: state),
                        ],
                      ),
                    ),
                    SizedBox(height: space.stackHero),
                    // Footer text
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: space.stackFormField,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTypography.body.copyWith(
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
                                style: AppTypography.label.copyWith(
                                  color: context.colors.feedbackSuccess,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: space.stackFormField),
                  ],
                ),
              ),
            ),
    );
  }
}
