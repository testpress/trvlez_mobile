import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OnboardingStepState { completed, active, upcoming }

class OnboardingStepItem {
  final String title;
  final String subtitle;
  final OnboardingStepState state;
  final VoidCallback? onTap;

  const OnboardingStepItem({
    required this.title,
    required this.subtitle,
    required this.state,
    this.onTap,
  });
}

class OnboardingStepper extends StatelessWidget {
  final List<OnboardingStepItem> steps;

  const OnboardingStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final step = steps[index];
        return buildStep(context, step);
      },
    );
  }

  Widget buildStep(BuildContext context, OnboardingStepItem step) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = step.state == OnboardingStepState.active;
    final isCompleted = step.state == OnboardingStepState.completed;

    final iconColor = isCompleted
        ? colorScheme.onPrimary
        : isActive
            ? colorScheme.onPrimary
            : colorScheme.onSurface.withValues(alpha: 0.6);

    final circleColor = isCompleted
        ? colorScheme.primary
        : isActive
            ? colorScheme.primary
            : colorScheme.surface;

    final borderColor = isCompleted
        ? colorScheme.primary
        : isActive
            ? colorScheme.primary
            : colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: step.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                width: isActive ? 1.2 : 0.8,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 0.8),
                    color: circleColor,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check_rounded, color: colorScheme.onPrimary, size: 16)
                        : Icon(
                            isActive ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
                            color: iconColor,
                            size: 16,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive || isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
