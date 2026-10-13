import 'dart:async';

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

/// Screen displaying the two sequential processing stages (Upload, Check) for selfie verification
/// driven by real-time backend state.
class SelfieProcessingScreen extends ConsumerStatefulWidget {
  const SelfieProcessingScreen({super.key});

  @override
  ConsumerState<SelfieProcessingScreen> createState() =>
      _SelfieProcessingScreenState();
}

class _SelfieProcessingScreenState
    extends ConsumerState<SelfieProcessingScreen> {
  bool _hasNavigated = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(verificationNotifierProvider);
      if (state.capturedVideo == null) {
        context.pushReplacement(AppRoutes.selfieCapture);
        return;
      }
      // If upload hasn't started yet, trigger it now
      if (state.phase != VerificationPhase.uploading &&
          state.phase != VerificationPhase.checkingVideoQuality) {
        ref.read(verificationNotifierProvider.notifier).uploadSelfie();
      }
    });
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  int _calculateDone(VerificationPhase phase) {
    return switch (phase) {
      VerificationPhase.uploading => 0,
      VerificationPhase.checkingVideoQuality => 1,
      VerificationPhase.uploadSuccess || VerificationPhase.verified => 2,
      _ => 0,
    };
  }

  String _calculateStatus(VerificationState state) {
    return switch (state.phase) {
      VerificationPhase.uploading =>
        state.uploadProgress > 0 && state.uploadProgress < 1.0
            ? 'Uploading ${(state.uploadProgress * 100).toInt()}%…'
            : 'Uploading securely…',
      VerificationPhase.checkingVideoQuality => "Checking it's you…",
      VerificationPhase.uploadSuccess ||
      VerificationPhase.verified => 'Face verified',
      VerificationPhase.videoQualityFailed ||
      VerificationPhase.error => 'Processing failed',
      _ => 'Uploading securely…',
    };
  }

  void _handleStateTransition(VerificationState next) {
    if (_hasNavigated || !mounted) return;

    if (next.phase == VerificationPhase.uploadSuccess) {
      _hasNavigated = true;
      _successTimer?.cancel();
      _successTimer = Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          context.pushReplacement(AppRoutes.selfieSuccess);
        }
      });
    } else if (next.phase == VerificationPhase.videoQualityFailed ||
        next.phase == VerificationPhase.error) {
      _hasNavigated = true;
      context.pushReplacement(AppRoutes.selfieFailed, extra: next.errorMessage);
    } else if (next.phase == VerificationPhase.verified) {
      _hasNavigated = true;
      context.pushReplacement(AppRoutes.verificationSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);

    ref.listen<VerificationState>(verificationNotifierProvider, (
      previous,
      next,
    ) {
      _handleStateTransition(next);
    });

    final doneCount = _calculateDone(state.phase);
    final currentStatus = _calculateStatus(state);

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
              i < doneCount ? TrioState.done : TrioState.waiting,
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
