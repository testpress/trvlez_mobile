import 'package:flutter/widgets.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The TrvlEz brand wordmark.
///
/// Features "TRVL" with the signature vector paper-plane glyph and "ez".
/// Uses semantic tokens from `context.colors`.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.planeWidth,
    this.gap,
    this.fontSize,
    this.trvlColor,
    this.ezColor,
  });

  /// Design width of the paper plane glyph.
  final double? planeWidth;

  /// Gap between text and plane.
  final double? gap;

  /// Optional font size for TRVL and ez. Defaults to [TextTheme.displaySmall].
  final double? fontSize;

  /// Optional color override for "TRVL". Defaults to [AppColors.brandOnSurface].
  final Color? trvlColor;

  /// Optional color override for "ez" and the plane. Defaults to [AppColors.brandSecondary].
  final Color? ezColor;

  @override
  Widget build(BuildContext context) {
    final trvlCol = trvlColor ?? context.colors.brandOnSurface;
    final ezCol = ezColor ?? context.colors.brandSecondary;
    final space = context.space;
    final sizes = context.sizes;

    final effectivePlaneWidth = planeWidth ?? sizes.iconMd;
    final effectiveGap = gap ?? space.inlineIconLabel;
    final effectiveFontSize =
        fontSize ?? context.text.displaySmall?.fontSize ?? sizes.iconDefault;

    final baseStyle = (context.text.displaySmall ?? const TextStyle()).copyWith(
      fontSize: effectiveFontSize,
      fontWeight: TypeScale.bold,
      height: 1.0,
      letterSpacing: 0.4,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('TRVL', style: baseStyle.copyWith(color: trvlCol)),
        SizedBox(width: effectiveGap),
        SizedBox(
          width: effectivePlaneWidth,
          height: effectivePlaneWidth * (16 / 20),
          child: CustomPaint(painter: _PlanePainter(ezCol)),
        ),
        SizedBox(width: effectiveGap),
        Text('ez', style: baseStyle.copyWith(color: ezCol)),
      ],
    );
  }
}

class _PlanePainter extends CustomPainter {
  const _PlanePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 20;
    final sy = size.height / 16;
    final path = Path()
      ..moveTo(20 * sx, 8 * sy)
      ..lineTo(0, 0)
      ..lineTo(7 * sx, 8 * sy)
      ..lineTo(0, 16 * sy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PlanePainter old) => old.color != color;
}
