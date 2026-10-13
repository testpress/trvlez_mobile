import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.6a: Check-in completion celebrating successful arrival with offline QR pass.
class CheckInDoneScreen extends ConsumerWidget {
  const CheckInDoneScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final stateAsync = ref.watch(checkInNotifierProvider(reservationId));
    final tokenState = ref.watch(checkInTokenProvider(reservationId));

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
        final bookingRef = details.reservation.confirmationCode;
        final token = tokenState.valueOrNull;

        return BrandVerifyScreen(
          title: "You're checked in",
          backgroundAsset: 'assets/art/bg_checkin_flow.svg',
          helpArea: ProblemArea.checkIn,
          closeIcon: true,
          onBack: () => context.go(AppRoutes.bookings),
          isScrollable: true,
          foot: [
            AppButton(
              label: 'Add to wallet',
              variant: AppButtonVariant.brandOutline,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: colors.surface,
                    content: Text(
                      'Wallet passes are not wired up in this build.',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ),
                );
              },
            ),
            const CheckInNotice(
              text: 'The code works offline. Screenshot it if you like.',
            ),
          ],
          children: [
            const SizedBox(height: AppSpacing.sm),
            // White check circle
            Center(
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brandOnSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.check,
                  size: 26,
                  color: colors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Show this at the desk',
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
              'Collect your keys and go straight up. Nothing else needed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // White QR Code Panel
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.brandOnSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: token != null && token.token.isNotEmpty
                    ? QrImageView(
                        data: token.token,
                        version: QrVersions.auto,
                        size: 110,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/art/checkin_qr.svg',
                        width: 110,
                        height: 110,
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Reference metadata
            _ReferenceRow(label: 'Booking', value: bookingRef),
            const _ReferenceRow(label: 'Hotel notified', value: 'Just now'),
          ],
        );
      },
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.checkInPassRef, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondarySmall,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
            ),
          ),
        ],
      ),
    );
  }
}
