import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/app/colors.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/document_processing_visual.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/processing_step_indicator.dart';

/// Minimum time each processing stage is displayed to prevent flash-skipping.
const Duration _minimumStageDuration = Duration(milliseconds: 500);

/// Duration the "all checks passed" success state is shown before navigating.
const Duration _successDisplayDuration = Duration(milliseconds: 1500);

/// A calm, story-like verification processing screen.
///
/// Replaces the previous generic loading spinner overlay with a dedicated
/// processing experience that visually communicates the verification journey.
///
/// This is a single screen with evolving state — NOT multiple screens.
/// The layout remains stable while content (title, subtitle, visual, step
/// indicator) transitions smoothly between stages.
///
/// When the backend transitions faster than [_minimumStageDuration], stages
/// are queued and displayed sequentially so the traveler can follow each step.
/// An intermediate "quality passed" stage is inserted between checking and
/// reading/completed to explicitly confirm that checks passed.
class VerificationProcessingScreen extends ConsumerStatefulWidget {
  final ProcessingType type;

  const VerificationProcessingScreen({super.key, required this.type});

  @override
  ConsumerState<VerificationProcessingScreen> createState() =>
      _VerificationProcessingScreenState();
}

class _VerificationProcessingScreenState
    extends ConsumerState<VerificationProcessingScreen> {
  /// The stage currently being displayed to the user.
  late ProcessingStage _displayedStage;

  /// Queued stages waiting to be shown after minimum display durations.
  final List<ProcessingStage> _pendingStages = [];

  /// When the current stage was first displayed.
  DateTime _stageShownAt = DateTime.now();

  /// Timer for enforcing minimum stage display duration.
  Timer? _drainTimer;

  /// Timer for auto-navigating after success.
  Timer? _successTimer;

  /// Whether we've already navigated away (prevents double-navigation).
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _displayedStage = _resolveStage(ref.read(verificationNotifierProvider));
    _stageShownAt = DateTime.now();
  }

  @override
  void dispose() {
    _drainTimer?.cancel();
    _successTimer?.cancel();
    super.dispose();
  }

  ProcessingStage _resolveStage(VerificationState state) {
    return switch (widget.type) {
      ProcessingType.passport => ProcessingStage.forPassport(
        state.phase,
        errorMessage: state.errorMessage,
      ),
      ProcessingType.video => ProcessingStage.forVideo(
        state.phase,
        errorMessage: state.errorMessage,
      ),
    };
  }

  /// Enqueues a new backend stage, inserting intermediate quality-passed
  /// stages when appropriate.
  void _enqueueStage(ProcessingStage newStage) {
    if (!mounted) return;

    // Determine the effective current stage (last in queue or displayed)
    final effectiveCurrent = _pendingStages.isNotEmpty
        ? _pendingStages.last
        : _displayedStage;

    // Insert quality-passed intermediate when transitioning from checking
    final isQualityCheckSuccess =
        effectiveCurrent.type == ProcessingStageType.checking &&
        (newStage.type == ProcessingStageType.reading ||
            newStage.type == ProcessingStageType.completed);

    if (isQualityCheckSuccess) {
      final qualityPassed = widget.type == ProcessingType.passport
          ? ProcessingStage.passportQualityPassed
          : ProcessingStage.videoQualityPassed;
      _pendingStages.add(qualityPassed);
    }

    _pendingStages.add(newStage);
    _drainQueue();
  }

  /// Drains the pending stage queue one stage at a time, respecting
  /// the minimum display duration for each stage.
  void _drainQueue() {
    if (_pendingStages.isEmpty || !mounted) return;

    final elapsed = DateTime.now().difference(_stageShownAt);
    final remaining = _minimumStageDuration - elapsed;

    if (remaining <= Duration.zero) {
      final next = _pendingStages.removeAt(0);
      _applyStage(next);

      // Schedule next drain if more stages are pending
      if (_pendingStages.isNotEmpty) {
        _drainTimer?.cancel();
        _drainTimer = Timer(_minimumStageDuration, () {
          if (mounted) _drainQueue();
        });
      }
    } else {
      // Wait for remaining minimum duration, then drain
      _drainTimer?.cancel();
      _drainTimer = Timer(remaining, () {
        if (mounted) _drainQueue();
      });
    }
  }

  void _applyStage(ProcessingStage stage) {
    if (!mounted) return;

    // Skip if identical to what's already displayed
    if (stage.type == _displayedStage.type &&
        stage.title == _displayedStage.title) {
      return;
    }

    setState(() {
      _displayedStage = stage;
      _stageShownAt = DateTime.now();
    });

    // Auto-navigate on completion after showing success briefly
    if (stage.type == ProcessingStageType.completed && !_hasNavigated) {
      _successTimer?.cancel();
      _successTimer = Timer(_successDisplayDuration, _navigateToNextScreen);
    }
  }

  void _navigateToNextScreen() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    if (widget.type == ProcessingType.passport) {
      context.go(AppRoutes.mrzReview);
    } else {
      context.go(AppRoutes.nfcIntro);
    }
  }

  void _handleRetry() {
    final notifier = ref.read(verificationNotifierProvider.notifier);

    if (widget.type == ProcessingType.passport) {
      notifier.clearImage();
      context.go(AppRoutes.passportCapture);
    } else {
      notifier.clearVideo();
      context.go(AppRoutes.selfieCapture);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to backend state changes and enqueue stages
    ref.listen<VerificationState>(verificationNotifierProvider, (
      previous,
      next,
    ) {
      final newStage = _resolveStage(next);
      _enqueueStage(newStage);
    });

    final stage = _displayedStage;
    final stepLabels = ProcessingStage.stepLabels(widget.type);
    final kycStepIndex = widget.type == ProcessingType.passport ? 0 : 2;

    return PopScope(
      canPop: stage.isTerminal,
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
          leading: stage.isTerminal
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface,
                    size: 18,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                )
              : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KycProgressStepper(progressIndex: kycStepIndex),
                const SizedBox(height: 24),
                _buildProcessingCard(theme, colorScheme, stage, stepLabels),
                const SizedBox(height: 32),
                _buildFooter(colorScheme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingCard(
    ThemeData theme,
    ColorScheme colorScheme,
    ProcessingStage stage,
    List<String> stepLabels,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVisual(stage),
          const SizedBox(height: 28),
          ProcessingStepIndicator(
            labels: stepLabels,
            currentIndex: stage.stepIndex(widget.type),
            isCompleted: stage.type == ProcessingStageType.completed,
            isFailed: stage.type == ProcessingStageType.failed,
          ),
          const SizedBox(height: 28),
          _buildAnimatedText(
            key: ValueKey('title_${stage.title}'),
            text: stage.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildAnimatedText(
            key: ValueKey('subtitle_${stage.subtitle}'),
            text: stage.subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          if (stage.type == ProcessingStageType.failed) ...[
            const SizedBox(height: 32),
            _buildRetryButton(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildVisual(ProcessingStage stage) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: DocumentProcessingVisual(
        key: ValueKey(stage.type),
        stageType: stage.type,
        processingType: widget.type,
      ),
    );
  }

  Widget _buildAnimatedText({
    required Key key,
    required String text,
    TextStyle? style,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(text, key: key, textAlign: TextAlign.center, style: style),
    );
  }

  Widget _buildRetryButton(ColorScheme colorScheme) {
    final retryLabel = widget.type == ProcessingType.passport
        ? 'Retake Passport'
        : 'Record Again';

    return ElevatedButton(
      onPressed: _handleRetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      child: Text(
        retryLabel,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Center(
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
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
