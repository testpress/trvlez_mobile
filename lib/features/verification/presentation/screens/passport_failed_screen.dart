import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed when passport quality gate or MRZ reading encounters an issue.
///
/// Features a single-play 800ms wobble illustration, trio progress marking the failed stage,
/// supportive guidance blaming the lighting rather than the traveler, and clear recovery actions.
class PassportFailedScreen extends ConsumerWidget {
  const PassportFailedScreen({
    super.key,
    this.failureReason,
    this.failurePhase,
  });

  final String? failureReason;
  final VerificationPhase? failurePhase;

  String _getExplanation(VerificationState state) {
    final reason = failureReason;
    if (reason != null && reason.isNotEmpty) {
      return reason;
    }
    final effectivePhase = failurePhase ?? state.phase;
    if (effectivePhase == VerificationPhase.imageQualityFailed) {
      final guidance = state.imageQualityResult?.uiGuidance;
      if (guidance != null && guidance.isNotEmpty) {
        return guidance;
      }
      final errorMsg = state.errorMessage;
      if (errorMsg != null && errorMsg.isNotEmpty) {
        return errorMsg;
      }
      return "Your passport photo isn't clear enough. Please ensure good lighting and no glare or blur.";
    }
    final errorMsg = state.errorMessage;
    if (errorMsg != null && errorMsg.isNotEmpty) {
      return errorMsg;
    }
    return "We couldn't read the two lines at the bottom of the page. A little more light usually fixes it.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final effectivePhase = failurePhase ?? state.phase;
    final trioStates = effectivePhase == VerificationPhase.imageQualityFailed
        ? const [TrioState.done, TrioState.failed, TrioState.waiting]
        : const [TrioState.done, TrioState.done, TrioState.failed];

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_flow.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 0),
        SizedBox(height: space.stackHero),
        Center(
          child: VerifyWobble(
            child: SvgPicture.asset(
              'assets/art/passport_error.svg',
              width: 104.0,
              height: 104.0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: space.stackSection),
        VerifyProgressTrio(
          labels: const ['Upload', 'Check', 'Read'],
          states: trioStates,
        ),
        SizedBox(height: space.stackSection),
        Text(
          "Let's try that again",
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space.inlineIconLabel),
          child: Text(
            _getExplanation(state),
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Retake photo',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            ref.read(verificationNotifierProvider.notifier).clearImage();
            context.pushReplacement(AppRoutes.passportCapture);
          },
        ),
        SizedBox(height: space.stackItem),
        AppButton(
          label: 'See the tips again',
          variant: AppButtonVariant.brandOutline,
          onPressed: () =>
              context.pushReplacement(AppRoutes.passportInstructions),
        ),
        SizedBox(height: space.stackFormField),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.passportFailed,
                ),
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: sizes.touchTargetMin),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: context.text.bodySmall?.copyWith(
                      color: colors.brandSecondaryBody,
                    ),
                    children: [
                      const TextSpan(text: 'Still stuck? '),
                      TextSpan(
                        text: "Tell us what's wrong",
                        style: context.text.bodySmall?.copyWith(
                          color: colors.brandSecondary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
