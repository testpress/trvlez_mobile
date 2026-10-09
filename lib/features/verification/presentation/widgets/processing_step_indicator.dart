import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// A subtle horizontal step indicator for verification processing stages.
///
/// Displays a series of dots connected by lines, with labels below.
/// Completed steps show a checkmark, the active step pulses with primary color,
/// and upcoming steps are muted.
///
/// Example: ✓ Upload  ● Check  ○ Read
class ProcessingStepIndicator extends StatelessWidget {
  /// Labels for each step (e.g. ['Upload', 'Check', 'Read']).
  final List<String> labels;

  /// 0-based index of the currently active step.
  final int currentIndex;

  /// Whether the current stage represents completion of all steps.
  final bool isCompleted;

  /// Whether the current stage represents a failure.
  final bool isFailed;

  const ProcessingStepIndicator({
    super.key,
    required this.labels,
    required this.currentIndex,
    this.isCompleted = false,
    this.isFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = context.colors.feedbackSuccess;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(labels.length * 2 - 1, (index) {
        // Odd indices are connector lines
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isConnected = isCompleted || stepBefore < currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 1.5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isConnected
                  ? successColor.withValues(alpha: 0.6)
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }

        // Even indices are step indicators
        final stepIndex = index ~/ 2;
        final isStepCompleted = isCompleted || stepIndex < currentIndex;
        final isActive = !isCompleted && !isFailed && stepIndex == currentIndex;
        final isUpcoming = !isCompleted && stepIndex > currentIndex;

        return _StepDot(
          label: labels[stepIndex],
          isCompleted: isStepCompleted,
          isActive: isActive,
          isUpcoming: isUpcoming,
          isFailed: isFailed && stepIndex == currentIndex,
          primaryColor: colorScheme.primary,
          successColor: successColor,
          errorColor: colorScheme.error,
          mutedColor: colorScheme.onSurface.withValues(alpha: 0.25),
          textStyle: textTheme.labelSmall!,
          onSurfaceColor: colorScheme.onSurface,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isActive;
  final bool isUpcoming;
  final bool isFailed;
  final Color primaryColor;
  final Color successColor;
  final Color errorColor;
  final Color mutedColor;
  final TextStyle textStyle;
  final Color onSurfaceColor;

  const _StepDot({
    required this.label,
    required this.isCompleted,
    required this.isActive,
    required this.isUpcoming,
    required this.isFailed,
    required this.primaryColor,
    required this.successColor,
    required this.errorColor,
    required this.mutedColor,
    required this.textStyle,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted
        ? successColor
        : isActive
        ? primaryColor
        : isFailed
        ? errorColor
        : mutedColor;

    final labelColor = isCompleted
        ? successColor
        : isActive
        ? onSurfaceColor
        : isFailed
        ? errorColor
        : onSurfaceColor.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUpcoming ? Colors.transparent : dotColor,
            border: Border.all(color: dotColor, width: isActive ? 2.0 : 1.5),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 6, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: textStyle.copyWith(
            color: labelColor,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
