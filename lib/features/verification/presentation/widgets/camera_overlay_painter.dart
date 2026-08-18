import 'package:flutter/material.dart';

class CameraOverlayPainter extends CustomPainter {
  final Rect cutout;
  final double radius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  CameraOverlayPainter({
    required this.cutout,
    this.radius = 16.0,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Darkened background with a transparent hole
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(radius)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()..color = overlayColor;
    canvas.drawPath(overlayPath, paint);

    // 2. White border around the cutout
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(cutout, Radius.circular(radius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return oldDelegate.cutout != cutout ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
