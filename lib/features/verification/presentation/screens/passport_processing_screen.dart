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
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying the three sequential processing stages (Upload, Check, Read)
/// with real-time state tracking and motion.
class PassportProcessingScreen extends ConsumerStatefulWidget {
  const PassportProcessingScreen({super.key, this.cropParams});

  final PassportCropParams? cropParams;

  @override
  ConsumerState<PassportProcessingScreen> createState() =>
      _PassportProcessingScreenState();
}

class _PassportProcessingScreenState
    extends ConsumerState<PassportProcessingScreen> {
  int _done = 0;

  static const _phases = [
    (label: 'Upload', status: 'Uploading securely…'),
    (label: 'Check', status: 'Checking the image is clear…'),
    (label: 'Read', status: 'Reading your details…'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executeProcessing());
  }

  Future<void> _executeProcessing() async {
    try {
      // Stage 1: Uploading
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _done = 1);

      // Stage 2: Quality check
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _done = 2);

      // Stage 3: Reading details / MRZ
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      final state = ref.read(verificationNotifierProvider);

      if (state.phase == VerificationPhase.error ||
          state.phase == VerificationPhase.imageQualityFailed ||
          state.phase == VerificationPhase.mrzExtractionFailed) {
        if (!mounted) return;
        context.pushReplacement(AppRoutes.passportFailed);
        return;
      }

      if (!mounted) return;
      setState(() => _done = 3);

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      context.pushReplacement(AppRoutes.confirmDetails);
    } catch (_) {
      if (mounted) {
        context.pushReplacement(AppRoutes.passportFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);

    if (state.phase == VerificationPhase.error ||
        state.phase == VerificationPhase.imageQualityFailed ||
        state.phase == VerificationPhase.mrzExtractionFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement(AppRoutes.passportFailed);
      });
    }

    final currentStatus = _done < _phases.length
        ? _phases[_done].status
        : 'Details verified';

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_flow.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        const VerificationStepper(current: 0, circleSize: 24.0),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: SvgPicture.asset(
            'assets/art/passport_processing.svg',
            width: 104.0,
            height: 104.0,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        VerifyProgressTrio(
          labels: const ['Upload', 'Check', 'Read'],
          states: [
            for (int i = 0; i < 3; i++)
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
          text: 'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
