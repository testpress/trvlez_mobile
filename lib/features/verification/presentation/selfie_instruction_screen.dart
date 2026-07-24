import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_progress_bar.dart';
/// Instruction screen shown before the selfie video capture.
///
/// Displays liveness check guidelines and enforces a 3-second minimum
/// reading time before the user can proceed to the camera.
class SelfieInstructionScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const SelfieInstructionScreen({super.key, required this.notifier});

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
    context.push('/verification/selfie-capture');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Before You Record'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Step progress bar — Selfie is step 3
              VerificationProgressBar.verification(currentStepIndex: 2),
              const SizedBox(height: 16),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_retouching_natural,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Selfie Video Instructions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Please follow these guidelines for a successful verification.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withAlpha(160),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Instructions list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _InstructionTile(
                        icon: Icons.visibility,
                        title: 'Look at the camera',
                        subtitle:
                            'Face the front camera directly and keep your face centered.',
                        colorScheme: colorScheme,
                      ),
                      _InstructionTile(
                        icon: Icons.remove_red_eye_outlined,
                        title: 'Blink naturally',
                        subtitle:
                            'Blink normally during the recording — do not stare without blinking.',
                        colorScheme: colorScheme,
                      ),
                      _InstructionTile(
                        icon: Icons.swap_horiz,
                        title: 'Move your head slightly',
                        subtitle:
                            'Slowly turn your head a little left and right during the video.',
                        colorScheme: colorScheme,
                      ),
                      _InstructionTile(
                        icon: Icons.light_mode_outlined,
                        title: 'Good lighting',
                        subtitle:
                            'Ensure your face is well-lit from the front — avoid backlighting.',
                        colorScheme: colorScheme,
                      ),
                      _InstructionTile(
                        icon: Icons.block,
                        title: 'No obstructions',
                        subtitle:
                            'Remove glasses, hats, or anything covering your face.',
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Continue button with countdown
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _canProceed
                    ? FadeTransition(
                        opacity: _fadeController,
                        child: FilledButton.icon(
                          onPressed: _proceedToCapture,
                          icon: const Icon(Icons.videocam),
                          label: const Text('Start Recording'),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Please read the instructions ($_remainingSeconds)',
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _InstructionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withAlpha(140),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
