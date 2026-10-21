import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// An ergonomic front-camera viewfinder oval with translucent halo,
/// subtle face alignment guidance marks, and smooth progress arc.
class VerifyFaceOval extends StatelessWidget {
  const VerifyFaceOval({
    super.key,
    this.previewChild,
    this.progress,
    this.width = 224.0,
    this.height = 296.0,
    this.showGuidanceGuides = true,
  });

  final Widget? previewChild;
  final double? progress;
  final double width;
  final double height;
  final bool showGuidanceGuides;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const stroke = 2.5;
    final isRecording = progress != null && progress! > 0;

    return Center(
      child: SizedBox(
        width: width + 20.0,
        height: height + 20.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer halo with subtle glow when actively recording
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: width + 18.0,
              height: height + 18.0,
              decoration: BoxDecoration(
                color: colors.brandOnSurface.withValues(
                  alpha: isRecording ? 0.16 : 0.08,
                ),
                borderRadius: BorderRadius.all(
                  Radius.elliptical((width + 18.0) / 2, (height + 18.0) / 2),
                ),
              ),
            ),
            // Clipped front camera or illustration
            ClipOval(
              child: SizedBox(
                width: width,
                height: height,
                child: ColoredBox(
                  color: colors.brandShotBackdrop,
                  child:
                      previewChild ??
                      SvgPicture.asset(
                        'assets/art/camera_face.svg',
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
            // Face guidance overlay (eye-level alignment notches)
            if (showGuidanceGuides)
              IgnorePointer(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    painter: _FaceGuidancePainter(
                      color: colors.brandOnSurface.withValues(
                        alpha: isRecording ? 0.22 : 0.40,
                      ),
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
                  ringColor: colors.brandOnSurface.withValues(alpha: 0.45),
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

class _FaceGuidancePainter extends CustomPainter {
  const _FaceGuidancePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2;
    final ry = size.height / 2;

    // Eye level is approximately at 42% of the vertical frame
    final eyeY = size.height * 0.42;
    final dyNorm = (eyeY - cy) / ry;
    final dySq = dyNorm * dyNorm;

    if (dySq < 1.0) {
      final dxAtY = rx * math.sqrt(1.0 - dySq);
      const tickLength = 10.0;

      // Left eye-level tick
      final leftX = cx - dxAtY;
      canvas.drawLine(
        Offset(leftX, eyeY),
        Offset(leftX + tickLength, eyeY),
        paint,
      );

      // Right eye-level tick
      final rightX = cx + dxAtY;
      canvas.drawLine(
        Offset(rightX - tickLength, eyeY),
        Offset(rightX, eyeY),
        paint,
      );
    }

    // Top head guideline notch
    const notchLen = 8.0;
    canvas.drawLine(Offset(cx, 10.0), Offset(cx, 10.0 + notchLen), paint);

    // Bottom chin guideline notch
    canvas.drawLine(
      Offset(cx, size.height - 10.0 - notchLen),
      Offset(cx, size.height - 10.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FaceGuidancePainter oldDelegate) =>
      oldDelegate.color != color;
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
        ..strokeWidth = stroke + 0.5
        ..strokeCap = StrokeCap.round
        ..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(_OvalRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.stroke != stroke;
}
