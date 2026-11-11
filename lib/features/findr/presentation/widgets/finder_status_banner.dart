import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';

/// Contextual warning and lifecycle banner for re-verification prompts,
/// suspensions, and terminal states.
class FinderStatusBanner extends StatelessWidget {
  const FinderStatusBanner({
    super.key,
    required this.summary,
    this.onReverificationReturned,
  });

  final FinderStateSummary summary;
  final VoidCallback? onReverificationReturned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final finder = summary.finder;
    final status = finder?.status;

    // 1. Re-verification Required Banner
    if (summary.reverificationRequired ||
        finder?.verificationLapsedAt != null) {
      return Container(
        margin: EdgeInsets.only(bottom: space.stackFormField),
        padding: space.insetCard,
        decoration: BoxDecoration(
          color: colors.feedbackWarning.withValues(alpha: 0.1),
          borderRadius: shape.radiusSurface,
          border: Border.all(
            color: colors.feedbackWarning.withValues(alpha: 0.5),
            width: shape.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.alertTriangle,
                  size: sizes.iconMd,
                  color: colors.feedbackWarning,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    'Passport Re-Verification Required',
                    style: context.text.labelLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: space.stackText),
            Text(
              'Your passport document or verification status has expired. '
              'Please re-verify your passport to maintain full Finder privileges and rewards.',
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: space.stackItem),
            AppButton(
              label: 'Re-verify Passport',
              onPressed: () async {
                await context.push(AppRoutes.verificationLanding);
                onReverificationReturned?.call();
              },
            ),
          ],
        ),
      );
    }

    // 2. Temporary Suspension Banner
    if (status == FinderStatusType.suspendedTemporary) {
      final endsAt = finder?.suspensionEndsAt;
      final endsAtStr = endsAt != null
          ? DateFormat('d MMM yyyy').format(endsAt.toLocal())
          : 'scheduled review';

      return Container(
        margin: EdgeInsets.only(bottom: space.stackFormField),
        padding: space.insetCard,
        decoration: BoxDecoration(
          color: colors.feedbackWarning.withValues(alpha: 0.08),
          borderRadius: shape.radiusSurface,
          border: Border.all(
            color: colors.feedbackWarning.withValues(alpha: 0.4),
            width: shape.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.clock,
                  size: sizes.iconMd,
                  color: colors.feedbackWarning,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    'Membership Temporarily Suspended',
                    style: context.text.labelLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: space.stackText),
            Text(
              'New recommendations and activity are paused until $endsAtStr. '
              'Your existing profile and historical records remain preserved.',
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Permanent Suspension or Deactivation
    if (status == FinderStatusType.suspendedPermanent ||
        status == FinderStatusType.deactivated) {
      final title = status == FinderStatusType.suspendedPermanent
          ? 'Membership Permanently Suspended'
          : 'Membership Deactivated';

      return Container(
        margin: EdgeInsets.only(bottom: space.stackFormField),
        padding: space.insetCard,
        decoration: BoxDecoration(
          color: colors.feedbackError.withValues(alpha: 0.08),
          borderRadius: shape.radiusSurface,
          border: Border.all(
            color: colors.feedbackError.withValues(alpha: 0.4),
            width: shape.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.circleX,
                  size: sizes.iconMd,
                  color: colors.feedbackError,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    title,
                    style: context.text.labelLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: space.stackText),
            Text(
              'Your Finder account has been closed. You can no longer submit new recommendations. '
              'Historical association with previously confirmed hotels is retained.',
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
