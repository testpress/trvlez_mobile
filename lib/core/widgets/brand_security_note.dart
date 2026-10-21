import 'package:flutter/widgets.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The security commitment note at the bottom of brand authentication & verification screens.
class BrandSecurityNote extends StatelessWidget {
  const BrandSecurityNote({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 10,
    this.iconWidth = 10,
    this.iconHeight = 11,
  });

  /// The promise string (e.g. "Encrypted and never shared with external AI")
  final String text;

  /// Optional text/icon color override. Defaults to [AppColors.brandSecondaryNote].
  final Color? color;

  /// Font size for the note
  final double fontSize;

  /// Dimensions for the padlock icon
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    final noteColor = color ?? colors.brandSecondaryNote;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: shape.borderMedium),
          child: SizedBox(
            width: iconWidth,
            height: iconHeight,
            child: CustomPaint(
              painter: _PadlockPainter(noteColor, shape.borderMedium),
            ),
          ),
        ),
        SizedBox(width: space.inlineMicro),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: TypeScale.regular,
              color: noteColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _PadlockPainter extends CustomPainter {
  const _PadlockPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 12;
    final sy = size.height / 14;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5 * sx, 6 * sy, 9 * sx, 7 * sy),
        Radius.circular(1.6 * sx),
      ),
      p,
    );

    final shackle = Path()
      ..moveTo(3.6 * sx, 6 * sy)
      ..lineTo(3.6 * sx, 4 * sy)
      ..arcToPoint(
        Offset(8.4 * sx, 4 * sy),
        radius: Radius.circular(2.4 * sx),
        clockwise: true,
      )
      ..lineTo(8.4 * sx, 6 * sy);
    canvas.drawPath(shackle, p);
  }

  @override
  bool shouldRepaint(_PadlockPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
