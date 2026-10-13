import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
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
  double _progress = 0.08;
  bool _isReading = false;

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
      final result = await widget.nfcService.readPassport(
        documentNumber: docNumber,
        dateOfBirth: dob,
        dateOfExpiry: expiry,
        onProgress: (progressEvent) {
          if (!mounted) return;
          setState(() {
            _isReading = true;
            _progress = (progressEvent.percentage / 100.0).clamp(0.08, 1.0);
          });
        },
      );
      if (!mounted) return;
      ref.read(verificationNotifierProvider.notifier).setNfcResult(result);
      context.pushReplacement(AppRoutes.chipData);
    } catch (_) {
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.nfcFailed,
        extra: {
          'failedStepTitle': 'Chip scan',
          'redoButtonLabel': 'Try chip scan again',
          'redoRoute': AppRoutes.nfcScan,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc_scan.svg',
      title: 'Chip scan',
      helpLine: false,
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          _isReading ? 'Reading chip…' : 'Hold near passport',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            _isReading
                ? 'Keep phone still against the passport cover.'
                : 'Rest the top of your phone on the front or back cover of the passport.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: TypeScale.regular,
              color: colors.brandSecondaryBody,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(child: VerifyNfcPulse()),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 5.0,
                  backgroundColor: colors.verificationProgressTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.brandOnSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.0,
                  fontWeight: TypeScale.medium,
                  color: colors.brandSecondaryBody,
                ),
              ),
            ],
          ),
        ),
      ],
      foot: [
        Center(
          child: TextButton(
            onPressed: () {
              ref.read(verificationNotifierProvider.notifier).skipNfc();
              ref
                  .read(verificationNotifierProvider.notifier)
                  .submitVerificationAsync();
              context.pushReplacement(AppRoutes.nfcFinalCheck);
            },
            child: Text(
              'Skip chip scan',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.0,
                color: colors.brandSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
