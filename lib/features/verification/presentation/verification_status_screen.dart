import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_notifier.dart';
import '../data/verification_repository.dart';
import '../domain/verification_job_result.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/traveler_verification_state.dart';
import '../../profile/presentation/profile_notifier.dart';
import '../domain/verification_status.dart' as domain;
import 'verification_notifier.dart';

/// Displays the full verification journey with step-by-step progress.
///
/// Shows a large animated status icon, a descriptive title, individual
/// step completion states, and contextual actions (re-submit for failed,
/// contact support).
///
/// When [verificationJobId] is provided, polls the backend for real-time
/// verification pipeline progress.
class VerificationStatusScreen extends StatefulWidget {
  final ProfileRepository profileRepository;
  final AuthNotifier authNotifier;
  final String? verificationJobId;
  final VerificationNotifier? verificationNotifier;

  const VerificationStatusScreen({
    super.key,
    required this.profileRepository,
    required this.authNotifier,
    this.verificationJobId,
    this.verificationNotifier,
  });

  @override
  State<VerificationStatusScreen> createState() =>
      VerificationStatusScreenState();
}

class VerificationStatusScreenState extends State<VerificationStatusScreen>
    with SingleTickerProviderStateMixin {
  late final ProfileNotifier profileNotifier;
  late final AnimationController pulseController;
  late final Animation<double> pulseAnimation;
  final VerificationRepository verificationRepository =
      VerificationRepository();

  VerificationJobResult? jobResult;
  domain.VerificationStatus? domainStatus;
  Timer? pollTimer;
  int pollInterval = 2;
  int totalElapsed = 0;
  static const int maxPollDuration = 300;
  static const int maxPollInterval = 15;

  @override
  void initState() {
    super.initState();
    profileNotifier = ProfileNotifier(repository: widget.profileRepository);
    profileNotifier.addListener(onStateChanged);
    profileNotifier.loadProfile();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    // Start polling if we have a job ID (legacy fallback)
    if (widget.verificationJobId != null) {
      startPolling();
    }

    fetchDomainStatus();

    widget.verificationNotifier?.addListener(onNotifierChanged);
  }

  Future<void> fetchDomainStatus() async {
    try {
      final status = await verificationRepository.getVerificationStatus();
      if (mounted) {
        setState(() => domainStatus = status);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    stopPolling();
    widget.verificationNotifier?.removeListener(onNotifierChanged);
    profileNotifier.removeListener(onStateChanged);
    profileNotifier.dispose();
    pulseController.dispose();
    super.dispose();
  }

  void onStateChanged() {
    if (mounted) setState(() {});
  }

  void onNotifierChanged() {
    if (mounted) setState(() {});
  }

  Future<void> handleRefresh() async {
    await profileNotifier.loadProfile();
    await widget.authNotifier.refreshVerificationState();

    try {
      final status = await verificationRepository.getVerificationStatus();
      if (mounted) {
        setState(() => domainStatus = status);
      }
    } catch (_) {}

    // If we have a job ID, also poll it directly
    if (widget.verificationJobId != null) {
      try {
        final result = await verificationRepository.getVerificationJob(
          widget.verificationJobId!,
        );
        if (mounted) {
          setState(() => jobResult = result);
        }
      } catch (_) {
        // Non-critical — profile state is the primary source
      }
    }
  }

  void startPolling() {
    pollTimer?.cancel();
    pollInterval = 2;
    totalElapsed = 0;

    schedulePoll();
  }

  void schedulePoll() {
    if (totalElapsed >= maxPollDuration) {
      stopPolling();
      return;
    }

    pollTimer = Timer(Duration(seconds: pollInterval), () async {
      if (!mounted) return;

      try {
        final result = await verificationRepository.getVerificationJob(
          widget.verificationJobId!,
        );

        if (!mounted) return;

        setState(() => jobResult = result);

        if (result.isComplete) {
          stopPolling();
          await fetchDomainStatus();
          // Refresh profile and auth state to pick up the new status
          await profileNotifier.loadProfile();
          await widget.authNotifier.refreshVerificationState();
          return;
        }
      } catch (_) {
        // Non-critical — continue polling
      }

      totalElapsed += pollInterval;
      // Exponential backoff
      if (pollInterval < maxPollInterval) {
        pollInterval = (pollInterval * 2).clamp(1, maxPollInterval);
      }

      schedulePoll();
    });
  }

  void stopPolling() {
    pollTimer?.cancel();
    pollTimer = null;
  }

  /// Derives the effective verification state, considering both the
  /// profile-level onboarding step and the real-time job result.
  TravelerVerificationState get effectiveState {
    final notifier = widget.verificationNotifier;

    // 1. Check global notifier phase first (if it's polling/running)
    if (notifier != null) {
      if (notifier.phase == VerificationPhase.verified) {
        return TravelerVerificationState.verified;
      }
      if (notifier.phase == VerificationPhase.verificationFailed ||
          notifier.phase == VerificationPhase.error) {
        return TravelerVerificationState.failed;
      }
    }

    // 2. If the global notifier has a completed job result
    final notifierJobResult = notifier?.jobResult;
    if (notifierJobResult != null && notifierJobResult.isComplete) {
      if (notifierJobResult.isVerified)
        return TravelerVerificationState.verified;
      if (notifierJobResult.isFailed) return TravelerVerificationState.failed;
    }

    // 3. If the global notifier has completed its background submit immediately
    final submitResult = notifier?.submitResult;
    if (submitResult != null) {
      if (submitResult.isVerified) return TravelerVerificationState.verified;
      if (submitResult.isFailed) return TravelerVerificationState.failed;
      // We do NOT return submitted here unconditionally, because we need to
      // allow polling updates (jobResult/phase) to override it.
    }

    // 4. Local polling job result
    if (jobResult != null && jobResult!.isComplete) {
      if (jobResult!.isVerified) return TravelerVerificationState.verified;
      if (jobResult!.isFailed) return TravelerVerificationState.failed;
    }

    // If job is still processing, show submitted/processing state
    if (notifier?.phase == VerificationPhase.submitting ||
        notifier?.phase == VerificationPhase.verifying ||
        (jobResult != null && !jobResult!.isComplete) ||
        (submitResult != null && submitResult.isProcessing)) {
      return TravelerVerificationState.submitted;
    }

    // 5. Check the overall session status from the backend
    if (domainStatus != null) {
      if (domainStatus!.isVerified) return TravelerVerificationState.verified;
      if (domainStatus!.isFailed) return TravelerVerificationState.failed;

      // If there is an active session but it is NOT processing, the user is still
      // in the middle of uploading documents. Override stale profile state (which
      // might still say 'submitted' from a prior failure) to prevent misleading UI.
      if (!domainStatus!.isProcessing) {
        return TravelerVerificationState.verificationStarted;
      }
    }

    return profileNotifier.profile?.verificationState ??
        TravelerVerificationState.submitted;
  }

  double? get activeVerificationScore {
    return widget.verificationNotifier?.jobResult?.verificationScore ??
        widget.verificationNotifier?.submitResult?.verificationScore ??
        jobResult?.verificationScore;
  }

  String? get failedStep =>
      domainStatus?.failedStep ??
      widget.verificationNotifier?.verificationStatus?.failedStep;

  String? get errorReason {
    final reason =
        domainStatus?.errorReason ??
        widget.verificationNotifier?.verificationStatus?.errorReason ??
        widget.verificationNotifier?.errorMessage ??
        jobResult?.errorMessage;
    if (reason == uiMitigation) return null;
    return reason;
  }

  String? get uiMitigation =>
      domainStatus?.uiMitigation ??
      widget.verificationNotifier?.verificationStatus?.uiMitigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = effectiveState;
    final config = StatusConfig.from(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileNotifier.isLoading && profileNotifier.profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // ── Status Icon ────────────────────────────────
                    buildStatusIcon(config, state),
                    const SizedBox(height: 24),
                    // ── Title & Subtitle ──────────────────────────
                    Text(
                      config.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withAlpha(150),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // ── Verification Score ───────────────────────
                    if (activeVerificationScore != null) ...[
                      const SizedBox(height: 16),
                      VerificationScoreIndicator(
                        score: activeVerificationScore!,
                        isVerified: state == TravelerVerificationState.verified,
                      ),
                    ],
                    const SizedBox(height: 40),
                    // ── Step Checklist ────────────────────────────
                    StepChecklist(state: state),
                    const SizedBox(height: 32),
                    // ── Info Card ─────────────────────────────────
                    InfoCard(
                      state: state,
                      failedStep: failedStep,
                      errorReason: errorReason,
                      uiMitigation: uiMitigation,
                    ),
                    const SizedBox(height: 24),
                    // ── Actions ───────────────────────────────────
                    if (state.isFailed) ...[
                      FilledButton.icon(
                        onPressed: () {
                          widget.verificationNotifier?.reset();
                          context.go('/verification/passport-capture');
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Re-submit Documents'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Future: open support chat/email
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Support — coming soon!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.support_agent_rounded),
                        label: const Text('Contact Support'),
                      ),
                    ],
                    if (state.isVerified) ...[
                      FilledButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.explore_rounded),
                        label: const Text('Start Exploring'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildStatusIcon(StatusConfig config, TravelerVerificationState state) {
    final icon = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.iconGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.iconGradient.first.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(config.icon, color: Colors.white, size: 44),
    );

    // Only pulse the icon when processing
    if (state.isProcessing) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: pulseAnimation.value, child: child);
        },
        child: icon,
      );
    }

    return icon;
  }
}

// ─── Verification Score Indicator ─────────────────────────────────────────

class VerificationScoreIndicator extends StatelessWidget {
  final double score;
  final bool isVerified;

  const VerificationScoreIndicator({
    required this.score,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVerified
        ? const Color(0xFF27AE60)
        : const Color(0xFFD32F2F);
    final percentage = (score * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Confidence Score: $percentage%',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Checklist ───────────────────────────────────────────────────────

class StepChecklist extends StatelessWidget {
  final TravelerVerificationState state;

  const StepChecklist({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // All steps before the user reaches the status screen are already done
    // (profile, passport, selfie). Only "Review" varies.
    final steps = [
      StepItem(label: 'Complete Profile', status: StepStatus.completed),
      StepItem(label: 'Upload Passport', status: StepStatus.completed),
      StepItem(label: 'Selfie Verification', status: StepStatus.completed),
      StepItem(
        label: 'Identity Review',
        status: switch (state) {
          TravelerVerificationState.verified => StepStatus.completed,
          TravelerVerificationState.failed => StepStatus.failed,
          _ => StepStatus.processing,
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Steps',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return StepRow(step: step, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

enum StepStatus { completed, processing, failed }

class StepItem {
  final String label;
  final StepStatus status;

  const StepItem({required this.label, required this.status});
}

class StepRow extends StatelessWidget {
  final StepItem step;
  final bool isLast;

  const StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (IconData icon, Color color) = switch (step.status) {
      StepStatus.completed => (
        Icons.check_circle_rounded,
        const Color(0xFF27AE60),
      ),
      StepStatus.processing => (
        Icons.hourglass_top_rounded,
        const Color(0xFFE65100),
      ),
      StepStatus.failed => (Icons.cancel_rounded, const Color(0xFFD32F2F)),
    };

    final statusLabel = switch (step.status) {
      StepStatus.completed => 'Completed',
      StepStatus.processing => 'In Progress',
      StepStatus.failed => 'Failed',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          // Step connector line + icon
          SizedBox(
            width: 32,
            child: Column(children: [Icon(icon, color: color, size: 28)]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              step.label,
              style: GoogleFonts.cabin(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.cabin(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────

class InfoCard extends StatelessWidget {
  final TravelerVerificationState state;
  final String? failedStep;
  final String? errorReason;
  final String? uiMitigation;

  const InfoCard({
    required this.state,
    this.failedStep,
    this.errorReason,
    this.uiMitigation,
  });

  String formatStep(String step) {
    return step
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state == TravelerVerificationState.failed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE65100).withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE65100).withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE65100),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Verification Unsuccessful',
                  style: GoogleFonts.cabin(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (failedStep != null && failedStep!.isNotEmpty) ...[
              Text(
                'Failed at: ${formatStep(failedStep!)}',
                style: GoogleFonts.cabin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withAlpha(200),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              errorReason ??
                  'Your verification could not be completed. This may be due to unclear document images or a mismatch. Please try again.',
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
            ),
            if (uiMitigation != null && uiMitigation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE65100).withAlpha(40),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: Color(0xFFE65100),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uiMitigation!,
                        style: GoogleFonts.cabin(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withAlpha(200),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    final (IconData icon, Color color, String message) = switch (state) {
      TravelerVerificationState.submitted => (
        Icons.info_outline_rounded,
        const Color(0xFF0277BD),
        'Your documents are being verified automatically. This usually takes less than a minute.',
      ),
      TravelerVerificationState.verified => (
        Icons.celebration_rounded,
        const Color(0xFF27AE60),
        'Congratulations! Your identity has been verified. You now have full access to all TrvlEz features.',
      ),
      _ => (
        Icons.info_outline_rounded,
        const Color(0xFF0277BD),
        'Your verification status will be updated here.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cabin(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(180),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Config ────────────────────────────────────────────────────────

class StatusConfig {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;

  const StatusConfig({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
  });

  factory StatusConfig.from(TravelerVerificationState state) {
    return switch (state) {
      TravelerVerificationState.submitted => const StatusConfig(
        icon: Icons.hourglass_top_rounded,
        iconGradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        title: 'Verifying Your Identity',
        subtitle:
            'Our system is reviewing your documents. This usually takes less than a minute.',
      ),
      TravelerVerificationState.verified => const StatusConfig(
        icon: Icons.verified_rounded,
        iconGradient: [Color(0xFF10B981), Color(0xFF34D399)],
        title: 'You\'re Verified!',
        subtitle: 'Your identity has been successfully verified.',
      ),
      TravelerVerificationState.failed => const StatusConfig(
        icon: Icons.error_outline_rounded,
        iconGradient: [Color(0xFFEF4444), Color(0xFFF87171)],
        title: 'Verification Failed',
        subtitle:
            'Unfortunately, we were unable to verify your identity. Please review and re-submit.',
      ),
      _ => const StatusConfig(
        icon: Icons.pending_rounded,
        iconGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        title: 'Verification Status',
        subtitle: 'Your current verification progress.',
      ),
    };
  }
}
