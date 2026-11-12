import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.2c: Document review before forwarding to the hotel.
class CheckInVisaReviewScreen extends ConsumerWidget {
  const CheckInVisaReviewScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
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
        final source = details.visaSource ?? VisaSource.camera;
        final imagePath = details.visaImagePath;

        final (subtitle, icon, sourceLabel) = switch (source) {
          VisaSource.camera => (
            'Both dates readable? No glare?',
            AppIcons.camera,
            'Photographed just now',
          ),
          VisaSource.file => (
            'Is this the right page?',
            AppIcons.paperclip,
            'Attached from your phone',
          ),
          VisaSource.pdf => (
            'Is this the right document?',
            AppIcons.fileText,
            'Uploaded as a PDF',
          ),
        };

        return BrandVerifyScreen(
          title: 'Your visa',
          backgroundAsset: 'assets/art/bg_capture.svg',
          helpArea: ProblemArea.checkIn,
          onBack: () => context.pop(),
          isScrollable: true,
          foot: [
            AppButton(
              label: 'Use this visa',
              variant: AppButtonVariant.brandWhite,
              onPressed: () {
                ref
                    .read(checkInNotifierProvider(reservationId).notifier)
                    .completeStage(CheckInStage.requirement);
                context.pushReplacement(
                  AppRoutes.checkInGuestsPath(reservationId),
                );
              },
            ),
            SizedBox(height: space.stackFormField),
            AppButton(
              label: 'Take it again',
              variant: AppButtonVariant.brandOutline,
              onPressed: () => context.pushReplacement(
                AppRoutes.checkInVisaCapturePath(reservationId),
              ),
            ),
            const CheckInNotice(
              text: 'We pass this to the hotel. We do not check it.',
            ),
          ],
          children: [
            SizedBox(height: space.stackSection),
            Text(
              'Check it before we send it',
              textAlign: TextAlign.center,
              style: context.text.headlineMedium?.copyWith(
                color: colors.brandOnSurface,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: space.stackTight),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: colors.brandSecondaryBody,
              ),
            ),
            SizedBox(height: space.stackFormField),

            // Captured image preview or placeholder panel
            Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: sizes.previewDocMaxHeight,
                ),
                decoration: BoxDecoration(
                  color: colors.brandCardBackground,
                  borderRadius: shape.radiusSurface,
                  border: Border.all(
                    color: colors.brandBorderSubtle,
                    width: shape.borderMedium,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 1 / 1.05,
                  child: imagePath != null && File(imagePath).existsSync()
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : SvgPicture.asset(
                          'assets/art/camera_passport.svg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(height: space.stackFormField),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: sizes.iconXs, color: colors.brandSecondary),
                SizedBox(width: space.inlineIconLabel),
                Flexible(
                  child: Text(
                    sourceLabel,
                    style: context.text.labelMedium?.copyWith(
                      color: colors.brandSecondaryBody,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
