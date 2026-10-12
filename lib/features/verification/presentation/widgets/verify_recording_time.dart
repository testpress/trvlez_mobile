import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Indicator row showing red dot and recording seconds (e.g. 0:04).
class VerifyRecordingTime extends StatelessWidget {
  const VerifyRecordingTime({super.key, required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.brandOnSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '0:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.medium,
            color: colors.brandOnSurface,
          ),
        ),
      ],
    );
  }
}
