import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_image_processor.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/document_processing_visual.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';

/// Intermediate screen displayed immediately after camera capture.
///
/// Explains the image processing state (cropping, resolution normalization,
/// and 100% JPEG encoding) to the traveler before transitioning to the review screen.
class PassportProcessingScreen extends ConsumerStatefulWidget {
  final PassportCropParams? cropParams;

  const PassportProcessingScreen({super.key, this.cropParams});

  @override
  ConsumerState<PassportProcessingScreen> createState() =>
      _PassportProcessingScreenState();
}

class _PassportProcessingScreenState
    extends ConsumerState<PassportProcessingScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  Future<void> _processImage() async {
    final state = ref.read(verificationNotifierProvider);
    final params = widget.cropParams ?? state.cropParams;

    if (params == null) {
      if (state.capturedImage != null && mounted) {
        context.go(AppRoutes.passportReview);
      } else if (mounted) {
        context.go(AppRoutes.passportCapture);
      }
      return;
    }

    try {
      final croppedFile = await compute(
        cropAndOptimizePassportImage,
        params.toMap(),
      );

      if (croppedFile != null && mounted) {
        ref.read(verificationNotifierProvider.notifier).setImage(croppedFile);
        if (mounted) {
          context.go(AppRoutes.passportReview);
        }
      } else {
        // Fallback to raw captured file if crop returned null
        if (state.capturedImage != null && mounted) {
          context.go(AppRoutes.passportReview);
        } else {
          throw Exception('Failed to process passport image.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Could not process passport image. Please try capturing again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'KYC',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const KycProgressStepper(progressIndex: 0),
                const Spacer(),
                Center(
                  child: DocumentProcessingVisual(
                    stageType: _errorMessage != null
                        ? ProcessingStageType.failed
                        : ProcessingStageType.preparing,
                    processingType: ProcessingType.passport,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _errorMessage != null
                      ? 'Processing Failed'
                      : 'Processing your passport',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ??
                      'Cropping and optimizing your document for review...',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage == null)
                  Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.passportCapture);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retake Passport'),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
