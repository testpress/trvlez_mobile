import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/traveler_verification_state.dart';
import '../../profile/presentation/profile_notifier.dart';

/// Displays the full verification journey with step-by-step progress.
///
/// Shows a large animated status icon, a descriptive title, individual
/// step completion states, and contextual actions (re-submit for failed,
/// contact support).
class VerificationStatusScreen extends StatefulWidget {
  final ProfileRepository profileRepository;
  final AuthNotifier authNotifier;

  const VerificationStatusScreen({
    super.key,
    required this.profileRepository,
    required this.authNotifier,
  });

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen>
    with SingleTickerProviderStateMixin {
  late final ProfileNotifier _profileNotifier;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _profileNotifier = ProfileNotifier(repository: widget.profileRepository);
    _profileNotifier.addListener(_onStateChanged);
    _profileNotifier.loadProfile();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onStateChanged);
    _profileNotifier.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleRefresh() async {
    await _profileNotifier.loadProfile();
    await widget.authNotifier.refreshVerificationState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = _profileNotifier.profile?.verificationState ??
        TravelerVerificationState.submitted;
    final config = _StatusConfig.from(state);

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
      body: _profileNotifier.isLoading && _profileNotifier.profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // ── Status Icon ────────────────────────────────
                    _buildStatusIcon(config, state),
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
                    const SizedBox(height: 40),
                    // ── Step Checklist ────────────────────────────
                    _StepChecklist(state: state),
                    const SizedBox(height: 32),
                    // ── Info Card ─────────────────────────────────
                    _InfoCard(state: state),
                    const SizedBox(height: 24),
                    // ── Actions ───────────────────────────────────
                    if (state.isFailed) ...[
                      FilledButton.icon(
                        onPressed: () {
                          // Navigate back to onboarding to re-upload
                          context.go('/onboarding');
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
                              content: const Text(
                                'Support — coming soon!',
                              ),
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusIcon(_StatusConfig config, TravelerVerificationState state) {
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
      child: Icon(
        config.icon,
        color: Colors.white,
        size: 44,
      ),
    );

    // Only pulse the icon when processing
    if (state.isProcessing) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: icon,
      );
    }

    return icon;
  }
}

// ─── Step Checklist ───────────────────────────────────────────────────────

class _StepChecklist extends StatelessWidget {
  final TravelerVerificationState state;

  const _StepChecklist({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // All steps before the user reaches the status screen are already done
    // (profile, passport, selfie). Only "Review" varies.
    final steps = [
      _StepItem(
        label: 'Complete Profile',
        status: _StepStatus.completed,
      ),
      _StepItem(
        label: 'Upload Passport',
        status: _StepStatus.completed,
      ),
      _StepItem(
        label: 'Selfie Verification',
        status: _StepStatus.completed,
      ),
      _StepItem(
        label: 'Identity Review',
        status: switch (state) {
          TravelerVerificationState.verified => _StepStatus.completed,
          TravelerVerificationState.failed => _StepStatus.failed,
          _ => _StepStatus.processing,
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

            return _StepRow(
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

enum _StepStatus { completed, processing, failed }

class _StepItem {
  final String label;
  final _StepStatus status;

  const _StepItem({required this.label, required this.status});
}

class _StepRow extends StatelessWidget {
  final _StepItem step;
  final bool isLast;

  const _StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (IconData icon, Color color) = switch (step.status) {
      _StepStatus.completed => (Icons.check_circle_rounded, const Color(0xFF27AE60)),
      _StepStatus.processing => (Icons.hourglass_top_rounded, const Color(0xFFE65100)),
      _StepStatus.failed => (Icons.cancel_rounded, const Color(0xFFD32F2F)),
    };

    final statusLabel = switch (step.status) {
      _StepStatus.completed => 'Completed',
      _StepStatus.processing => 'In Progress',
      _StepStatus.failed => 'Failed',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          // Step connector line + icon
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
              ],
            ),
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

class _InfoCard extends StatelessWidget {
  final TravelerVerificationState state;

  const _InfoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (IconData icon, Color color, String message) = switch (state) {
      TravelerVerificationState.submitted => (
          Icons.info_outline_rounded,
          const Color(0xFF0277BD),
          'Verification typically takes 1–2 business days. We\'ll notify you when it\'s complete.',
        ),
      TravelerVerificationState.verified => (
          Icons.celebration_rounded,
          const Color(0xFF27AE60),
          'Congratulations! Your identity has been verified. You now have full access to all TrvlEz features.',
        ),
      TravelerVerificationState.failed => (
          Icons.warning_amber_rounded,
          const Color(0xFFE65100),
          'Your verification could not be completed. This may be due to unclear document images or a mismatch. Please try again.',
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
        border: Border.all(
          color: color.withAlpha(40),
        ),
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

class _StatusConfig {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String subtitle;

  const _StatusConfig({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
  });

  factory _StatusConfig.from(TravelerVerificationState state) {
    return switch (state) {
      TravelerVerificationState.submitted => const _StatusConfig(
          icon: Icons.hourglass_top_rounded,
          iconGradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          title: 'Verification In Progress',
          subtitle: 'Sit tight — our team is reviewing your documents.',
        ),
      TravelerVerificationState.verified => const _StatusConfig(
          icon: Icons.verified_rounded,
          iconGradient: [Color(0xFF10B981), Color(0xFF34D399)],
          title: 'You\'re Verified!',
          subtitle: 'Your identity has been successfully verified.',
        ),
      TravelerVerificationState.failed => const _StatusConfig(
          icon: Icons.error_outline_rounded,
          iconGradient: [Color(0xFFEF4444), Color(0xFFF87171)],
          title: 'Verification Failed',
          subtitle:
              'Unfortunately, we were unable to verify your identity. Please review and re-submit.',
        ),
      _ => const _StatusConfig(
          icon: Icons.pending_rounded,
          iconGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          title: 'Verification Status',
          subtitle: 'Your current verification progress.',
        ),
    };
  }
}
