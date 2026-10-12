import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying the two sequential processing stages (Upload, Check) for selfie verification.
class SelfieProcessingScreen extends ConsumerStatefulWidget {
  const SelfieProcessingScreen({super.key});

  @override
  ConsumerState<SelfieProcessingScreen> createState() =>
      _SelfieProcessingScreenState();
}

class _SelfieProcessingScreenState
    extends ConsumerState<SelfieProcessingScreen> {
  int _done = 0;

  static const _stages = [
    (label: 'Upload', status: 'Uploading securely…'),
    (label: 'Check', status: "Checking it's you…"),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executeProcessing());
  }

  Future<void> _executeProcessing() async {
    try {
      // Stage 1: Uploading video
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() => _done = 1);

      // Stage 2: Face matching / liveness check
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      final state = ref.read(verificationNotifierProvider);

      if (state.phase == VerificationPhase.error ||
          state.phase == VerificationPhase.videoQualityFailed) {
        if (!mounted) return;
        context.pushReplacement(AppRoutes.selfieFailed);
        return;
      }

      if (!mounted) return;
      setState(() => _done = 2);

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      context.pushReplacement(AppRoutes.selfieSuccess);
    } catch (_) {
      if (mounted) {
        context.pushReplacement(AppRoutes.selfieFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);

    if (state.phase == VerificationPhase.error ||
        state.phase == VerificationPhase.videoQualityFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement(AppRoutes.selfieFailed);
      });
    }

    final currentStatus = _done < _stages.length
        ? _stages[_done].status
        : 'Face verified';

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_upload_check.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        const VerificationStepper(current: 2, circleSize: 23.0),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 80.0,
            height: 80.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardBackground,
            ),
            child: SvgPicture.asset(
              'assets/art/video_glyph.svg',
              width: 36.0,
              height: 36.0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        VerifyProgressTrio(
          labels: const ['Upload', 'Check'],
          states: [
            for (int i = 0; i < 2; i++)
              i < _done ? TrioState.done : TrioState.waiting,
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 28.0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                currentStatus,
                key: ValueKey<String>(currentStatus),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.0,
                  fontWeight: TypeScale.medium,
                  color: colors.brandSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
      foot: const [
        BrandSecurityNote(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
