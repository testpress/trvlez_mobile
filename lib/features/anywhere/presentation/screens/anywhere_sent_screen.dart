import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show liveFindrPortfolioProvider;
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_big_ring.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2e: Submission confirmation for check-in anywhere request.
class AnywhereSentScreen extends ConsumerWidget {
  const AnywhereSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final draft = ref.watch(anywhereDraftProvider);
    final findrPortfolio = ref.watch(liveFindrPortfolioProvider);
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
        SizedBox(height: space.stackSection),
        const CheckInBigRing(icon: AppIcons.check),
        SizedBox(height: space.stackFormField),
        Text(
          'Sent',
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'Your pass proves TRVLez has verified who you are.',
          textAlign: TextAlign.center,
          style: context.text.labelMedium?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        SizedBox(height: space.stackFormField),
        CheckInFlagCallout(
          icon: AppIcons.infoCircle,
          lead: 'Not confirmed yet. ',
          body:
              '$hotel has to reply, and we will tell you the moment they do. Show your pass at the desk — they may still ask for your passport.',
          marginTop: space.stackFormField,
        ),
      ],
    );
  }
}
