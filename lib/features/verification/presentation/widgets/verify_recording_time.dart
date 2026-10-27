import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Indicator row showing red dot and recording seconds (e.g. 0:04).
class VerifyRecordingTime extends StatelessWidget {
  const VerifyRecordingTime({super.key, required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: sizes.indicatorDot,
          height: sizes.indicatorDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.brandOnSurface,
          ),
        ),
        SizedBox(width: space.inlineMicro),
        Text(
          '0:${seconds.toString().padLeft(2, '0')}',
          style: context.text.labelMedium?.copyWith(
            fontWeight: TypeScale.medium,
            color: colors.brandOnSurface,
          ),
        ),
      ],
    );
  }
}
