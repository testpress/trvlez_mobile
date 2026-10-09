import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

/// Step state for the verification progress bar.
enum VerificationStepState { completed, active, upcoming }

/// Horizontal step indicator for the verification pipeline.
///
/// Displays a linear 5-step flow: Passport → Review → Selfie → NFC → Complete.
/// Each step shows as completed (checkmark), active (highlighted), or upcoming (grey).
class VerificationProgressBar extends StatelessWidget {
  /// Labels for each step in the progress bar.
  final List<String> stepLabels;

  /// States for each step (must match [stepLabels] length).
  final List<VerificationStepState> stepStates;

  const VerificationProgressBar({
    super.key,
    required this.stepLabels,
    required this.stepStates,
  }) : assert(stepLabels.length == stepStates.length);

  /// Factory constructor for the default 5-step verification flow.
  factory VerificationProgressBar.verification({
    Key? key,
    required int currentStepIndex,
  }) {
    const labels = ['Passport', 'Review', 'Selfie', 'NFC', 'Done'];
    final states = List.generate(labels.length, (index) {
      if (index < currentStepIndex) return VerificationStepState.completed;
      if (index == currentStepIndex) return VerificationStepState.active;
      return VerificationStepState.upcoming;
    });
    return VerificationProgressBar(
      key: key,
      stepLabels: labels,
      stepStates: states,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(stepLabels.length * 2 - 1, (index) {
          // Even indices are steps, odd indices are connectors
          if (index.isOdd) {
            final prevStepIndex = index ~/ 2;
            final isConnected =
                stepStates[prevStepIndex] == VerificationStepState.completed;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? context.colors.feedbackSuccess
                      : colorScheme.onSurface.withAlpha(40),
                  borderRadius: AppRadius.xxsRadius,
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final state = stepStates[stepIndex];
          final label = stepLabels[stepIndex];

          return _StepIndicator(
            label: label,
            state: state,
            colorScheme: colorScheme,
          );
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final VerificationStepState state;
  final ColorScheme colorScheme;

  const _StepIndicator({
    required this.label,
    required this.state,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == VerificationStepState.completed;
    final isActive = state == VerificationStepState.active;

    final circleColor = isCompleted
        ? context.colors.feedbackSuccess
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(40);

    final circleSize = isActive ? 28.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? circleColor : Colors.transparent,
            border: Border.all(color: circleColor, width: isActive ? 2.5 : 2),
          ),
          child: isCompleted
              ? Icon(Icons.check, color: context.colors.textOnAction, size: 14)
              : isActive
              ? Icon(Icons.circle, color: context.colors.textOnAction, size: 8)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isCompleted
                ? context.colors.feedbackSuccess
                : isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withAlpha(100),
          ),
        ),
      ],
    );
  }
}
