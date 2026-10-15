import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_info_card.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Instruction screen introducing passport chip scanning.
///
/// Corresponds to Step 4 of verification. Explains on-device chip security.
class NfcIntroScreen extends ConsumerWidget {
  const NfcIntroScreen({super.key, this.nfcService});

  final NfcPassportService? nfcService;

  void _showUnsupportedSheet(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceSubtle,
                  ),
                  child: Icon(
                    AppIcons.nfc,
                    size: 28.0,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'NFC Not Supported',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 18.0,
                  fontWeight: TypeScale.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This device does not have NFC hardware, which is required to scan passport chips. You can continue verification without chip scanning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.0,
                  fontWeight: TypeScale.regular,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Continue without chip scan',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  ref.read(verificationNotifierProvider.notifier).skipNfc();
                  ref
                      .read(verificationNotifierProvider.notifier)
                      .submitVerificationAsync();
                  context.pushReplacement(AppRoutes.nfcFinalCheck);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisabledSheet(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceSubtle,
                  ),
                  child: Icon(
                    AppIcons.nfc,
                    size: 28.0,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enable NFC to Continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 18.0,
                  fontWeight: TypeScale.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'NFC is turned off on your device. To scan your passport chip, please enable NFC in your device settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.0,
                  fontWeight: TypeScale.regular,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Open NFC Settings',
                variant: AppButtonVariant.primary,
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await AppSettings.openAppSettings(
                      type: AppSettingsType.nfc,
                    );
                  } catch (_) {
                    try {
                      await AppSettings.openAppSettings(
                        type: AppSettingsType.settings,
                      );
                    } catch (_) {}
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 3, circleSize: 22.0),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 60.0,
            height: 60.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardIconBackground,
            ),
            child: Icon(AppIcons.nfc, size: 28.0, color: colors.brandOnSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Scan the chip',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20.0,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your passport has a secure chip. Reading it is the strongest check there is, and it takes seconds.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const BrandInfoCard(
          heading: "You'll need",
          borderRadius: 12.0,
          paddingVertical: 10.0,
          paddingHorizontal: 12.0,
          itemGap: 8.0,
          iconSize: 13.0,
          bullets: [
            BrandBullet(
              icon: AppIcons.deviceMobile,
              text: 'A phone with NFC switched on',
            ),
            BrandBullet(
              icon: AppIcons.id,
              text: 'A passport with the chip symbol on the cover',
            ),
          ],
        ),
      ],
      foot: [
        AppButton(
          label: 'Start scan',
          variant: AppButtonVariant.brandWhite,
          onPressed: () async {
            final NfcPassportService activeNfcService =
                nfcService ?? ref.read(nfcPassportServiceProvider);
            final status = await activeNfcService.getNfcStatus();
            if (!context.mounted) return;

            if (status == NfcDeviceStatus.unsupported) {
              _showUnsupportedSheet(context, ref);
              return;
            }
            if (status == NfcDeviceStatus.disabled) {
              _showDisabledSheet(context);
              return;
            }
            context.push(AppRoutes.nfcScan);
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
