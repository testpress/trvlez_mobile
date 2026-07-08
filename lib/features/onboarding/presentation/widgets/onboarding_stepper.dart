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
        ? Colors.green
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(50);

    final borderColor = isCompleted
        ? Colors.green
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(50);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: step.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary.withAlpha(15)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? colorScheme.primary.withAlpha(50)
                    : theme.dividerColor.withAlpha(30),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                    color: isCompleted
                        ? Colors.green.withAlpha(20)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : (isActive
                              ? Icons.play_arrow_rounded
                              : Icons.lock_outline),
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isActive || isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: GoogleFonts.cabin(
                          fontSize: 14,
                          color: colorScheme.onSurface.withAlpha(
                            isActive ? 200 : 120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
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
