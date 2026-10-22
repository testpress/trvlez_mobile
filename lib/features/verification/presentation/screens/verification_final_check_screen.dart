import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed while the backend final decision engine processes all verification inputs.
///
/// Submits verification asynchronously and polls for live status until completion.
/// When [verificationJobId] is provided or when verification is already in progress,
/// polls the backend for real-time verification pipeline updates.
class VerificationFinalCheckScreen extends ConsumerStatefulWidget {
  final String? verificationJobId;

  const VerificationFinalCheckScreen({super.key, this.verificationJobId});

  @override
  ConsumerState<VerificationFinalCheckScreen> createState() =>
      _VerificationFinalCheckScreenState();
}

class _VerificationFinalCheckScreenState
    extends ConsumerState<VerificationFinalCheckScreen>
    with WidgetsBindingObserver {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkStatusAndProceed();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _checkStatusAndProceed();
    }
  }

  void _checkStatusAndProceed() {
    if (_hasNavigated || !mounted) return;

    final state = ref.read(verificationNotifierProvider);
    final status = state.verificationStatus;

    if (state.phase == VerificationPhase.verified ||
        status?.isVerified == true) {
      _navigateToSuccess();
      return;
    }

    if (state.phase == VerificationPhase.verificationFailed ||
        status?.isFailed == true) {
      _handleFailure(state);
      return;
    }

    if (widget.verificationJobId != null) {
      ref
          .read(verificationNotifierProvider.notifier)
          .startPollingVerificationJob(widget.verificationJobId!);
      return;
    }

    if (state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying) {
      return;
    }

    if (status?.isProcessing == true) {
      ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
      return;
    }

    if (state.phase == VerificationPhase.error) {
      return;
    }

    final hasLocalDocuments =
        state.capturedImage != null || state.capturedVideo != null;
    if (hasLocalDocuments) {
      ref
          .read(verificationNotifierProvider.notifier)
          .submitVerificationAsync();
    } else {
      ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
    }
  }

  void _navigateToSuccess() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.pushReplacement(AppRoutes.verificationSuccess);
  }

  void _handleFailure(VerificationState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final status = state.verificationStatus ??
        ref.read(verificationStatusProvider).valueOrNull;
    final (title, route, label) = _resolveFailedStep(status?.failedStep);
    context.pushReplacement(
      AppRoutes.nfcFailed,
      extra: {
        'failedStepTitle': title,
        'redoButtonLabel': label,
        'redoRoute': route,
        'reason': state.errorMessage ?? status?.errorReason,
        'mitigation': status?.uiMitigation,
      },
    );
  }

  (String, String, String) _resolveFailedStep(String? failedStep) {
    if (failedStep == null) {
      return ('Verification check', AppRoutes.passportCapture, 'Start over');
    }
    final normalized = failedStep.toLowerCase();
    if (normalized.contains('selfie') ||
        normalized.contains('face') ||
        normalized.contains('liveness')) {
      return ('Selfie', AppRoutes.selfieCapture, 'Record the video again');
    }
    if (normalized.contains('chip') || normalized.contains('nfc')) {
      return ('Chip scan', AppRoutes.nfcScan, 'Try chip scan again');
    }
    if (normalized.contains('passport') ||
        normalized.contains('doc') ||
        normalized.contains('mrz')) {
      return ('Passport photo', AppRoutes.passportCapture, 'Retake photo');
    }
    return ('Verification check', AppRoutes.passportCapture, 'Start over');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);

    ref.listen<VerificationState>(verificationNotifierProvider, (
      previous,
      next,
    ) {
      if (next.phase == VerificationPhase.verified ||
          next.verificationStatus?.isVerified == true) {
        _navigateToSuccess();
      } else if (next.phase == VerificationPhase.verificationFailed ||
          next.verificationStatus?.isFailed == true) {
        _handleFailure(next);
      }
    });



    void navigateExit() {
      context.go(AppRoutes.home);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        navigateExit();
      },
      child: BrandVerifyScreen(
        backgroundAsset: 'assets/art/bg_nfc.svg',
        title: 'Verification',
        helpLine: false,
        isScrollable: false,
        onBack: navigateExit,
      body: [
        VerificationStepper(current: 4, circleSize: sizes.iconDefault),
        const Spacer(flex: 1),
        const Center(child: VerifyHourglass()),
        const Spacer(flex: 1),
        Text(
          'Checking everything',
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space.stackFormField),
          child: Text(
            "Usually under a minute. You can close the app — we'll let you know.",
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(flex: 1),
        VerifyStatusRows(
          rows: [
            const VerifyStatusRow(
              title: 'Your details',
              state: VerifyRowStatus.done,
            ),
            const VerifyStatusRow(
              title: 'Passport photo',
              state: VerifyRowStatus.done,
            ),
            const VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.done),
            if (!state.isNfcSkipped)
              const VerifyStatusRow(
                title: 'Chip scan',
                state: VerifyRowStatus.done,
              ),
            const VerifyStatusRow(
              title: 'Final check',
              state: VerifyRowStatus.running,
            ),
          ],
        ),
        if (state.phase == VerificationPhase.error) ...[
          SizedBox(height: space.stackFormField),
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: shape.radiusControl,
              border: Border.all(
                color: colors.brandDivider,
                width: shape.borderDefault,
              ),
            ),
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? 'Submission encountered an issue.',
                  textAlign: TextAlign.center,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.brandOnSurface,
                  ),
                ),
                SizedBox(height: space.stackItem),
                Builder(
                  builder: (context) {
                    final errorMsg = state.errorMessage?.toLowerCase() ?? '';
                    final isNoActiveSession = errorMsg.contains('session') ||
                        errorMsg.contains('active verification');
                    final canRetry = !isNoActiveSession;

                    if (canRetry) {
                      return Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Start over',
                              variant: AppButtonVariant.brandOutline,
                              onPressed: () {
                                ref
                                    .read(verificationNotifierProvider.notifier)
                                    .reset();
                                context.go(AppRoutes.passportCapture);
                              },
                            ),
                          ),
                          SizedBox(width: space.inlineButtonGroup),
                          Expanded(
                            child: AppButton(
                              label: 'Retry submission',
                              variant: AppButtonVariant.brandWhite,
                              onPressed: () {
                                ref
                                    .read(verificationNotifierProvider.notifier)
                                    .submitVerificationAsync();
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return AppButton(
                      label: 'Start over',
                      variant: AppButtonVariant.brandWhite,
                      onPressed: () {
                        ref
                            .read(verificationNotifierProvider.notifier)
                            .reset();
                        context.go(AppRoutes.passportCapture);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
      foot: [
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.verificationFinalCheck,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: space.inlineMicro),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.text.bodySmall?.copyWith(
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Taking too long? '),
                    TextSpan(
                      text: "Tell us what's wrong",
                      style: TextStyle(
                        color: colors.brandSecondary,
                        decoration: TextDecoration.underline,
                        fontWeight: TypeScale.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: space.stackItem),
        const BrandSecurityNote(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
    ),
  );
}
}
