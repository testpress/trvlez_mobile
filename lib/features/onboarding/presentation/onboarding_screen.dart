import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_notifier.dart';
import 'widgets/onboarding_stepper.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLoading = profileNotifier.isLoading;
    final step = profileNotifier.profile?.onboardingStep ?? 'profile_pending';

    // Map backend steps to visual progress
    final bool isProfileComplete = step != 'profile_pending';
    final bool isPassportComplete =
        step == 'verification_started' ||
        step == 'documents_uploaded' ||
        step == 'submitted' ||
        step == 'verified';
    final bool isSelfieComplete =
        step == 'documents_uploaded' ||
        step == 'submitted' ||
        step == 'verified';
    final bool isFullyVerified = step == 'verified';

    int completedSteps = 0;
    if (isProfileComplete) completedSteps++;
    if (isPassportComplete) completedSteps++;
    if (isSelfieComplete) completedSteps++;

    final double progress = completedSteps / 3.0;

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
                      Text(
                        'Welcome to TrvlEz!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete these steps to unlock full access to all features.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedSteps of 3 Steps Completed',
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
                      const SizedBox(height: 40),

                      // Stepper
                      OnboardingStepper(
                        steps: [
                          OnboardingStepItem(
                            title: 'Complete Profile',
                            subtitle:
                                'Provide your basic information and preferences.',
                            state: isProfileComplete
                                ? OnboardingStepState.completed
                                : OnboardingStepState.active,
                            onTap: isProfileComplete
                                ? null
                                : () async {
                                    await context.push('/profile-setup');
                                    loadProfile(); // Refresh when returning
                                  },
                          ),
                          OnboardingStepItem(
                            title: 'Upload Passport',
                            subtitle: isPassportComplete
                                ? 'Passport uploaded successfully.'
                                : 'Capture a clear photo of your passport.',
                            state: isPassportComplete
                                ? OnboardingStepState.completed
                                : (isProfileComplete
                                      ? OnboardingStepState.active
                                      : OnboardingStepState.upcoming),
                            onTap: (isProfileComplete && !isPassportComplete)
                                ? () async {
                                    await context.push(
                                      '/verification/passport-capture',
                                    );
                                    loadProfile(); // Refresh when returning
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
                                : (isPassportComplete
                                      ? OnboardingStepState.active
                                      : OnboardingStepState.upcoming),
                            onTap: (isPassportComplete && !isSelfieComplete)
                                ? () async {
                                    await context.push(
                                      '/verification/selfie-instructions',
                                    );
                                    loadProfile(); // Refresh when returning
                                  }
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      if (isSelfieComplete && !isFullyVerified)
                        Container(
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
                        ),
                      if (isFullyVerified)
                        FilledButton(
                          onPressed: () {
                            // Navigate to home
                          },
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
}
