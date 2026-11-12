import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Transient celebration screen displayed briefly (~1.4s) when selfie verification succeeds.
///
/// Automatically transitions to the NFC chip scan step without requiring user interaction.
class SelfieSuccessScreen extends StatefulWidget {
  const SelfieSuccessScreen({super.key});

  @override
  State<SelfieSuccessScreen> createState() => _SelfieSuccessScreenState();
}

class _SelfieSuccessScreenState extends State<SelfieSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        context.pushReplacement(AppRoutes.nfcIntro);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_success.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        const VerificationStepper(current: 3),
        SizedBox(height: space.stackHero),
        Center(
          child: Container(
            width: sizes.pulseIndicator,
            height: sizes.pulseIndicator,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: Icon(
              AppIcons.check,
              size: sizes.iconXl,
              color: colors.brandPrimary,
            ),
          ),
        ),
        SizedBox(height: space.stackSection),
        const VerifyProgressTrio(
          labels: ['Upload', 'Check'],
          states: [TrioState.done, TrioState.done],
        ),
        SizedBox(height: space.stackSection),
        Text(
          'Selfie verified',
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          'Going to the chip scan…',
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: colors.brandSecondaryBody,
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
