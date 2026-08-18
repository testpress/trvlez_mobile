import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationScoreIndicator extends StatelessWidget {
  final double score;
  final bool isVerified;

  const VerificationScoreIndicator({
    super.key,
    required this.score,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isVerified
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
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
