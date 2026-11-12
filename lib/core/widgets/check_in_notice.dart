import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Centered small promise text at the foot of check-in screens.
class CheckInNotice extends StatelessWidget {
  const CheckInNotice({super.key, required this.text, this.marginTop});

  final String text;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Padding(
      padding: EdgeInsets.only(top: marginTop ?? space.stackItem),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.bodySmall?.copyWith(
          color: colors.brandSecondaryNote,
          height: 1.35,
        ),
      ),
    );
  }
}
