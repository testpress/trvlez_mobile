import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed when one specific step needs redoing during the final verification check.
///
/// Clearly indicates that all other steps remain saved and allows the traveler to jump
/// directly into retrying the single required action.
class NfcFailedScreen extends StatelessWidget {
  const NfcFailedScreen({
    super.key,
    this.failedStepTitle = 'Selfie',
    this.redoButtonLabel = 'Record the video again',
    this.redoRoute = AppRoutes.selfieInstructions,
  });

  final String failedStepTitle;
  final String redoButtonLabel;
  final String redoRoute;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc_scan.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 62.0,
            height: 62.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: Icon(
              AppIcons.refresh,
              size: 30.0,
              color: colors.brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'One step needs redoing',
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
            "Everything else is fine — we just couldn't read your face clearly in the video.",
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
          dimCompleted: true,
          rows: [
            VerifyStatusRow(title: 'Your details', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Passport photo', state: VerifyRowStatus.done),
            VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.redo),
            VerifyStatusRow(title: 'Chip scan', state: VerifyRowStatus.done),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.brandCardIconBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What usually fixes it',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: TypeScale.semiBold,
                  color: colors.brandOnSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Better light on your face, nothing covering it, and holding the phone at arm's length rather than close up.",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: TypeScale.regular,
                  color: colors.brandSecondaryBody,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: redoButtonLabel,
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            context.pushReplacement(redoRoute);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text: "Your other steps are saved. You won't repeat them.",
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.nfcFailed,
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
                    const TextSpan(text: 'Still stuck? '),
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
