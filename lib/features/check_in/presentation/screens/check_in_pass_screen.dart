import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.6b: The reusable digital hotel pass with guest portrait, ID verification badge, and QR code.
class CheckInPassScreen extends ConsumerWidget {
  const CheckInPassScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
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
        final guestName = details.reservation.guestName.isNotEmpty
            ? details.reservation.guestName
            : 'Amara Okafor';
        final token = tokenState.valueOrNull;

        return BrandVerifyScreen(
          title: details.hotel,
          backgroundAsset: 'assets/art/bg_checkin_pass.svg',
          helpArea: ProblemArea.checkIn,
          closeIcon: true,
          onBack: () => context.pop(),
          isScrollable: true,
          foot: const [
            CheckInNotice(text: 'Works offline. Expires when you check out.'),
          ],
          children: [
            SizedBox(height: space.stackSection),
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
            SizedBox(height: space.stackTight),
            Text(
              'Collect your keys and go straight up.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
              ),
            ),
            SizedBox(height: space.stackFormField),

            // White pass card
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.brandOnSurface,
                borderRadius: shape.radiusSurface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: space.insetCard,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: shape.radiusControlSm,
                          child: SvgPicture.asset(
                            'assets/art/guest_photo.svg',
                            width: 52,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: space.inlineItem),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                guestName,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 15,
                                  fontWeight: TypeScale.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: space.stackText),
                              Text(
                                details.dateAndGuests,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                              SizedBox(height: space.stackTight),
                              // ID verified badge
                              Container(
                                padding: space.insetTag,
                                decoration: BoxDecoration(
                                  color: colors.redTint,
                                  borderRadius: shape.radiusPill,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      AppIcons.rosetteDiscountCheck,
                                      size: sizes.iconXs,
                                      color: colors.brandPrimary,
                                    ),
                                    SizedBox(width: space.inlineMicro),
                                    Text(
                                      'ID verified',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: TypeScale.bold,
                                        color: colors.brandActionLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR section
                  Padding(
                    padding: EdgeInsets.only(
                      left: space.insetCard.left,
                      right: space.insetCard.right,
                      bottom: space.insetCard.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        token != null && token.token.isNotEmpty
                            ? QrImageView(
                                data: token.token,
                                version: QrVersions.auto,
                                size: sizes.thumbPhotoMd,
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: colors.textPrimary,
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: colors.textPrimary,
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/art/checkin_qr.svg',
                                width: sizes.thumbPhotoMd,
                                height: sizes.thumbPhotoMd,
                              ),
                        Container(
                          margin: EdgeInsets.only(top: space.stackItem),
                          padding: EdgeInsets.only(top: space.stackItem),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colors.line,
                                width: shape.dividerDefault,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Booking',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                bookingRef,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: TypeScale.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.stackFormField),

            // Link: See what the hotel gets
            Center(
              child: GestureDetector(
                onTap: () =>
                    context.push(AppRoutes.hotelViewPath(reservationId)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.eye,
                      size: sizes.iconXs,
                      color: colors.brandOnSurface,
                    ),
                    SizedBox(width: space.inlineIconLabel),
                    Text(
                      'See what the hotel gets',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.brandUnderline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
