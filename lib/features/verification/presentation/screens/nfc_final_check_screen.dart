import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed while the backend final decision engine processes all verification inputs.
///
/// Features the 3D twisting hourglass animation and live checklist showing 4 completed steps
/// and 1 running step.
class NfcFinalCheckScreen extends ConsumerStatefulWidget {
  const NfcFinalCheckScreen({super.key});

  @override
  ConsumerState<NfcFinalCheckScreen> createState() =>
      _NfcFinalCheckScreenState();
}

class _NfcFinalCheckScreenState extends ConsumerState<NfcFinalCheckScreen> {
  Timer? _decisionTimer;

  @override
  void initState() {
    super.initState();
    _decisionTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        context.pushReplacement(AppRoutes.verificationSuccess);
      }
    });
  }

  @override
  void dispose() {
    _decisionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);

    if (state.phase == VerificationPhase.verified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement(AppRoutes.verificationSuccess);
      });
    }

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        const VerificationStepper(current: 4, circleSize: 22.0),
        const SizedBox(height: AppSpacing.lg),
        const Center(child: VerifyHourglass()),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Checking everything',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20.0,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            "Usually under a minute. You can close the app — we'll let you know.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: TypeScale.regular,
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const VerifyStatusRows(
          rows: [
            VerifyStatusRow(title: 'Your details', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Passport photo', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Chip scan', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Final check', state: VerifyRowStatus.running),
          ],
        ),
      ],
      foot: [
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.nfcFinalCheck,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Taking too long? '),
                    TextSpan(
                      text: "Tell us what's wrong",
                      style: TextStyle(
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
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
