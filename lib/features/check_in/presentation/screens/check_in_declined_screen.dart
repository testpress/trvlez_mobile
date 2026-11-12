import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_big_ring.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_bring_card.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.7: Calm decline state confirming that checking in at the front desk is fine.
class CheckInDeclinedScreen extends ConsumerWidget {
  const CheckInDeclinedScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final stateAsync = ref.watch(checkInNotifierProvider(reservationId));

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.brandSurface,
        body: const Center(child: LoadingView()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.brandSurface,
        body: Center(
          child: ErrorView.fromError(
            error: err,
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(reservationId)),
          ),
        ),
      ),
      data: (details) {
        return BrandVerifyScreen(
          title: 'Online check-in',
          backgroundAsset: 'assets/art/bg_checkin_declined.svg',
          helpArea: ProblemArea.checkIn,
          closeIcon: true,
          onBack: () => context.go(AppRoutes.bookings),
          isScrollable: true,
          foot: [
            AppButton(
              label: 'Back to my booking',
              variant: AppButtonVariant.brandWhite,
              onPressed: () => context.go(AppRoutes.bookings),
            ),
            SizedBox(height: space.stackFormField),
            AppButton(
              label: 'Review what Spain needs',
              variant: AppButtonVariant.brandOutline,
              onPressed: () => context.pushReplacement(
                AppRoutes.checkInDisclosurePath(reservationId),
              ),
            ),
            const CheckInNotice(
              text: 'Nothing was sent. Nothing was recorded.',
            ),
          ],
          children: [
            const CheckInBigRing(icon: AppIcons.buildingStore),
            SizedBox(height: space.stackFormField),
            Text(
              "You'll check in at the desk",
              textAlign: TextAlign.center,
              style: context.text.headlineMedium?.copyWith(
                color: colors.brandOnSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              "That's absolutely fine. Your booking is unaffected — ${details.hotel} is expecting you.",
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
            SizedBox(height: space.stackFormField),
            CheckInBringCard(
              title: 'Take with you',
              lines: [
                const CheckInBringLine(
                  icon: AppIcons.id,
                  lead: 'Your ',
                  strong: 'passport',
                ),
                CheckInBringLine(
                  icon: AppIcons.ticket,
                  lead: 'Booking ',
                  strong: details.reservation.confirmationCode,
                ),
              ],
            ),
            SizedBox(height: space.stackFormField),
            Text(
              'Changed your mind? You can check in online any time before you arrive.',
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }
}
