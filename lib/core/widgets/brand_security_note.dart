import 'package:flutter/widgets.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// The security commitment note at the bottom of brand authentication & verification screens.
class BrandSecurityNote extends StatelessWidget {
  const BrandSecurityNote({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.iconWidth,
    this.iconHeight,
  });

  /// The promise string (e.g. "Encrypted and never shared with external AI")
  final String text;

  /// Optional text/icon color override. Defaults to [AppColors.brandSecondaryNote].
  final Color? color;

  /// Optional font size override for the note. Defaults to [TextTheme.bodySmall].
  final double? fontSize;

  /// Optional dimensions for the padlock icon. Defaults to [AppSize.iconMicro].
  final double? iconWidth;
  final double? iconHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final noteColor = color ?? colors.brandSecondaryNote;
    final effectiveWidth = iconWidth ?? sizes.iconMicro;
    final effectiveHeight = iconHeight ?? sizes.iconMicro;
    final effectiveFontSize = fontSize ?? context.text.bodySmall?.fontSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: shape.borderMedium),
          child: SizedBox(
            width: effectiveWidth,
            height: effectiveHeight,
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
            style: context.text.bodySmall?.copyWith(
              fontSize: effectiveFontSize,
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
