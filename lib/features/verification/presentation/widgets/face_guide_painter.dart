import 'dart:math' as math;

import 'package:flutter/material.dart';

class FaceGuidePainter extends CustomPainter {
  final double progress;

  FaceGuidePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw semi-transparent background
    final paint = Paint()..color = Colors.black54;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Define the oval face guide area
    final ovalWidth = size.width * 0.92;
    final ovalHeight = ovalWidth * 1.35;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2.05),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Create the cutout
    final ovalPath = Path()..addOval(ovalRect);
    final combinedPath = Path.combine(PathOperation.difference, path, ovalPath);

    canvas.drawPath(combinedPath, paint);

    // Draw the base oval border
    final borderPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(ovalRect, borderPaint);

    // Draw the progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      // Sweep angle is progress * 2 * pi
      canvas.drawArc(
        ovalRect,
        -math.pi / 2, // Start at top
        progress * 2 * math.pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceGuidePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
