import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying the three sequential processing stages (Upload, Check, Read)
/// driven by real-time backend verification state.
class PassportProcessingScreen extends ConsumerStatefulWidget {
  const PassportProcessingScreen({super.key, this.cropParams});

  final PassportCropParams? cropParams;

  @override
  ConsumerState<PassportProcessingScreen> createState() =>
      _PassportProcessingScreenState();
}

class _PassportProcessingScreenState
    extends ConsumerState<PassportProcessingScreen> {
  bool _hasNavigated = false;
  Timer? _successTimer;

  bool _isTerminalPhase(VerificationPhase phase) {
    return phase == VerificationPhase.uploadSuccess ||
        phase == VerificationPhase.imageQualityFailed ||
        phase == VerificationPhase.mrzExtractionFailed ||
        phase == VerificationPhase.error ||
        phase == VerificationPhase.verified;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(verificationNotifierProvider);
      if (state.capturedImage == null) {
        context.pushReplacement(AppRoutes.passportCapture);
        return;
      }
      // If state already reached a terminal phase before or during mount, transition immediately
      if (_isTerminalPhase(state.phase)) {
        _handleStateTransition(state);
        return;
      }
      // If upload hasn't started yet, trigger it now
      if (state.phase == VerificationPhase.idle) {
        ref.read(verificationNotifierProvider.notifier).uploadPassport();
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
      VerificationPhase.idle || VerificationPhase.preparingImage => 0,
      VerificationPhase.uploading ||
      VerificationPhase.checkingImageQuality => 1,
      VerificationPhase.extractingMrz => 2,
      VerificationPhase.uploadSuccess ||
      VerificationPhase.mrzReviewed ||
      VerificationPhase.verified => 3,
      _ => 0,
    };
  }

  String _calculateStatus(VerificationState state) {
    return switch (state.phase) {
      VerificationPhase.preparingImage => 'Preparing image…',
      VerificationPhase.uploading =>
        state.uploadProgress > 0 && state.uploadProgress < 1.0
            ? 'Uploading ${(state.uploadProgress * 100).toInt()}%…'
            : 'Uploading securely…',
      VerificationPhase.checkingImageQuality => 'Checking the image is clear…',
      VerificationPhase.extractingMrz => 'Reading your details…',
      VerificationPhase.uploadSuccess ||
      VerificationPhase.mrzReviewed ||
      VerificationPhase.verified => 'Details verified',
      VerificationPhase.imageQualityFailed ||
      VerificationPhase.mrzExtractionFailed ||
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
          context.pushReplacement(AppRoutes.confirmDetails);
        }
      });
    } else if (next.phase == VerificationPhase.imageQualityFailed ||
        next.phase == VerificationPhase.mrzExtractionFailed ||
        next.phase == VerificationPhase.error) {
      _hasNavigated = true;
      context.pushReplacement(
        AppRoutes.passportFailed,
        extra: {'reason': next.errorMessage, 'phase': next.phase.name},
      );
    } else if (next.phase == VerificationPhase.verified) {
      _hasNavigated = true;
      context.pushReplacement(AppRoutes.verificationSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
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
      backgroundAsset: 'assets/art/bg_passport_flow.svg',
      title: 'Verification',
      isScrollable: false,
      body: [
        const VerificationStepper(current: 0),
        const Spacer(flex: 3),
        Center(
          child: SvgPicture.asset(
            'assets/art/passport_processing.svg',
            width: sizes.thumbPhotoLg,
            height: sizes.thumbPhotoLg,
            fit: BoxFit.contain,
          ),
        ),
        const Spacer(flex: 3),
        VerifyProgressTrio(
          labels: const ['Upload', 'Check', 'Read'],
          states: [
            for (int i = 0; i < 3; i++)
              i < doneCount ? TrioState.done : TrioState.waiting,
          ],
        ),
        const Spacer(flex: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            currentStatus,
            key: ValueKey<String>(currentStatus),
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
            ),
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'This usually takes a few seconds.',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        const Spacer(flex: 2),
      ],
      foot: const [
        BrandSecurityNote(
          text:
              'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
