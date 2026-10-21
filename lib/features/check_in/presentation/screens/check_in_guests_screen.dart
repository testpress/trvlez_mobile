import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_info_card.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/invite_guest_sheet.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_guest_row.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.4: Overview of travelers on the booking and invitation status for additional guests.
class CheckInGuestsScreen extends ConsumerWidget {
  const CheckInGuestsScreen({super.key, required this.reservationId});

  final String reservationId;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'AO';
  }

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
          child: ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(reservationId)),
          ),
        ),
      ),
      data: (details) {
        final adults = details.numberOfGuests > 0 ? details.numberOfGuests : 2;
        final invitedAdults = details.invitedAdults;
        final allInvited =
            adults <= 1 ||
            List.generate(
              adults - 1,
              (i) => i + 1,
            ).every((idx) => invitedAdults.contains(idx));

        void onwards() {
          ref
              .read(checkInNotifierProvider(reservationId).notifier)
              .completeStage(CheckInStage.requirement);
          context.pushReplacement(
            AppRoutes.checkInQuestionsPath(reservationId),
          );
        }

        void openInviteSheet([int adultIndex = 1]) {
          InviteGuestSheet.show(
            context,
            reservationId: reservationId,
            bookingReference: details.reservation.confirmationCode,
            adultIndex: adultIndex,
            onInvited: () {
              ref
                  .read(checkInNotifierProvider(reservationId).notifier)
                  .inviteGuest(adultIndex);
            },
          );
        }

        final bookerName = details.reservation.guestName.isNotEmpty
            ? details.reservation.guestName
            : 'Amara Okafor';

        return BrandVerifyScreen(
          title: 'Online check-in',
          backgroundAsset: 'assets/art/bg_checkin_visa.svg',
          helpArea: ProblemArea.checkIn,
          onBack: () => context.pop(),
          isScrollable: true,
          foot: [
            AppButton(
              label: allInvited
                  ? 'Continue'
                  : (adults > 2 ? 'Invite next adult' : 'Invite second guest'),
              variant: AppButtonVariant.brandWhite,
              onPressed: allInvited ? onwards : () => openInviteSheet(1),
            ),
            SizedBox(height: space.stackItem),
            AppButton(
              label: 'Finish without them',
              variant: AppButtonVariant.brandOutline,
              onPressed: onwards,
            ),
            const CheckInNotice(text: "Each guest's documents stay their own."),
          ],
          children: [
            SizedBox(height: space.stackItem),
            Text(
              "Who's staying",
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 22,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: space.stackText),
            Text(
              "The hotel needs ID for every adult guest. Each person verifies themselves — you won't see their documents.",
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
            SizedBox(height: space.stackText),

            // Booker Row
            CheckInGuestRow(
              initials: _getInitials(bookerName),
              name: bookerName,
              detail: 'You · passport verified',
              chip: 'Ready',
              ready: true,
            ),

            // Secondary Adult Guest Rows
            for (int i = 1; i < adults; i++) ...[
              CheckInGuestRow(
                initials: null,
                name: adults > 2 ? 'Adult ${i + 1}' : 'Second guest',
                detail: invitedAdults.contains(i)
                    ? 'Invited · waiting for them'
                    : 'Not invited yet',
                chip: invitedAdults.contains(i) ? 'Sent' : 'Invite',
                ready: false,
                onTap: invitedAdults.contains(i)
                    ? null
                    : () => openInviteSheet(i),
              ),
            ],

            CheckInFlagCallout(
              icon: AppIcons.infoCircle,
              lead: '1 of $adults ${adults == 1 ? 'guest' : 'guests'} ready. ',
              body:
                  'You can finish check-in now — anyone not verified will show ID at the desk as usual.',
              marginTop: space.stackFormField,
              centreIcon: true,
            ),
            SizedBox(height: space.stackItem),

            const BrandInfoCard(
              bullets: [
                BrandBullet(
                  icon: AppIcons.send,
                  text: 'Send them a link by message or email',
                ),
                BrandBullet(
                  icon: AppIcons.shieldLock,
                  text: 'They verify on their own phone, privately',
                ),
                BrandBullet(
                  icon: AppIcons.qrcode,
                  text: 'Both of you appear on the same key code',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
