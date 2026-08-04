import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A shared horizontal stepper for the KYC verification flow.
///
/// Displays 4 steps: Passport, Passport Review, Selfie, NFC.
/// Indicates active, completed, and upcoming steps based on [progressIndex].
class KycProgressStepper extends StatelessWidget {
  final int progressIndex;

  const KycProgressStepper({
    super.key,
    required this.progressIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stepLabels = ['Passport', 'Profile Review', 'Selfie', 'NFC'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Row: Circles & Connecting Lines
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = progressIndex == index;
            final isCompleted = progressIndex > index;

            final circleColor = isActive || isCompleted
                ? colorScheme.primary
                : colorScheme.surface;
            final textColor = isActive
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.65);
            final borderColor = isActive || isCompleted
                ? colorScheme.primary
                : colorScheme.outlineVariant;

            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Line segment before circle
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: progressIndex >= index
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                  ),
                  // Circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: circleColor,
                      border: Border.all(color: borderColor, width: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: colorScheme.onPrimary,
                              size: 14,
                            )
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                  // Line segment after circle
                  Expanded(
                    child: index == 3
                        ? const SizedBox()
                        : Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: progressIndex > index
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Bottom Row: Step Labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (index) {
            final isActive = progressIndex == index;

            return Expanded(
              child: Text(
                stepLabels[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
