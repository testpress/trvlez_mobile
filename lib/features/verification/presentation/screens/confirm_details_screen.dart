import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying extracted read-only passport details for confirmation before moving to selfie.
///
/// Corresponds to Stepper Step 2 (Profile Review active).
class ConfirmDetailsScreen extends ConsumerWidget {
  const ConfirmDetailsScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final mrz = state.mrzExtractionResult;

    final rows = <(String, String)>[
      ('First name', mrz?.firstName ?? 'AMARA CHIDINMA'),
      ('Last name', mrz?.lastName ?? 'OKAFOR'),
      ('Passport number', mrz?.documentNumber ?? state.extractedDocumentNumber ?? '536294145'),
      ('Nationality', mrz?.nationality ?? 'GBR'),
      ('Date of birth', mrz?.dateOfBirth ?? '14 Mar 1991'),
      ('Expiry', mrz?.dateOfExpiry ?? '22 Aug 2031'),
      ('Sex', mrz?.sex ?? 'F'),
    ];

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_flow.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 1, circleSize: 24.0),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Confirm your details',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20.0,
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "We read these from your passport. Check they're right before we continue.",
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
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 13.0,
          ),
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < rows.length; i++)
                VerifyDetailRow(
                  label: rows[i].$1,
                  value: rows[i].$2,
                  isLast: i == rows.length - 1,
                ),
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Confirm and continue',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            notifier.confirmMrz();
            context.push(AppRoutes.selfieInstructions);
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Re-upload passport',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            notifier.clearImage();
            context.pushReplacement(AppRoutes.passportInstructions);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.confirmDetails,
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
                    const TextSpan(text: 'Something wrong? '),
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
      ],
    );
  }
}
