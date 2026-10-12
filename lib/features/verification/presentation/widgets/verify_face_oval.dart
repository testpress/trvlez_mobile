import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// The 158x210 ellipse front-camera viewfinder with 9px translucent halo and progress arc.
class VerifyFaceOval extends StatelessWidget {
  const VerifyFaceOval({
    super.key,
    this.previewChild,
    this.progress,
    this.width = 158.0,
    this.height = 210.0,
  });

  final Widget? previewChild;
  final double? progress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const stroke = 2.5;

    return Center(
      child: SizedBox(
        width: width + 18.0,
        height: height + 18.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 9px outer halo
            Container(
              width: width + 18.0,
              height: height + 18.0,
              decoration: BoxDecoration(
                color: colors.brandOnSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.all(
                  Radius.elliptical((width + 18.0) / 2, (height + 18.0) / 2),
                ),
              ),
            ),
            // Clipped front camera or illustration
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.elliptical(width / 2, height / 2),
              ),
              child: SizedBox(
                width: width,
                height: height,
                child: ColoredBox(
                  color: colors.brandShotBackdrop,
                  child: previewChild ??
                      SvgPicture.asset(
                        'assets/art/camera_face.svg',
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
            // Progress ring
            SizedBox(
              width: width + stroke,
              height: height + stroke,
              child: CustomPaint(
                painter: _OvalRingPainter(
                  progress: progress,
                  stroke: stroke,
                  ringColor: colors.brandOnSurface.withValues(alpha: 0.55),
                  activeColor: colors.brandOnSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OvalRingPainter extends CustomPainter {
  const _OvalRingPainter({
    required this.progress,
    required this.stroke,
    required this.ringColor,
    required this.activeColor,
  });

  final double? progress;
  final double stroke;
  final Color ringColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = ringColor;

    canvas.drawOval(rect.deflate(stroke / 2), base);

    final p = progress;
    if (p == null || p <= 0) return;

    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2 * p.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(_OvalRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.stroke != stroke;
}
