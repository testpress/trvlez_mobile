import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Active scan screen for reading the passport NFC chip with real-time hardware interaction.
class NfcScanScreen extends ConsumerStatefulWidget {
  const NfcScanScreen({super.key, required this.nfcService});

  final NfcPassportService nfcService;

  @override
  ConsumerState<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends ConsumerState<NfcScanScreen> {
  double _progress = 0.0;
  bool _isReading = false;
  String _stepDescription = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  void _startScan() async {
    final state = ref.read(verificationNotifierProvider);
    final docNumber =
        state.extractedDocumentNumber ??
        state.mrzExtractionResult?.documentNumber;
    final dob =
        state.extractedDateOfBirth ??
        _parseDate(state.mrzExtractionResult?.dateOfBirth);
    final expiry =
        state.extractedDateOfExpiry ??
        _parseDate(state.mrzExtractionResult?.dateOfExpiry);

    if (docNumber == null ||
        docNumber.isEmpty ||
        dob == null ||
        expiry == null) {
      if (mounted) {
        context.pushReplacement(
          AppRoutes.passportFailed,
          extra:
              'Could not read passport data for NFC chip scan. Please retake your passport photo.',
        );
      }
      return;
    }

    try {
      final nfcStatus = await widget.nfcService.getNfcStatus();
      if (!mounted) return;

      if (nfcStatus == NfcDeviceStatus.unsupported) {
        context.pushReplacement(
          AppRoutes.nfcFailed,
          extra: {
            'failedStepTitle': 'Chip scan',
            'reason': 'This device does not support NFC chip scanning.',
            'mitigation': 'You can skip chip scan and continue verification.',
          },
        );
        return;
      }

      if (nfcStatus == NfcDeviceStatus.disabled) {
        context.pushReplacement(
          AppRoutes.nfcFailed,
          extra: {
            'failedStepTitle': 'Chip scan',
            'redoButtonLabel': 'Try chip scan again',
            'redoRoute': AppRoutes.nfcScan,
            'reason': 'NFC is turned off on your device.',
            'mitigation':
                'Please enable NFC in your device settings before trying again.',
          },
        );
        return;
      }

      final result = await widget.nfcService.readPassport(
        documentNumber: docNumber,
        dateOfBirth: dob,
        dateOfExpiry: expiry,
        onProgress: (progressEvent) {
          if (!mounted) return;
          setState(() {
            _isReading =
                progressEvent.currentStep != NfcReadStep.connecting ||
                progressEvent.percentage > 0.0;
            final rawPercent = progressEvent.percentage > 1.0
                ? progressEvent.percentage / 100.0
                : progressEvent.percentage;
            _progress = rawPercent.clamp(0.0, 1.0);
            _stepDescription = progressEvent.description;
          });
        },
      );
      if (!mounted) return;
      ref.read(verificationNotifierProvider.notifier).setNfcResult(result);
      context.pushReplacement(AppRoutes.chipData);
    } catch (e) {
      if (!mounted) return;
      final reason = e is NfcError
          ? e.message
          : "We couldn't read the chip inside your passport.";
      final mitigation = e is NfcError
          ? (e.userGuidance ?? e.technicalDetails)
          : null;
      context.pushReplacement(
        AppRoutes.nfcFailed,
        extra: {
          'failedStepTitle': 'Chip scan',
          'redoButtonLabel': 'Try chip scan again',
          'redoRoute': AppRoutes.nfcScan,
          'reason': reason,
          'mitigation': mitigation,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final String semanticsLabel;
    if (_isReading) {
      semanticsLabel = _stepDescription.isNotEmpty
          ? _stepDescription
          : 'Reading the chip';
    } else {
      semanticsLabel = 'Reading passport chip';
    }

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc_scan.svg',
      title: 'Scanning passport',
      closeIcon: true,
      onBack: () => context.pop(),
      helpLine: true,
      helpPrefix: 'Not working? ',
      helpLinkText: "Tell us what's wrong",
      helpArea: ProblemArea.verification,
      isScrollable: false,
      body: [
        const Spacer(flex: 3),
        Center(child: VerifyNfcPulse(size: sizes.cardWidthCarousel)),
        const Spacer(flex: 3),
        Text(
          'Reading the chip',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            color: colors.brandOnSurface,
          ),
        ),
        SizedBox(height: space.stackItem),
        Semantics(
          label: semanticsLabel,
          value: '${(_progress * 100).toInt()}%',
          child: ClipRRect(
            borderRadius: shape.radiusPill,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: sizes.indicatorProgressHeight,
                  backgroundColor: colors.verificationProgressTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.brandOnSurface,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: space.stackItem),
        Text(
          'Keep the phone still against the passport',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        const Spacer(flex: 2),
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: shape.radiusSurface,
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.handStop,
                size: sizes.iconDefault,
                color: colors.brandOnSurface,
              ),
              SizedBox(width: space.inlineButtonGroup),
              Expanded(
                child: Text(
                  'Almost there. Moving the phone now will start the read again.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.brandOnSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }
}
