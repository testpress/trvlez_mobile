import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/onboarding/presentation/widgets/onboarding_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/app/routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadProfile() async {
    final _ = await ref.refresh(currentProfileProvider.future);
  }

  int _stepToProgressIndex(String step) {
    switch (step) {
      case 'profile_pending':
      case 'profile_complete':
        return 0;
      case 'verification_started':
        return 0;
      case 'passport_reviewed':
        return 2;
      case 'documents_uploaded':
        return 3;
      case 'submitted':
        return 4;
      case 'verified':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLoading = profileState.isLoading;
    final step = profileState.value?.onboardingStep ?? 'profile_pending';
    final progressIndex = _stepToProgressIndex(step);

    final bool isPassportUploaded = progressIndex >= 1;
    final bool isReviewComplete = progressIndex >= 2;
    final bool isSelfieComplete = progressIndex >= 3;
    final bool isNfcComplete = progressIndex >= 4;
    final bool isFullyVerified = step == 'verified';

    int completedSteps = 0;
    if (isPassportUploaded) completedSteps++;
    if (isReviewComplete) completedSteps++;
    if (isSelfieComplete) completedSteps++;
    if (isNfcComplete) completedSteps++;

    final double progressValue = completedSteps / 4.0;

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
      ),
      body: isLoading && profileState.value == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Horizontal Stepper Progress Indicator
                      KycProgressStepper(progressIndex: progressIndex),
                      const SizedBox(height: 24),

                      // Central Card Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
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
                            Text(
                              'Welcome to TrvlEz!',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verify your identity to unlock full access.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildProgress(
                              progressValue,
                              completedSteps,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildStepper(
                              isPassportUploaded: isPassportUploaded,
                              isReviewComplete: isReviewComplete,
                              isSelfieComplete: isSelfieComplete,
                              isNfcComplete: isNfcComplete,
                            ),
                            if (isNfcComplete && !isFullyVerified) ...[
                              const SizedBox(height: 12),
                              _buildReviewNotice(colorScheme),
                            ],
                            if (isFullyVerified) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.go(AppRoutes.home),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.onSurface,
                                  foregroundColor: colorScheme.surface,
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Explore TrvlEz',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
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
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
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
                                    color: const Color(0xFF25D366),
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
            ),
    );
  }

  Widget _buildProgress(
    double progressValue,
    int completedSteps,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedSteps of 4 Steps Completed',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progressValue * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 6,
            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewNotice(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your identity verification is currently under review.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({
    required bool isPassportUploaded,
    required bool isReviewComplete,
    required bool isSelfieComplete,
    required bool isNfcComplete,
  }) {
    return OnboardingStepper(
      steps: [
        OnboardingStepItem(
          title: 'Upload Passport',
          subtitle: isPassportUploaded
              ? 'Passport uploaded successfully.'
              : 'Capture a clear photo of your passport.',
          state: isPassportUploaded
              ? OnboardingStepState.completed
              : OnboardingStepState.active,
          onTap: !isPassportUploaded
              ? () async {
                  await context.push(AppRoutes.passportCapture);
                  loadProfile();
                }
              : null,
        ),
        OnboardingStepItem(
          title: 'Review Details',
          subtitle: isReviewComplete
              ? 'Passport details confirmed.'
              : 'Verify your extracted passport information.',
          state: isReviewComplete
              ? OnboardingStepState.completed
              : (isPassportUploaded
                    ? OnboardingStepState.active
                    : OnboardingStepState.upcoming),
          onTap: (isPassportUploaded && !isReviewComplete)
              ? () async {
                  await context.push(AppRoutes.mrzReview);
                  loadProfile();
                }
              : null,
        ),
        OnboardingStepItem(
          title: 'Selfie Verification',
          subtitle: isSelfieComplete
              ? 'Selfie video recorded successfully.'
              : 'Record a short video to verify your identity.',
          state: isSelfieComplete
              ? OnboardingStepState.completed
              : (isReviewComplete
                    ? OnboardingStepState.active
                    : OnboardingStepState.upcoming),
          onTap: (isReviewComplete && !isSelfieComplete)
              ? () async {
                  await context.push(AppRoutes.selfieInstructions);
                  loadProfile();
                }
              : null,
        ),
        OnboardingStepItem(
          title: 'NFC Verification',
          subtitle: isNfcComplete
              ? 'NFC scan complete.'
              : 'Scan your passport chip for extra security.',
          state: isNfcComplete
              ? OnboardingStepState.completed
              : (isSelfieComplete
                    ? OnboardingStepState.active
                    : OnboardingStepState.upcoming),
          onTap: (isSelfieComplete && !isNfcComplete)
              ? () async {
                  await context.push(AppRoutes.nfcIntro);
                  loadProfile();
                }
              : null,
        ),
      ],
    );
  }
}
