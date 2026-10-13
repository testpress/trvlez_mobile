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
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_field.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/disputes/presentation/providers/dispute_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.3b: Written explanation and photo evidence collection.
class DisputeDetailScreen extends ConsumerStatefulWidget {
  const DisputeDetailScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  ConsumerState<DisputeDetailScreen> createState() =>
      _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  final _wordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wordsController.addListener(() {
      ref.read(disputeDraftProvider.notifier).setWords(_wordsController.text);
    });
  }

  @override
  void dispose() {
    _wordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final draft = ref.watch(disputeDraftProvider);
    final reason = draft.reason ?? DisputeReason.somethingElse;

    return BrandVerifyScreen(
      title: 'Something wrong',
      backgroundAsset: 'assets/art/bg_checkin_steps.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Raise this',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            ref.read(disputesProvider.notifier).raiseDispute(draft);
            context.pushReplacement(
              AppRoutes.disputeRaisedPath(widget.reservationId),
            );
          },
        ),
        const CheckInNotice(
          text: 'We will email you. You can withdraw this at any time.',
        ),
      ],
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tell us what happened',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${reason.title} · ${draft.hotel}',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Text input for explanation
        CheckInField(
          label: 'In your own words',
          value: '',
          tall: true,
          controller: _wordsController,
          hint: reason.prompt,
        ),

        // Photo attachment row
        _AttachRow(
          count: draft.photoCount,
          onTap: () {
            ref.read(disputeDraftProvider.notifier).addPhoto();
          },
          onClear: () {
            ref.read(disputeDraftProvider.notifier).clearPhotos();
          },
        ),

        // Photo separation privacy callout
        const CheckInFlagCallout(
          icon: AppIcons.shieldLock,
          lead: 'Photos stay separate from your ID. ',
          body:
              'They are kept apart from your passport and selfie, used only to look into problems at this property, and held for 24 months.',
          marginTop: AppSpacing.md - 2,
        ),
      ],
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
    required this.count,
    required this.onTap,
    required this.onClear,
  });

  final int count;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final full = count >= 3;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      decoration: BoxDecoration(
        color: colors.checkInStepPanel,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.checkInRingPanel,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              AppIcons.camera,
              size: 14,
              color: colors.brandOnSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count > 0
                      ? '$count of 3 photos added'
                      : 'Add photos · optional',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                    color: colors.brandOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count > 0
                      ? 'Tap + to add more, or tap Clear'
                      : 'Photographs of the room or property',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: colors.brandSecondaryBody,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            GestureDetector(
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: TypeScale.semiBold,
                    color: colors.brandSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          if (!full)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.checkInRingPanel,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  '+ Photo',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: TypeScale.bold,
                    color: colors.brandOnSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
