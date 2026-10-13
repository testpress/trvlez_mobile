import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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

  int _calculateDoneSteps(VerificationState state) {
    if (state.phase == VerificationPhase.verified) return 4;
    if (state.nfcResult != null || state.isNfcSkipped) return 3;
    if (state.capturedVideo != null ||
        state.phase == VerificationPhase.videoQualityFailed ||
        state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying) {
      return 2;
    }
    if (state.mrzExtractionResult != null ||
        state.extractedDocumentNumber != null ||
        state.phase == VerificationPhase.mrzReviewed ||
        state.phase == VerificationPhase.confirmingMrz) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);
    final doneCount = _calculateDoneSteps(state).clamp(0, 4);

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
      isScrollable: true,
      body: [
        VerificationStepper(current: doneCount, circleSize: 26.0),
        const SizedBox(height: AppSpacing.md),

        // Welcome Header with Wordmark inline
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6.0,
          children: [
            Text(
              'Welcome to',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18.0,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
                height: 1.2,
              ),
            ),
            const BrandWordmark(planeWidth: 12.0, gap: 3.0, fontSize: 18.0),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          'Verify your identity to unlock full access.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Progress indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$doneCount of 4 steps completed',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: TypeScale.medium,
                color: colors.brandOnSurface,
              ),
            ),
            Text(
              '${(doneCount / 4 * 100).round()}%',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: TypeScale.semiBold,
                color: colors.brandSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: colors.verificationProgressTrack,
            borderRadius: BorderRadius.circular(AppRadius.pill),
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
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 4 Step Cards
        for (int i = 0; i < _steps.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _StepCard(
            index: i,
            isDone: i < doneCount,
            isActive: i == doneCount,
            stepData: _steps[i],
            onTap: i <= doneCount ? () => context.push(_steps[i].route) : null,
          ),
        ],
      ],
      foot: const [
        BrandSecurityNote(
          text:
              'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
          fontSize: 10.0,
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
          borderRadius: BorderRadius.circular(14.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isActive
                  ? colors.verificationCardActiveFill
                  : colors.brandCardBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: isActive
                  ? Border.all(color: colors.brandOnSurface, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isActive || isDone)
                        ? colors.brandOnSurface
                        : colors.verificationCardIconFill,
                  ),
                  child: Icon(
                    icon,
                    size: 16.0,
                    color: (isActive || isDone)
                        ? colors.brandPrimary
                        : colors.verificationStepInactiveText,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepData.title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: TypeScale.semiBold,
                          color: isLocked
                              ? colors.verificationCardLockedTitle
                              : colors.brandOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        stepData.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.0,
                          fontWeight: TypeScale.regular,
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
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    AppIcons.chevronRight,
                    size: 18.0,
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
