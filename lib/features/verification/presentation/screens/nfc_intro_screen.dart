import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: space.stackFormField),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: sizes.avatarMd,
                  height: sizes.indicatorProgressHeight,
                  margin: EdgeInsets.only(
                    top: space.stackItem,
                    bottom: space.stackFormField,
                  ),
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: shape.radiusPill,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: sizes.controlXl,
                  height: sizes.controlXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceSubtle,
                  ),
                  child: Icon(
                    AppIcons.nfc,
                    size: sizes.iconLg,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: space.stackFormField),
              Text(
                'NFC Not Supported',
                textAlign: TextAlign.center,
                style: context.text.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                'This device does not have NFC hardware, which is required to scan passport chips. You can continue verification without chip scanning.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: space.stackSection),
              AppButton(
                label: 'Continue without chip scan',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  ref.read(verificationNotifierProvider.notifier).skipNfc();
                  ref
                      .read(verificationNotifierProvider.notifier)
                      .submitVerificationAsync();
                  context.pushReplacement(AppRoutes.verificationFinalCheck);
                },
              ),
              SizedBox(height: space.stackText),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(sheetContext),
              ),
              SizedBox(height: space.stackFormField),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisabledSheet(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: space.stackFormField),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: sizes.avatarMd,
                  height: sizes.indicatorProgressHeight,
                  margin: EdgeInsets.only(
                    top: space.stackItem,
                    bottom: space.stackFormField,
                  ),
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: shape.radiusPill,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: sizes.controlXl,
                  height: sizes.controlXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceSubtle,
                  ),
                  child: Icon(
                    AppIcons.nfc,
                    size: sizes.iconLg,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: space.stackFormField),
              Text(
                'Enable NFC to Continue',
                textAlign: TextAlign.center,
                style: context.text.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                'NFC is turned off on your device. To scan your passport chip, please enable NFC in your device settings.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: space.stackSection),
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
              SizedBox(height: space.stackText),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(sheetContext),
              ),
              SizedBox(height: space.stackFormField),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc.svg',
      title: 'Verification',
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        VerificationStepper(current: 3, circleSize: sizes.iconDefault),
        const Spacer(flex: 1),
        Center(
          child: Container(
            width: sizes.pulseIndicator,
            height: sizes.pulseIndicator,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardIconBackground,
            ),
            child: Icon(
              AppIcons.nfc,
              size: sizes.iconLg,
              color: colors.brandOnSurface,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Text(
          'Scan the chip',
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'Your passport has a secure chip. Reading it is the strongest check there is, and it takes seconds.',
          textAlign: TextAlign.center,
          style: context.text.labelMedium?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 1),
        const BrandInfoCard(
          heading: "You'll need",
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
        SizedBox(height: space.stackFormField),
        const BrandSecurityNote(
          text: 'Read on your phone.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
