import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final nfc = state.nfcResult;
    final mrz = state.mrzExtractionResult;

    final parsedMrz = nfc?.parsedMrz;
    final givenNames = parsedMrz?.firstName ?? mrz?.firstName ?? '';
    final surname = parsedMrz?.lastName ?? mrz?.lastName ?? '';
    final nameParts = [givenNames, surname].where((s) => s.isNotEmpty).toList();
    final displayName = nameParts.isNotEmpty ? nameParts.join(' ') : '—';

    final docNumber = parsedMrz?.documentNumber ??
        state.extractedDocumentNumber ??
        mrz?.documentNumber ??
        '—';

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
      body: [
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: sizes.avatarXl,
            height: sizes.avatarXl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: Icon(
              AppIcons.nfc,
              size: sizes.iconFeature,
              color: colors.brandPrimary,
            ),
          ),
        ),
        const Spacer(flex: 2),
        Text(
          'Chip data received',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          "This is what your passport's chip holds. Check it looks right.",
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const Spacer(flex: 2),
        Container(
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: shape.radiusCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: shape.radiusControl,
                      child: faceBytes != null
                          ? Image.memory(
                              faceBytes,
                              width: sizes.pulseIndicator,
                              height: sizes.avatarXl,
                              fit: BoxFit.cover,
                            )
                          : SvgPicture.asset(
                              'assets/art/chip_photo.svg',
                              width: sizes.pulseIndicator,
                              height: sizes.avatarXl,
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
                            displayName,
                            style: context.text.titleLarge?.copyWith(
                              fontWeight: TypeScale.bold,
                              color: colors.brandOnSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: space.stackTight),
                          Text(
                            'Document no. $docNumber',
                            style: context.text.bodySmall?.copyWith(
                              color: colors.brandSecondaryBody,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: space.stackItem),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: space.inlineIconLabel,
                              vertical: space.inlineMicro,
                            ),
                            decoration: BoxDecoration(
                              color: colors.brandOnSurface.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: shape.radiusPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.nfc,
                                  size: sizes.iconXs,
                                  color: colors.brandOnSurface,
                                ),
                                SizedBox(width: space.inlineMicro),
                                Text(
                                  'From the chip',
                                  style: context.text.labelSmall?.copyWith(
                                    fontWeight: TypeScale.medium,
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
              Divider(
                height: shape.dividerDefault,
                thickness: shape.dividerDefault,
                color: colors.brandDivider,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  space.stackFormField,
                  0,
                  space.stackFormField,
                  space.stackText,
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
        const Spacer(flex: 1),
      ],
      foot: [
        AppButton(
          label: 'Submit verification',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            ref
                .read(verificationNotifierProvider.notifier)
                .submitVerificationAsync();
            context.go(AppRoutes.verificationFinalCheck);
          },
        ),
        SizedBox(height: space.stackItem),
        const BrandSecurityNote(
          text: 'Read on your phone.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
