import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_big_ring.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2e: Submission confirmation for check-in anywhere request.
class AnywhereSentScreen extends ConsumerWidget {
  const AnywhereSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final draft = ref.watch(anywhereDraftProvider);
    final findrPortfolio = ref.watch(findrPortfolioProvider);
    final hotel = draft.hotelName.isNotEmpty ? draft.hotelName : 'The hotel';

    return BrandVerifyScreen(
      title: 'Check in anywhere',
      backgroundAsset: 'assets/art/bg_anywhere_sent.svg',
      helpArea: ProblemArea.checkIn,
      closeIcon: true,
      onBack: () => context.go(AppRoutes.bookings),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Show my pass',
          variant: AppButtonVariant.brandWhite,
          onPressed: () => context.go(AppRoutes.bookings),
        ),
        CheckInNotice(
          text: findrPortfolio.joined
              ? 'If $hotel joins TRVLez, the introduction is yours.'
              : 'If $hotel joins TRVLez, you earn Findr credit.',
        ),
      ],
      children: [
        const SizedBox(height: AppSpacing.sm),
        const CheckInBigRing(icon: AppIcons.check),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sent',
          textAlign: TextAlign.center,
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
          'Your pass proves TRVLez has verified who you are.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CheckInFlagCallout(
          icon: AppIcons.infoCircle,
          lead: 'Not confirmed yet. ',
          body:
              '$hotel has to reply, and we will tell you the moment they do. Show your pass at the desk — they may still ask for your passport.',
          marginTop: AppSpacing.xs,
        ),
      ],
    );
  }
}
