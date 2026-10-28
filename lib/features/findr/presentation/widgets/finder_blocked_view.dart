import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';

/// Informative view displayed when the caller does not meet backend eligibility rules.
class FinderBlockedView extends StatelessWidget {
  const FinderBlockedView({
    super.key,
    required this.eligibility,
    this.title,
    this.message,
    this.onActionCompleted,
  });

  final FinderEligibility eligibility;
  final String? title;
  final String? message;
  final VoidCallback? onActionCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final (icon, defaultTitle, defaultMessage, actionLabel, actionRoute) =
        _resolveBlockedContent(eligibility.reason);

    final displayTitle = title ?? defaultTitle;
    final displayMessage = message ?? defaultMessage;

    return SingleChildScrollView(
      padding: space.insetCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FindrHeading(),
          SizedBox(height: space.stackSection),
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: shape.radiusSurface,
              border: Border.all(
                color: colors.borderSubtle,
                width: shape.borderDefault,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: sizes.controlLg,
                  height: sizes.controlLg,
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: sizes.iconMd,
                    color: colors.brandPrimary,
                  ),
                ),
                SizedBox(height: space.stackItem),
                Text(
                  displayTitle,
                  style: context.text.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: TypeScale.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: space.stackText),
                Text(
                  displayMessage,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && actionRoute != null) ...[
                  SizedBox(height: space.stackSection),
                  AppButton(
                    label: actionLabel,
                    onPressed: () async {
                      await context.push(actionRoute);
                      onActionCompleted?.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, String, String, String?, String?) _resolveBlockedContent(
    FinderEligibilityReason reason,
  ) {
    return switch (reason) {
      FinderEligibilityReason.verificationIncomplete => (
          AppIcons.shield,
          'Passport Verification Required',
          'To activate your Findr status and earn rewards for hotel recommendations, you must complete biometric passport verification.',
          'Start Verification',
          AppRoutes.verificationLanding,
        ),
      FinderEligibilityReason.verificationExpired => (
          AppIcons.clock,
          'Passport Verification Expired',
          'Your verified passport document has expired. Please re-verify to restore your eligibility for the Findr programme.',
          'Re-verify Passport',
          AppRoutes.verificationLanding,
        ),
      FinderEligibilityReason.underage => (
          AppIcons.alertCircle,
          'Age Requirement (18+)',
          'Participants in the Findr rewards programme must be at least 18 years of age based on their verified date of birth.',
          null,
          null,
        ),
      FinderEligibilityReason.dateOfBirthMissing => (
          AppIcons.calendar,
          'Date of Birth Required',
          'We could not verify your date of birth from your traveler profile. Please complete passport verification to proceed.',
          'Verify Passport',
          AppRoutes.verificationLanding,
        ),
      FinderEligibilityReason.marketUnavailable => (
          AppIcons.mapPin,
          'Market Unavailable',
          'The Findr programme is not currently available in your country or region. We are expanding to new regions soon and will notify you when Findr launches in your area.',
          null,
          null,
        ),
      FinderEligibilityReason.programDisabled => (
          AppIcons.infoCircle,
          'Programme Unavailable',
          'The Findr programme is currently not accepting new applications. Please check back later.',
          null,
          null,
        ),
      FinderEligibilityReason.accountInactive => (
          AppIcons.lock,
          'Account Inactive',
          'Your account is currently inactive. Please contact TRVLez support to reactivate your account.',
          null,
          null,
        ),
      FinderEligibilityReason.terminalStatus => (
          AppIcons.circleX,
          'Membership Closed',
          'This account has previously been deactivated from the Findr programme and cannot be reactivated.',
          null,
          null,
        ),
      FinderEligibilityReason.addressRequired => (
          AppIcons.mapPin,
          'Address Required',
          'A verified residential address in an eligible market is required to complete activation.',
          null,
          null,
        ),
      FinderEligibilityReason.eligible => (
          AppIcons.checkCircle,
          'Eligible to Join',
          'You meet all requirements to become a Findr.',
          null,
          null,
        ),
    };
  }
}
