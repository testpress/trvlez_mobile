import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Capture screen for the passport photo page.
///
/// Features a dedicated 1:1.05 aspect camera frame with corner guides and dashed
/// MRZ box, live camera feed support with SVG fallback, square shutter capture button,
/// and support for gallery fallback.
class PassportCaptureScreen extends ConsumerStatefulWidget {
  const PassportCaptureScreen({
    super.key,
    required this.cameraService,
  });

  final CameraService cameraService;

  @override
  ConsumerState<PassportCaptureScreen> createState() =>
      _PassportCaptureScreenState();
}

class _PassportCaptureScreenState extends ConsumerState<PassportCaptureScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _controller = await widget.cameraService.initCamera(
        lensDirection: CameraLensDirection.back,
        resolution: ResolutionPreset.high,
        enableAudio: false,
      );

      final cam = _controller;
      if (cam != null && mounted) {
        try {
          await cam.setFocusMode(FocusMode.auto);
        } catch (_) {}
        try {
          await cam.setExposureMode(ExposureMode.auto);
        } catch (_) {}
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (_) {
      // Graceful fallback to SVG illustration if camera is unavailable in simulator/environment
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    final cam = _controller;
    if (cam != null && cam.value.isInitialized) {
      setState(() => _isCapturing = true);
      try {
        final XFile file = await cam.takePicture();
        final cropParams = PassportCropParams(
          imagePath: file.path,
          screenWidth: 300,
          screenHeight: 400,
          frameWidth: 260,
          frameHeight: 273,
          frameCenterX: 150,
          previewAspectRatio: cam.value.aspectRatio,
        );

        ref
            .read(verificationNotifierProvider.notifier)
            .setImage(File(file.path), cropParams: cropParams);

        if (mounted) {
          context.push(AppRoutes.passportReview);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture photo. Try again.')),
          );
        }
      } finally {
        if (mounted) setState(() => _isCapturing = false);
      }
    } else {
      // If camera preview is inactive (e.g. simulator), open gallery or use sample capture
      await _pickFromGallery();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        final cropParams = PassportCropParams(
          imagePath: image.path,
          screenWidth: 300,
          screenHeight: 400,
          frameWidth: 260,
          frameHeight: 273,
          frameCenterX: 150,
          previewAspectRatio: 1.0,
        );

        ref
            .read(verificationNotifierProvider.notifier)
            .setImage(File(image.path), cropParams: cropParams);

        if (mounted) {
          context.push(AppRoutes.passportReview);
        }
      }
    } catch (_) {
      // Gallery picker dismissed or unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cam = _controller;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 0, circleSize: 23.0),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Fit the page in the frame',
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
          'Both the photo page and the code lines.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AspectRatio(
              aspectRatio: 1 / 1.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  color: colors.brandShotBackdrop.withValues(alpha: 0.35),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isCameraInitialized && cam != null)
                        CameraPreview(cam)
                      else
                        SvgPicture.asset(
                          'assets/art/camera_passport.svg',
                          fit: BoxFit.cover,
                        ),
                      // Framing overlay guide with corners and dashed MRZ box
                      _buildFramingGuide(colors),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.numbers,
              size: 14.0,
              color: colors.brandSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Keep the dashed box over the code lines',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: TypeScale.regular,
                  color: colors.brandSecondaryBody,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: TextButton.icon(
            onPressed: _pickFromGallery,
            icon: Icon(
              AppIcons.photo,
              size: 14.0,
              color: colors.brandSecondaryBody,
            ),
            label: Text(
              'Upload from photo library',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.0,
                color: colors.brandSecondaryBody,
              ),
            ),
          ),
        ),
      ],
      foot: [
        VerifyShutter(
          square: true,
          onPressed: _isCapturing ? null : _capturePhoto,
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.passportCapture,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Trouble with the camera? '),
                    TextSpan(
                      text: "Tell us what's wrong",
                      style: TextStyle(
                        color: colors.brandSecondary,
                        decoration: TextDecoration.underline,
                        fontWeight: TypeScale.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFramingGuide(AppColors colors) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.brandBorderSubtle,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 48.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.brandSecondary.withValues(alpha: 0.8),
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
