import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_info_card.dart';
import 'package:trvlez_mobile/core/widgets/brand_pointer_pair.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_alt_action.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.2a: Visa document guidelines and capture method selection.
class CheckInVisaScreen extends ConsumerWidget {
  const CheckInVisaScreen({super.key, required this.reservationId});

  final String reservationId;

  Future<void> _pickFile(
    BuildContext context,
    WidgetRef ref,
    VisaSource source,
  ) async {
    String? pickedPath;
    if (source == VisaSource.file) {
      try {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        pickedPath = image?.path;
      } catch (_) {}
    }

    ref
        .read(checkInNotifierProvider(reservationId).notifier)
        .setVisaSource(source, pickedPath);

    if (context.mounted) {
      context.push(AppRoutes.checkInVisaReviewPath(reservationId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return BrandVerifyScreen(
      title: 'Online check-in',
      backgroundAsset: 'assets/art/bg_checkin_visa.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Open camera',
          variant: AppButtonVariant.brandWhite,
          onPressed: () =>
              context.push(AppRoutes.checkInVisaCapturePath(reservationId)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: CheckInAltAction(
                icon: AppIcons.paperclip,
                label: 'Attach a file',
                onTap: () => _pickFile(context, ref, VisaSource.file),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CheckInAltAction(
                icon: AppIcons.fileText,
                label: 'Upload a PDF',
                onTap: () => _pickFile(context, ref, VisaSource.pdf),
              ),
            ),
          ],
        ),
        const CheckInNotice(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your visa',
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
          "Photograph the visa page in your passport, or the sticker if it's separate.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Visa illustration
        Center(
          child: SvgPicture.asset(
            'assets/art/visa_how_to.svg',
            width: 198,
            height: 126,
          ),
        ),
        const SizedBox(height: AppSpacing.md - 2),

        // Pointers
        const BrandPointerPair(
          items: [
            ('1', 'The whole visa', 'All four edges inside the frame'),
            ('2', 'The dates', 'Valid from and valid to, both readable'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 2),

        // Info card with bullets
        const BrandInfoCard(
          bullets: [
            BrandBullet(
              icon: AppIcons.bulb,
              text: 'Well lit, no glare across the hologram',
            ),
            BrandBullet(
              icon: AppIcons.handStop,
              text: 'No fingers or shadows over the dates or stamp',
            ),
            BrandBullet(
              icon: AppIcons.fileSearch,
              text: 'If your visa is digital, upload the PDF instead',
            ),
          ],
        ),
      ],
    );
  }
}
