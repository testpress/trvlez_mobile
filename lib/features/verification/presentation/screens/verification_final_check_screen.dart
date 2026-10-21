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
    extends ConsumerState<VerificationFinalCheckScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.verificationJobId != null) {
        ref
            .read(verificationNotifierProvider.notifier)
            .startPollingVerificationJob(widget.verificationJobId!);
      }
      final state = ref.read(verificationNotifierProvider);
      if (state.phase == VerificationPhase.verified ||
          state.verificationStatus?.isVerified == true) {
        _navigateToSuccess();
      } else if (state.phase == VerificationPhase.verificationFailed ||
          state.verificationStatus?.isFailed == true) {
        _handleFailure(state);
      } else if (state.phase == VerificationPhase.submitting ||
          state.phase == VerificationPhase.verifying) {
        // Polling already active or submission currently executing
      } else if (state.verificationStatus?.isProcessing == true) {
        ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
      } else if (state.phase == VerificationPhase.error) {
        // Already in error state, wait for user to retry
      } else {
        ref
            .read(verificationNotifierProvider.notifier)
            .submitVerificationAsync();
      }
    });
  }

  void _navigateToSuccess() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.pushReplacement(AppRoutes.verificationSuccess);
  }

  void _handleFailure(VerificationState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final status = state.verificationStatus;
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
      if (next.phase == VerificationPhase.verified) {
        _navigateToSuccess();
      } else if (next.phase == VerificationPhase.verificationFailed) {
        _handleFailure(next);
      }
    });

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: false,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
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
                AppButton(
                  label: 'Retry submission',
                  variant: AppButtonVariant.brandWhite,
                  onPressed: () {
                    ref
                        .read(verificationNotifierProvider.notifier)
                        .submitVerificationAsync();
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
    );
  }
}
