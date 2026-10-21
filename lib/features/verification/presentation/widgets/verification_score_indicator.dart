import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';

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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final color = isVerified
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final percentage = (score * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: space.insetCardComfortable.left,
        vertical: space.inlineButtonGroup,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: shape.radiusControl,
        border: Border.all(
          color: color.withAlpha(40),
          width: shape.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: color,
            size: sizes.iconMd,
          ),
          SizedBox(width: space.inlineIconLabel),
          Text(
            'Confidence Score: $percentage%',
            style: AppTypography.heading.copyWith(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
