import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_consent_tick.dart';
import 'package:trvlez_mobile/core/widgets/check_in_disclosure_card.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.3: Legal disclosure consent for destination authorities.
class CheckInDisclosureScreen extends ConsumerWidget {
  const CheckInDisclosureScreen({super.key, required this.reservationId});

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
          child: ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(reservationId)),
          ),
        ),
      ),
      data: (details) {
        final hotel = details.hotel;

        return BrandVerifyScreen(
          title: 'What Spain needs',
          backgroundAsset: 'assets/art/bg_checkin_steps.svg',
          helpArea: ProblemArea.checkIn,
          onBack: () => context.pop(),
          isScrollable: true,
          foot: [
            AppButton(
              label: 'Share and continue',
              variant: AppButtonVariant.brandWhite,
              enabled: details.disclosureAgreed,
              onPressed: () {
                ref
                    .read(checkInNotifierProvider(reservationId).notifier)
                    .completeStage(CheckInStage.requirement);
                context.pushReplacement(
                  AppRoutes.checkInGuestsPath(reservationId),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: space.stackFormField),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(checkInNotifierProvider(reservationId).notifier)
                        .declineCheckIn();
                    context.push(AppRoutes.checkInDeclinedPath(reservationId));
                  },
                  child: Text(
                    "Not now — I'll check in at the desk",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: colors.brandSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.brandUnderline,
                    ),
                  ),
                ),
              ),
            ),
            const CheckInNotice(
              text: "This goes in Who has your details,\nwith today's date.",
            ),
          ],
          children: [
            SizedBox(height: space.stackSection),
            Text(
              'Approve what we send',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 22,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              'Spanish law names these fields. We send exactly them and nothing else.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
            SizedBox(height: space.stackFormField),
            CheckInDisclosureCard(
              title: 'Sent to $hotel',
              lines: const [
                CheckInDisclosureLine('Full name'),
                CheckInDisclosureLine('Passport number'),
                CheckInDisclosureLine('Nationality'),
                CheckInDisclosureLine('Date of birth'),
                CheckInDisclosureLine('Dates of your stay'),
              ],
            ),
            const CheckInDisclosureCard(
              title: 'Still not sent',
              lines: [
                CheckInDisclosureLine('Your passport scan', shared: false),
                CheckInDisclosureLine('Your selfie video', shared: false),
                CheckInDisclosureLine(
                  'Anything about your other trips',
                  shared: false,
                ),
              ],
            ),
            CheckInConsentTick(
              agreed: details.disclosureAgreed,
              marginTop: space.stackSection,
              label:
                  'I agree to share these details with $hotel for this stay.',
              onTap: () {
                ref
                    .read(checkInNotifierProvider(reservationId).notifier)
                    .setDisclosureAgreed(!details.disclosureAgreed);
              },
            ),
          ],
        );
      },
    );
  }
}
