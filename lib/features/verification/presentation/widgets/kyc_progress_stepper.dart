import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A shared horizontal stepper for the KYC verification flow.
///
/// Displays 4 steps: Passport, Profile Review, Selfie, NFC.
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return _buildStepCircle(index, progressIndex, colorScheme);
      }),
    );
  }

  Widget _buildStepCircle(
    int index,
    int currentProgressIndex,
    ColorScheme colorScheme,
  ) {
    final stepLabels = ['Passport', 'Profile Review', 'Selfie', 'NFC'];

    bool isActive = currentProgressIndex == index;
    bool isCompleted = currentProgressIndex > index;

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
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 6),
                Text(
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
              ],
            ),
          ),
          if (index < 3)
            Container(
              width: 24,
              height: 2.5,
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
