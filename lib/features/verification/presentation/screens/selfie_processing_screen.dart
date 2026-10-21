import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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

  bool _isTerminalPhase(VerificationPhase phase) {
    return phase == VerificationPhase.uploadSuccess ||
        phase == VerificationPhase.videoQualityFailed ||
        phase == VerificationPhase.error ||
        phase == VerificationPhase.verified;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(verificationNotifierProvider);
      if (state.capturedVideo == null) {
        context.pushReplacement(AppRoutes.selfieCapture);
        return;
      }
      if (_isTerminalPhase(state.phase)) {
        _handleStateTransition(state);
        return;
      }
      // If upload hasn't started yet, trigger it now
      if (state.phase == VerificationPhase.idle) {
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
      backgroundAsset: 'assets/art/bg_upload_check.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        VerificationStepper(current: 2, circleSize: sizes.iconDefault),
        SizedBox(height: space.stackHero),
        Center(
          child: Container(
            width: sizes.avatarXl,
            height: sizes.avatarXl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardBackground,
            ),
            child: SvgPicture.asset(
              'assets/art/video_glyph.svg',
              width: sizes.avatarMd,
              height: sizes.avatarMd,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: space.stackSection),
        VerifyProgressTrio(
          labels: const ['Upload', 'Check'],
          states: [
            for (int i = 0; i < 2; i++)
              i < doneCount ? TrioState.done : TrioState.waiting,
          ],
        ),
        SizedBox(height: space.stackSection),
        SizedBox(
          height: sizes.avatarSm,
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
