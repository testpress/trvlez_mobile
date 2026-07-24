import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/core/auth/auth_notifier.dart';import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_progress_bar.dart';import 'package:trvlez_mobile/features/onboarding/presentation/widgets/onboarding_stepper.dart';
class OnboardingScreen extends StatefulWidget {
  final AuthNotifier authNotifier;
  final ProfileRepository profileRepository;

  const OnboardingScreen({
    super.key,
    required this.authNotifier,
    required this.profileRepository,
  });

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  late final ProfileNotifier profileNotifier;

  @override
  void initState() {
    super.initState();
    profileNotifier = ProfileNotifier(repository: widget.profileRepository);
    profileNotifier.addListener(onProfileChanged);
    loadProfile();
  }

  @override
  void dispose() {
    profileNotifier.removeListener(onProfileChanged);
    profileNotifier.dispose();
    super.dispose();
  }

  void onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> loadProfile() async {
    await profileNotifier.loadProfile();
  }

  /// Maps the backend onboarding step to the progress bar step index (0-4).
  int _stepToProgressIndex(String step) {
    switch (step) {
      case 'profile_pending':
      case 'profile_complete':
        return 0; // Passport step
      case 'verification_started':
        return 0; // Session started, passport capture in progress
      case 'passport_reviewed':
        return 2; // Selfie step
      case 'documents_uploaded':
        return 3; // NFC step
      case 'submitted':
        return 4; // Done step
      case 'verified':
        return 5; // All complete
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLoading = profileNotifier.isLoading;
    final step = profileNotifier.profile?.onboardingStep ?? 'profile_pending';

    // Map backend steps to the 5-step passport-first flow
    final progressIndex = _stepToProgressIndex(step);

    final bool isPassportUploaded = progressIndex >= 1;
    final bool isReviewComplete = progressIndex >= 2;
    final bool isSelfieComplete = progressIndex >= 3;
    final bool isNfcComplete = progressIndex >= 4;
    final bool isFullyVerified = step == 'verified';

    // Count completed steps out of 4 actionable steps
    int completedSteps = 0;
    if (isPassportUploaded) completedSteps++;
    if (isReviewComplete) completedSteps++;
    if (isSelfieComplete) completedSteps++;
    if (isNfcComplete) completedSteps++;

    final double progress = completedSteps / 4.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting Started'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading && profileNotifier.profile == null
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
                      _buildHeader(theme, colorScheme),
                      const SizedBox(height: 24),
                      VerificationProgressBar.verification(
                        currentStepIndex: progressIndex.clamp(0, 4),
                      ),
                      const SizedBox(height: 16),
                      _buildProgress(progress, completedSteps, colorScheme),
                      const SizedBox(height: 32),
                      _buildStepper(
                        isPassportUploaded: isPassportUploaded,
                        isReviewComplete: isReviewComplete,
                        isSelfieComplete: isSelfieComplete,
                        isNfcComplete: isNfcComplete,
                      ),
                      const SizedBox(height: 40),
                      if (isNfcComplete && !isFullyVerified)
                        _buildReviewNotice(colorScheme),
                      if (isFullyVerified)
                        FilledButton(
                          onPressed: () => context.go('/home'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Explore TrvlEz'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome to TrvlEz!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verify your identity to unlock full access.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(double progress, int completedSteps, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedSteps of 4 Steps Completed',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: colorScheme.primary.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewNotice(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your identity verification is currently under review.',
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
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
                  await context.push('/verification/passport-capture');
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
                  await context.push('/verification/mrz-review');
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
                  await context.push('/verification/selfie-instructions');
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
                  await context.push('/verification/nfc-intro');
                  loadProfile();
                }
              : null,
        ),
      ],
    );
  }
}
