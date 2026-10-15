import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displaying the cryptographically authenticated passport chip data.
///
/// Features chip portrait, "From the chip" provenance tag, and key document fields.
class ChipDataScreen extends ConsumerWidget {
  const ChipDataScreen({super.key});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);
    final nfc = state.nfcResult;
    final mrz = state.mrzExtractionResult;

    final parsedMrz = nfc?.parsedMrz;
    final givenNames = parsedMrz?.firstName ?? mrz?.firstName ?? '';
    final surname = parsedMrz?.lastName ?? mrz?.lastName ?? '';
    final nameParts = [givenNames, surname].where((s) => s.isNotEmpty).toList();
    final displayName = nameParts.isNotEmpty ? nameParts.join(' ') : '—';

    final nationality = parsedMrz?.nationality ?? mrz?.nationality ?? '—';
    final dob = parsedMrz?.dateOfBirth ?? state.extractedDateOfBirth;
    final dobFormatted = dob != null
        ? _formatDate(dob)
        : (mrz?.dateOfBirth ?? '—');
    final expiry = parsedMrz?.dateOfExpiry ?? state.extractedDateOfExpiry;
    final expiryFormatted = expiry != null
        ? _formatDate(expiry)
        : (mrz?.dateOfExpiry ?? '—');

    final Uint8List? faceBytes = nfc?.faceImageBytes;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_chip_data.svg',
      title: 'Chip scan',
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        const Spacer(flex: 1),
        Center(
          child: Container(
            width: AppSpacing.xxl + AppSpacing.md,
            height: AppSpacing.xxl + AppSpacing.md,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: Icon(
              AppIcons.nfc,
              size: AppSpacing.xl,
              color: colors.brandPrimary,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Text(
          'Chip data received',
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "This is what your passport's chip holds. Check it looks right.",
          textAlign: TextAlign.center,
          style: context.text.labelMedium?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        const Spacer(flex: 1),
        Container(
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: faceBytes != null
                          ? Image.memory(
                              faceBytes,
                              width: AppSpacing.xxl + AppSpacing.xs,
                              height: AppSpacing.xxl + AppSpacing.md,
                              fit: BoxFit.cover,
                            )
                          : SvgPicture.asset(
                              'assets/art/chip_photo.svg',
                              width: AppSpacing.xxl + AppSpacing.xs,
                              height: AppSpacing.xxl + AppSpacing.md,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: context.text.titleMedium?.copyWith(
                              color: colors.brandOnSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm - 2,
                              vertical: AppSpacing.xs / 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.brandOnSurface.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.nfc,
                                  size: AppSpacing.sm + AppSpacing.xs / 2,
                                  color: colors.brandOnSurface,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'From the chip',
                                  style: context.text.labelSmall?.copyWith(
                                    color: colors.brandOnSurface,
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
              Divider(height: 1.0, thickness: 1.0, color: colors.brandDivider),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VerifyDetailRow(label: 'Nationality', value: nationality),
                    VerifyDetailRow(
                      label: 'Date of birth',
                      value: dobFormatted,
                    ),
                    VerifyDetailRow(
                      label: 'Expiry',
                      value: expiryFormatted,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Submit verification',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            ref
                .read(verificationNotifierProvider.notifier)
                .submitVerificationAsync();
            context.pushReplacement(AppRoutes.nfcFinalCheck);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text: 'Read on your phone.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
