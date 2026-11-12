import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
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

    void navigateHome() {
      ref.invalidate(currentProfileProvider);
      ref.invalidate(verificationStatusProvider);
      ref.read(authNotifierProvider.notifier).refreshVerificationState();
      context.go(AppRoutes.home);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        navigateHome();
      },
      child: BrandVerifyScreen(
        backgroundAsset: 'assets/art/bg_success.svg',
        title: 'Verification',
        helpLine: true,
        isScrollable: false,
        body: [
          const VerificationStepper(current: 4),
          const Spacer(flex: 3),
          Center(
            child: Container(
              width: sizes.thumbPhotoMd,
              height: sizes.thumbPhotoMd,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brandOnSurface,
              ),
              child: Icon(
                AppIcons.rosetteDiscountCheck,
                size: sizes.controlHero,
                color: colors.brandPrimary,
              ),
            ),
          ),
          const Spacer(flex: 3),
          Text(
            "You're verified",
            textAlign: TextAlign.center,
            style: context.text.headlineLarge?.copyWith(
              color: colors.brandOnSurface,
            ),
          ),
          SizedBox(height: space.stackTight),
          Text(
            expiryFormatted.isNotEmpty
                ? '$displayName · passport valid to $expiryFormatted'
                : displayName,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: colors.brandSecondaryBody,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: shape.radiusCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What this unlocks',
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.brandOnSurface,
                  ),
                ),
                SizedBox(height: space.stackItem),
                for (int i = 0; i < _unlocks.length; i++) ...[
                  if (i > 0) SizedBox(height: space.stackItem),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: sizes.iconDefault,
                        height: sizes.iconDefault,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.brandOnSurface.withValues(alpha: 0.18),
                        ),
                        child: Icon(
                          AppIcons.check,
                          size: sizes.iconXs,
                          color: colors.brandOnSurface,
                        ),
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _unlocks[i].title,
                              style: context.text.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.brandOnSurface,
                              ),
                            ),
                            Text(
                              _unlocks[i].subtitle,
                              style: context.text.bodySmall?.copyWith(
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
          const Spacer(flex: 1),
        ],
        foot: [
          AppButton(
            label: 'Start exploring',
            variant: AppButtonVariant.brandWhite,
            onPressed: navigateHome,
          ),
          SizedBox(height: space.stackItem),
          const BrandSecurityNote(
            text:
                'You control who sees your details.\nManage it any time in Account.',
          ),
        ],
      ),
    );
  }
}
