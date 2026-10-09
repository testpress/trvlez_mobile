import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';

/// Instruction screen shown before the selfie video capture.
///
/// Displays liveness check guidelines and enforces a 3-second minimum
/// reading time before the user can proceed to the camera.
class SelfieInstructionScreen extends StatefulWidget {
  const SelfieInstructionScreen({super.key});

  @override
  State<SelfieInstructionScreen> createState() =>
      _SelfieInstructionScreenState();
}

class _SelfieInstructionScreenState extends State<SelfieInstructionScreen>
    with SingleTickerProviderStateMixin {
  static const int _countdownSeconds = 3;

  int _remainingSeconds = _countdownSeconds;
  bool _canProceed = false;
  Timer? _timer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _canProceed = true;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _proceedToCapture() {
    if (!_canProceed) return;
    context.go(AppRoutes.selfieCapture);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Horizontal Stepper Progress Indicator - Step 3 (Selfie) is active
              const KycProgressStepper(progressIndex: 2),
              const SizedBox(height: 24),

              // Central Card Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Selfie Verification',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need a quick video to confirm you match the photo on your passport.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Guidelines
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please ensure:',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGuidelineRow(
                            Icons.lightbulb_outline_rounded,
                            'You are in a well-lit room',
                            colorScheme,
                          ),
                          const SizedBox(height: 8),
                          _buildGuidelineRow(
                            Icons.face_rounded,
                            'Your face is clearly visible',
                            colorScheme,
                          ),
                          const SizedBox(height: 8),
                          _buildGuidelineRow(
                            Icons.remove_red_eye_outlined,
                            'No glasses, hats, or masks',
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Proceed button
                    ElevatedButton(
                      onPressed: _canProceed ? _proceedToCapture : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSurface,
                        foregroundColor: colorScheme.surface,
                        disabledBackgroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.12),
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.38),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: _canProceed
                          ? FadeTransition(
                              opacity: _fadeController,
                              child: Text(
                                'I\'m Ready',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Text(
                              'Please read ($_remainingSeconds)',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer text
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'If you are facing any difficulties, please get in touch with us on ',
                        ),
                        TextSpan(
                          text: 'Whatsapp',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: context.colors.feedbackSuccess,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineRow(
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
