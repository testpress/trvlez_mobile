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
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final ProfileNotifier _profileNotifier;

  @override
  void initState() {
    super.initState();
    _profileNotifier = ProfileNotifier(repository: widget.profileRepository);
    _profileNotifier.addListener(_onProfileChanged);
    _loadProfile();
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onProfileChanged);
    _profileNotifier.dispose();
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    await _profileNotifier.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isLoading = _profileNotifier.isLoading;
    final step = _profileNotifier.profile?.onboardingStep ?? 'profile_pending';

    // Map backend steps to visual progress
    final bool isProfileComplete = step != 'profile_pending';
    final bool isVerificationComplete = step == 'verified';
    final bool isVerificationStarted = step == 'verification_started' || step == 'documents_uploaded' || step == 'submitted';

    int completedSteps = 0;
    if (isProfileComplete) completedSteps++;
    if (isVerificationComplete) completedSteps++;

    final double progress = completedSteps / 2.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting Started'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => widget.authNotifier.logout(),
          ),
        ],
      ),
      body: isLoading && _profileNotifier.profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            '$completedSteps of 2 Steps Completed',
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
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Stepper
                      OnboardingStepper(
                        steps: [
                          OnboardingStepItem(
                            title: 'Complete Profile',
                            subtitle: 'Provide your basic information and preferences.',
                            state: isProfileComplete 
                                ? OnboardingStepState.completed 
                                : OnboardingStepState.active,
                            onTap: isProfileComplete 
                                ? null 
                                : () async {
                                    await context.push('/profile-setup');
                                    _loadProfile(); // Refresh when returning
                                  },
                          ),
                          OnboardingStepItem(
                            title: 'Verify Identity',
                            subtitle: isVerificationStarted 
                                ? 'Your identity verification is currently processing.'
                                : 'Upload your passport or ID to verify your account.',
                            state: isVerificationComplete 
                                ? OnboardingStepState.completed 
                                : (isProfileComplete ? OnboardingStepState.active : OnboardingStepState.upcoming),
                            onTap: (isProfileComplete && !isVerificationStarted && !isVerificationComplete) 
                                ? () async {
                                    await context.push('/verification/passport-capture');
                                    _loadProfile(); // Refresh when returning
                                  } 
                                : null,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      if (isVerificationComplete)
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
