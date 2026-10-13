import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Screen celebrating full identity verification completion.
///
/// Features a large rosette verification icon, verified traveler metadata,
/// and a structured list of unlocked privileges.
class VerificationSuccessScreen extends ConsumerWidget {
  const VerificationSuccessScreen({super.key});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _unlocks = [
    (
      title: 'Book without re-checking',
      subtitle: 'No documents at every booking',
    ),
    (
      title: 'Walk past the front desk',
      subtitle: 'Check in online, collect your keys',
    ),
    (title: 'Findr', subtitle: 'Open to you now'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);
    final nfc = state.nfcResult;
    final mrz = state.mrzExtractionResult;

    final parsedMrz = nfc?.parsedMrz;
    final givenNames = parsedMrz?.firstName ?? mrz?.firstName ?? '';
    final surname = parsedMrz?.lastName ?? mrz?.lastName ?? '';
    final displayName = (givenNames.isNotEmpty || surname.isNotEmpty)
        ? '$givenNames $surname'.trim()
        : 'Verified Traveler';

    final expiryFormatted = parsedMrz != null
        ? '${_months[parsedMrz.dateOfExpiry.month - 1]} ${parsedMrz.dateOfExpiry.year}'
        : (mrz?.dateOfExpiry ?? '');

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_success.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      body: [
        const VerificationStepper(current: 4, circleSize: 23.0),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 86.0,
            height: 86.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: Icon(
              AppIcons.rosetteDiscountCheck,
              size: 44.0,
              color: colors.brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "You're verified",
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
        Text(
          expiryFormatted.isNotEmpty
              ? '$displayName · passport valid to $expiryFormatted'
              : displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What this unlocks',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: TypeScale.semiBold,
                  color: colors.brandOnSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (int i = 0; i < _unlocks.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16.0,
                      height: 16.0,
                      margin: const EdgeInsets.only(top: 2.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.brandOnSurface,
                      ),
                      child: Icon(
                        AppIcons.check,
                        size: 10.0,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _unlocks[i].title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.0,
                              fontWeight: TypeScale.semiBold,
                              color: colors.brandOnSurface,
                            ),
                          ),
                          Text(
                            _unlocks[i].subtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.0,
                              fontWeight: TypeScale.regular,
                              color: colors.brandSecondaryBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Start exploring',
          variant: AppButtonVariant.brandWhite,
          onPressed: () => context.go(AppRoutes.home),
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text:
              'You control who sees your details.\nManage it any time in Account.',
        ),
      ],
    );
  }
}
