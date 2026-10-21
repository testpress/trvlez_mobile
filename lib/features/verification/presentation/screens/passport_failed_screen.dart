import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    if (failureReason != null && failureReason!.isNotEmpty) {
      return failureReason!;
    }
    final effectivePhase = failurePhase ?? state.phase;
    if (effectivePhase == VerificationPhase.imageQualityFailed) {
      if (state.imageQualityResult?.uiGuidance != null &&
          state.imageQualityResult!.uiGuidance!.isNotEmpty) {
        return state.imageQualityResult!.uiGuidance!;
      }
      if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
        return state.errorMessage!;
      }
      return "Your passport photo isn't clear enough. Please ensure good lighting and no glare or blur.";
    }
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return state.errorMessage!;
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
        VerificationStepper(current: 0, circleSize: sizes.iconDefault),
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
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20.0,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space.stackItem),
          child: Text(
            _getExplanation(state),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: TypeScale.regular,
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
        SizedBox(height: space.stackText),
        AppButton(
          label: 'See the tips again',
          variant: AppButtonVariant.brandOutline,
          onPressed: () =>
              context.pushReplacement(AppRoutes.passportInstructions),
        ),
        SizedBox(height: space.stackItem),
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
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: space.inlineMicro),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Still stuck? '),
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
      ],
    );
  }
}
