import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed when the selfie video check does not succeed.
///
/// Features a wobbling face illustration, 2-stage trio with check failure,
/// compassionate lighting explanation, and retry/tips actions.
class SelfieFailedScreen extends ConsumerWidget {
  const SelfieFailedScreen({super.key, this.failureReason});

  final String? failureReason;

  String _getExplanation(String? errorFromState) {
    if (failureReason != null && failureReason!.isNotEmpty) {
      return failureReason!;
    }
    if (errorFromState != null && errorFromState.isNotEmpty) {
      return errorFromState;
    }
    return "We couldn't get a clear enough look at your face. A little more light usually fixes it.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 2),
        SizedBox(height: space.stackHero),
        Center(
          child: VerifyWobble(
            child: SvgPicture.asset(
              'assets/art/selfie_error.svg',
              width: 104.0,
              height: 104.0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: space.stackSection),
        const VerifyProgressTrio(
          labels: ['Upload', 'Check'],
          states: [TrioState.done, TrioState.failed],
        ),
        SizedBox(height: space.stackSection),
        Text(
          "Let's try that again",
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space.stackItem),
          child: Text(
            _getExplanation(state.errorMessage),
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
          label: 'Record again',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            ref.read(verificationNotifierProvider.notifier).clearVideo();
            context.pushReplacement(AppRoutes.selfieCapture);
          },
        ),
        SizedBox(height: space.stackItem),
        AppButton(
          label: 'See the tips again',
          variant: AppButtonVariant.brandOutline,
          onPressed: () =>
              context.pushReplacement(AppRoutes.selfieInstructions),
        ),
        SizedBox(height: space.stackFormField),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.selfieFailed,
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
                          fontWeight: TypeScale.medium,
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
