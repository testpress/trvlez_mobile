import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
        helpLine: false,
        isScrollable: false,
        body: [
          VerificationStepper(current: 4, circleSize: sizes.iconDefault),
          const Spacer(flex: 1),
          Center(
            child: Container(
              width: sizes.avatarXl + space.stackText,
              height: sizes.avatarXl + space.stackText,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brandOnSurface,
              ),
              child: Icon(
                AppIcons.rosetteDiscountCheck,
                size: sizes.controlMd,
                color: colors.brandPrimary,
              ),
            ),
          ),
          const Spacer(flex: 1),
          Text(
            "You're verified",
            textAlign: TextAlign.center,
            style: context.text.headlineMedium?.copyWith(
              color: colors.brandOnSurface,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            expiryFormatted.isNotEmpty
                ? '$displayName · passport valid to $expiryFormatted'
                : displayName,
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(
              color: colors.brandSecondaryBody,
            ),
          ),
          const Spacer(flex: 1),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: space.inlineButtonGroup,
              horizontal: space.stackFormField,
            ),
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: shape.radiusControl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What this unlocks',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: TypeScale.semiBold,
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
                        width: space.inlineItem,
                        height: space.inlineItem,
                        margin: EdgeInsets.only(top: space.stackText / 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.brandOnSurface,
                        ),
                        child: Icon(
                          AppIcons.check,
                          size: sizes.indicatorDot + space.stackText / 2,
                          color: colors.brandPrimary,
                        ),
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _unlocks[i].title,
                              style: context.text.labelMedium?.copyWith(
                                fontWeight: TypeScale.semiBold,
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
