import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying extracted read-only passport details for confirmation before moving to selfie.
///
/// Corresponds to Stepper Step 2 (Profile Review active).
class ConfirmDetailsScreen extends ConsumerStatefulWidget {
  const ConfirmDetailsScreen({super.key});

  @override
  ConsumerState<ConfirmDetailsScreen> createState() =>
      _ConfirmDetailsScreenState();
}

class _ConfirmDetailsScreenState extends ConsumerState<ConfirmDetailsScreen> {
  bool _isConfirming = false;

  Future<void> _handleConfirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    try {
      final notifier = ref.read(verificationNotifierProvider.notifier);
      await notifier.confirmMrz();
      if (!mounted) return;

      final updatedState = ref.read(verificationNotifierProvider);
      if (updatedState.phase == VerificationPhase.mrzReviewed ||
          updatedState.phase == VerificationPhase.uploadSuccess) {
        context.push(AppRoutes.selfieInstructions);
      } else if (updatedState.phase == VerificationPhase.verified) {
        context.pushReplacement(AppRoutes.verificationSuccess);
      } else if (updatedState.phase == VerificationPhase.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedState.errorMessage ?? 'Failed to confirm passport details',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final mrz = state.mrzExtractionResult;

    final firstName = mrz?.firstName?.isNotEmpty == true
        ? mrz!.firstName!
        : '—';
    final lastName = mrz?.lastName?.isNotEmpty == true ? mrz!.lastName! : '—';
    final docNumber = mrz?.documentNumber?.isNotEmpty == true
        ? mrz!.documentNumber!
        : (state.extractedDocumentNumber?.isNotEmpty == true
              ? state.extractedDocumentNumber!
              : '—');
    final nationality = mrz?.nationality?.isNotEmpty == true
        ? mrz!.nationality!
        : '—';
    final dob = mrz?.dateOfBirth?.isNotEmpty == true ? mrz!.dateOfBirth! : '—';
    final expiry = mrz?.dateOfExpiry?.isNotEmpty == true
        ? mrz!.dateOfExpiry!
        : '—';
    final sex = mrz?.sex?.isNotEmpty == true ? mrz!.sex! : '—';

    final rows = <(String, String)>[
      ('First name', firstName),
      ('Last name', lastName),
      ('Passport number', docNumber),
      ('Nationality', nationality),
      ('Date of birth', dob),
      ('Expiry', expiry),
      ('Sex', sex),
    ];

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_flow.svg',
      title: 'Verification',
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        VerificationStepper(current: 1, circleSize: sizes.iconDefault),
        const Spacer(flex: 1),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Confirm your details',
            style: context.text.headlineMedium?.copyWith(
              color: colors.brandOnSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(height: space.stackTight),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "We read these from your passport. Check they're right before we continue.",
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: shape.radiusControl,
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
          label: _isConfirming ? 'Confirming…' : 'Confirm and continue',
          variant: AppButtonVariant.brandWhite,
          onPressed: _isConfirming ? null : _handleConfirm,
        ),
        SizedBox(height: space.stackText),
        AppButton(
          label: 'Retake passport photo',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            notifier.clearImage();
            context.pushReplacement(AppRoutes.passportInstructions);
          },
        ),
        SizedBox(height: space.stackItem),
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
              padding: EdgeInsets.symmetric(vertical: space.stackText),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.text.bodySmall?.copyWith(
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Something wrong? '),
                    TextSpan(
                      text: "Tell us what's wrong",
                      style: TextStyle(
                        color: colors.brandSecondary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
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
