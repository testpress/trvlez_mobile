import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_wordmark.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

const _steps = [
  (
    icon: AppIcons.camera,
    title: 'Upload Passport',
    subtitle: 'Capture a clear photo of your passport.',
    route: AppRoutes.passportInstructions,
  ),
  (
    icon: AppIcons.id,
    title: 'Review Details',
    subtitle: 'Verify your extracted passport information.',
    route: AppRoutes.confirmDetails,
  ),
  (
    icon: AppIcons.moodSmile,
    title: 'Selfie Verification',
    subtitle: 'Record a short video to verify your identity.',
    route: AppRoutes.selfieInstructions,
  ),
  (
    icon: AppIcons.nfc,
    title: 'NFC Verification',
    subtitle: 'Scan your passport chip for extra security.',
    route: AppRoutes.nfcIntro,
  ),
];

/// The central verification hub displaying step-by-step progress cards.
class VerificationLandingScreen extends ConsumerStatefulWidget {
  const VerificationLandingScreen({super.key});

  @override
  ConsumerState<VerificationLandingScreen> createState() =>
      _VerificationLandingScreenState();
}

class _VerificationLandingScreenState
    extends ConsumerState<VerificationLandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationNotifierProvider.notifier).reconcileWithBackend();
    });
  }

  int _calculateDoneSteps({
    required VerificationState state,
    required TravelerVerificationState travelerState,
  }) {
    if (state.phase == VerificationPhase.verified ||
        state.verificationStatus?.isVerified == true ||
        travelerState.isVerified) {
      return 4;
    }
    if (state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying ||
        state.jobResult != null ||
        travelerState == TravelerVerificationState.submitted ||
        state.nfcResult != null ||
        state.isNfcSkipped) {
      return 4;
    }
    if (state.capturedVideo != null ||
        state.phase == VerificationPhase.uploadSuccess ||
        travelerState == TravelerVerificationState.documentsUploaded) {
      return 3;
    }
    if (state.phase == VerificationPhase.mrzReviewed ||
        travelerState == TravelerVerificationState.passportReviewed) {
      return 2;
    }
    if (state.capturedImage != null ||
        state.mrzExtractionResult != null ||
        state.extractedDocumentNumber != null ||
        state.phase == VerificationPhase.confirmingMrz ||
        state.imageQualityResult?.isAcceptable == true) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final travelerState = ref.watch(travelerVerificationStateProvider);
    final isVerified =
        travelerState.isVerified ||
        state.phase == VerificationPhase.verified ||
        state.verificationStatus?.isVerified == true;
    final isSubmitted =
        travelerState.isProcessing ||
        state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying;

    final doneCount = _calculateDoneSteps(
      state: state,
      travelerState: travelerState,
    ).clamp(0, 4);

    final isFlowFinished = isVerified || isSubmitted || doneCount >= 4;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_verification_landing.svg',
      title: 'Verification',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      isScrollable: false,
      body: [
        VerificationStepper(current: doneCount),
        const Spacer(flex: 2),

        // Welcome Header
        if (isVerified) ...[
          Text(
            'Identity verified',
            style: context.text.headlineMedium?.copyWith(
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
              height: 1.2,
            ),
          ),
          SizedBox(height: space.stackTight),
          Text(
            'Your identity has been confirmed. You have full access.',
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ] else if (isSubmitted) ...[
          Text(
            'Verification in review',
            style: context.text.headlineMedium?.copyWith(
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
              height: 1.2,
            ),
          ),
          SizedBox(height: space.stackTight),
          Text(
            'All documents submitted. We are reviewing your details.',
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ] else ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: space.inlineIconLabel,
            children: [
              Text(
                'Welcome to',
                style: context.text.headlineMedium?.copyWith(
                  fontWeight: TypeScale.bold,
                  color: colors.brandOnSurface,
                  height: 1.2,
                ),
              ),
              BrandWordmark(
                planeWidth: space.inlineItem,
                gap: space.inlineMicro,
                fontSize: context.text.headlineMedium?.fontSize,
              ),
            ],
          ),
          SizedBox(height: space.stackTight),
          Text(
            'Verify your identity to unlock full access.',
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ],
        const Spacer(flex: 2),

        // Progress indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$doneCount of 4 steps completed',
              style: context.text.bodySmall?.copyWith(
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
              ),
            ),
            Text(
              '${(doneCount / 4 * 100).round()}%',
              style: context.text.bodySmall?.copyWith(
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: space.stackTight),
        Container(
          height: sizes.indicatorProgressHeight,
          decoration: BoxDecoration(
            color: colors.verificationProgressTrack,
            borderRadius: shape.radiusPill,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 450),
              curve: const Cubic(0.4, 0.0, 0.2, 1.0),
              widthFactor: doneCount / 4,
              heightFactor: 1.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.brandOnSurface,
                  borderRadius: shape.radiusPill,
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),

        // 4 Step Cards
        for (int i = 0; i < _steps.length; i++) ...[
          if (i > 0) SizedBox(height: space.stackItem),
          _StepCard(
            index: i,
            isDone: i < doneCount,
            isActive: !isFlowFinished && i == doneCount,
            stepData: _steps[i],
            onTap: (!isFlowFinished && i == doneCount)
                ? () => context.push(_steps[i].route)
                : null,
          ),
        ],
        const Spacer(flex: 1),
      ],
      foot: [
        if (isVerified)
          AppButton(
            label: 'View verification status',
            variant: AppButtonVariant.brandWhite,
            onPressed: () => context.push(AppRoutes.verificationStatus),
          )
        else if (isSubmitted)
          AppButton(
            label: 'Check status',
            variant: AppButtonVariant.brandWhite,
            onPressed: () => context.push(AppRoutes.verificationStatus),
          ),
        if (isVerified || isSubmitted) SizedBox(height: space.stackItem),
        const BrandSecurityNote(
          text:
              'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.isDone,
    required this.isActive,
    required this.stepData,
    this.onTap,
  });

  final int index;
  final bool isDone;
  final bool isActive;
  final ({IconData icon, String subtitle, String title, String route}) stepData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final isLocked = !isActive && !isDone;

    final IconData icon = isDone
        ? AppIcons.check
        : (isLocked ? AppIcons.lock : stepData.icon);

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '${stepData.title}. ${stepData.subtitle}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape.radiusSurface,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: isActive
                  ? colors.verificationCardActiveFill
                  : colors.brandCardBackground,
              borderRadius: shape.radiusSurface,
              border: isActive
                  ? Border.all(
                      color: colors.brandOnSurface,
                      width: shape.borderMedium,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: sizes.avatarMd,
                  height: sizes.avatarMd,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isActive || isDone)
                        ? colors.brandOnSurface
                        : colors.verificationCardIconFill,
                  ),
                  child: Icon(
                    icon,
                    size: sizes.iconSm,
                    color: (isActive || isDone)
                        ? colors.brandPrimary
                        : colors.brandOnSurface,
                  ),
                ),
                SizedBox(width: space.inlineButtonGroup),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepData.title,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: TypeScale.bold,
                          color: isLocked
                              ? colors.verificationCardLockedTitle
                              : colors.brandOnSurface,
                        ),
                      ),
                      SizedBox(height: space.stackText / 2),
                      Text(
                        stepData.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: isLocked
                              ? colors.verificationCardLockedSubtitle
                              : colors.brandSecondaryBody,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive) ...[
                  SizedBox(width: space.inlineMicro),
                  Icon(
                    AppIcons.chevronRight,
                    size: sizes.iconSm,
                    color: colors.brandOnSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
