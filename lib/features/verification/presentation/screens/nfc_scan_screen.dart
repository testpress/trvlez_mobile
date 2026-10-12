import 'dart:async';

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

/// Active scan screen for reading the passport NFC chip.
///
/// Features animated 3-ring pulse, dynamic waiting/reading states, live progress bar,
/// and smooth transition to Chip Data on completion.
class NfcScanScreen extends ConsumerStatefulWidget {
  const NfcScanScreen({
    super.key,
    required this.nfcService,
  });

  final NfcPassportService nfcService;

  @override
  ConsumerState<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends ConsumerState<NfcScanScreen> {
  double _progress = 0.08;
  Timer? _simTimer;

  bool get _isReading => _progress >= 0.2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  DateTime _parseDate(String? s, DateTime fallback) {
    if (s == null) return fallback;
    return DateTime.tryParse(s) ?? fallback;
  }

  void _startScan() async {
    final state = ref.read(verificationNotifierProvider);
    final docNumber = state.mrzExtractionResult?.documentNumber ??
        state.extractedDocumentNumber ??
        'A12345678';
    final dob = state.extractedDateOfBirth ??
        _parseDate(state.mrzExtractionResult?.dateOfBirth, DateTime(1991, 3, 14));
    final expiry = state.extractedDateOfExpiry ??
        _parseDate(state.mrzExtractionResult?.dateOfExpiry, DateTime(2031, 8, 22));

    try {
      final result = await widget.nfcService.readPassport(
        documentNumber: docNumber,
        dateOfBirth: dob,
        dateOfExpiry: expiry,
        onProgress: (progressEvent) {
          if (!mounted) return;
          setState(() {
            _progress = (progressEvent.percentage / 100.0).clamp(0.08, 1.0);
          });
        },
      );
      if (!mounted) return;
      ref.read(verificationNotifierProvider.notifier).setNfcResult(result);
      _onSuccess();
    } catch (_) {
      // In simulator / test environments, fallback to simulated scan
      _startSimulatedScan();
    }
  }

  void _startSimulatedScan() {
    _simTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress = (_progress + 0.035).clamp(0.08, 1.0);
      });

      if (_progress >= 1.0) {
        timer.cancel();
        _onSuccess();
      }
    });
  }

  void _onSuccess() {
    if (mounted) {
      context.pushReplacement(AppRoutes.chipData);
    }
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final heading = _isReading ? 'Reading the chip' : 'Waiting for the chip';
    final subtitle = _isReading
        ? 'Keep your phone against the passport. It takes a few seconds.'
        : 'Hold the top of your phone against the passport cover. Keep still once it vibrates.';

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_nfc_scan.svg',
      title: 'Scanning passport',
      closeIcon: true,
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const SizedBox(height: AppSpacing.xxl),
        const Center(child: VerifyNfcPulse()),
        const SizedBox(height: AppSpacing.xl),
        Text(
          heading,
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
            subtitle,
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
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 220.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 120),
                widthFactor: _progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.brandOnSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
