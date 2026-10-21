import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_step_tile.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.1: The primary check-in overview displaying hotel summary,
/// flag requirement callout, and 4-step sequence.
class CheckInStepsScreen extends ConsumerWidget {
  const CheckInStepsScreen({super.key, required this.reservationId});

  final String reservationId;

  CheckInStepState _stateFor(CheckInStage current, CheckInStage target) {
    if (target.index < current.index) return CheckInStepState.done;
    if (target.index == current.index) return CheckInStepState.now;
    return CheckInStepState.todo;
  }

  String _routeFor(CheckInStage stage, CheckInRequirement requirement) {
    return switch (stage) {
      CheckInStage.requirement =>
        requirement == CheckInRequirement.visa
            ? AppRoutes.checkInVisaPath(reservationId)
            : AppRoutes.checkInDisclosurePath(reservationId),
      CheckInStage.questions => AppRoutes.checkInQuestionsPath(reservationId),
      CheckInStage.key => AppRoutes.checkInDonePath(reservationId),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final stateAsync = ref.watch(checkInNotifierProvider(reservationId));

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.brandSurface,
        body: const Center(child: LoadingView()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.brandSurface,
        body: Center(
          child: ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(reservationId)),
          ),
        ),
      ),
      data: (details) {
        final step = details.currentStage;
        final requirement = details.requirement;

        return BrandVerifyScreen(
          title: 'Online check-in',
          backgroundAsset: 'assets/art/bg_checkin_steps.svg',
          helpArea: ProblemArea.checkIn,
          onBack: () => context.pop(),
          isScrollable: false,
          foot: [
            AppButton(
              label: 'Continue',
              variant: AppButtonVariant.brandWhite,
              onPressed: () => context.push(_routeFor(step, requirement)),
            ),
            CheckInNotice(text: requirement.notice),
          ],
          children: [
            SizedBox(height: space.stackFormField),
            Text(
              details.hotel,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 22,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              details.summary,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
            const Spacer(flex: 1),

            // Callout carries the requirement information
            CheckInFlagCallout(
              icon: requirement.flagIcon,
              lead: requirement.flagLead,
              body: requirement.flagBody,
              marginTop: space.stackItem,
            ),
            const Spacer(flex: 1),

            // Step 1: Already verified
            const CheckInStepTile(
              number: 1,
              state: CheckInStepState.done,
              title: 'Your identity',
              subtitle: 'Already verified',
            ),

            // Step 2: Destination requirement (Visa or Disclosure)
            CheckInStepTile(
              number: 2,
              state: _stateFor(step, CheckInStage.requirement),
              title: requirement.stepTitle,
              subtitle: requirement.stepSubtitle,
              onTap: () => context.push(
                requirement == CheckInRequirement.visa
                    ? AppRoutes.checkInVisaPath(reservationId)
                    : AppRoutes.checkInDisclosurePath(reservationId),
              ),
            ),

            // Step 3: Questions
            CheckInStepTile(
              number: 3,
              state: _stateFor(step, CheckInStage.questions),
              title: 'A few questions',
              subtitle: 'Arrival time and anything they should know',
              onTap: () =>
                  context.push(AppRoutes.checkInQuestionsPath(reservationId)),
            ),

            // Step 4: Key code
            CheckInStepTile(
              number: 4,
              state: _stateFor(step, CheckInStage.key),
              title: 'Get your key code',
              subtitle: 'Show it at the desk',
              onTap: () =>
                  context.push(AppRoutes.checkInDonePath(reservationId)),
            ),
            const Spacer(flex: 2),
          ],
        );
      },
    );
  }
}

extension on CheckInRequirement {
  IconData get flagIcon => switch (this) {
    CheckInRequirement.visa => AppIcons.fileText,
    CheckInRequirement.disclosure => AppIcons.scale,
  };
}
