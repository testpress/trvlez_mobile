import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

/// Framing guide overlay for passport photo page capture.
///
/// Follows ICAO Doc 9303 TD3 specification (125mm x 88mm, ~1.42:1 aspect ratio),
/// rendering four corner brackets and a dashed MRZ alignment box at the bottom.
class PassportFramingGuide extends StatelessWidget {
  const PassportFramingGuide({
    super.key,
    required this.viewportSize,
    required this.colors,
  });

  final Size viewportSize;
  final AppColors colors;

  /// Standard ICAO Doc 9303 TD3 passport aspect ratio (125mm x 88mm).
  static const double passportAspectRatio = 125.0 / 88.0; // ~1.42045

  /// Computes the passport framing rectangle centered within [viewportSize].
  static Rect calculatePassportFrame(Size viewportSize) {
    // Provide comfortable margin within the viewfinder (~18px horizontal on 320px viewport)
    double frameW = viewportSize.width - 36.0;
    double frameH = frameW / passportAspectRatio;

    if (frameH > viewportSize.height - 32.0) {
      frameH = viewportSize.height - 32.0;
      frameW = frameH * passportAspectRatio;
    }

    final double left = (viewportSize.width - frameW) / 2;
    final double top = (viewportSize.height - frameH) / 2;
    return Rect.fromLTWH(left, top, frameW, frameH);
  }

  @override
  Widget build(BuildContext context) {
    final frameRect = calculatePassportFrame(viewportSize);

    return IgnorePointer(
      child: CustomPaint(
        size: viewportSize,
        painter: _PassportFramingPainter(
          frameRect: frameRect,
          colors: colors,
        ),
      ),
    );
  }
}

class _PassportFramingPainter extends CustomPainter {
  const _PassportFramingPainter({
    required this.frameRect,
    required this.colors,
  });

  final Rect frameRect;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (frameRect.isEmpty) return;

    // 1. Subtle outline around the full passport boundary
    final rrect = RRect.fromRectAndRadius(
      frameRect,
      const Radius.circular(AppRadius.sm),
    );
    final borderPaint = Paint()
      ..color = colors.brandBorderSubtle.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Four distinct corner bracket guides
    final cornerPaint = Paint()
      ..color = colors.brandSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final double cornerLen = math.min(22.0, frameRect.width * 0.12);
    const double r = 5.0;

    // Top-Left corner
    final tlPath = Path()
      ..moveTo(frameRect.left, frameRect.top + cornerLen)
      ..lineTo(frameRect.left, frameRect.top + r)
      ..arcToPoint(
        Offset(frameRect.left + r, frameRect.top),
        radius: const Radius.circular(r),
      )
      ..lineTo(frameRect.left + cornerLen, frameRect.top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right corner
    final trPath = Path()
      ..moveTo(frameRect.right - cornerLen, frameRect.top)
      ..lineTo(frameRect.right - r, frameRect.top)
      ..arcToPoint(
        Offset(frameRect.right, frameRect.top + r),
        radius: const Radius.circular(r),
      )
      ..lineTo(frameRect.right, frameRect.top + cornerLen);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left corner
    final blPath = Path()
      ..moveTo(frameRect.left, frameRect.bottom - cornerLen)
      ..lineTo(frameRect.left, frameRect.bottom - r)
      ..arcToPoint(
        Offset(frameRect.left + r, frameRect.bottom),
        radius: const Radius.circular(r),
      )
      ..lineTo(frameRect.left + cornerLen, frameRect.bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right corner
    final brPath = Path()
      ..moveTo(frameRect.right - cornerLen, frameRect.bottom)
      ..lineTo(frameRect.right - r, frameRect.bottom)
      ..arcToPoint(
        Offset(frameRect.right, frameRect.bottom - r),
        radius: const Radius.circular(r),
      )
      ..lineTo(frameRect.right, frameRect.bottom - cornerLen);
    canvas.drawPath(brPath, cornerPaint);

    // 3. Dashed MRZ guidance box positioned across the bottom 25% of passport
    final double mrzH = (frameRect.height * 0.25).clamp(36.0, 50.0);
    final Rect mrzRect = Rect.fromLTWH(
      frameRect.left + 10.0,
      frameRect.bottom - mrzH - 6.0,
      frameRect.width - 20.0,
      mrzH,
    );
    final mrzRRect = RRect.fromRectAndRadius(
      mrzRect,
      const Radius.circular(AppRadius.xs),
    );

    _drawDashedRRect(
      canvas,
      mrzRRect,
      Paint()
        ..color = colors.brandSecondary.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
      dashLength: 4.0,
      dashGap: 4.0,
    );
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint, {
    required double dashLength,
    required double dashGap,
  }) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_PassportFramingPainter oldDelegate) =>
      oldDelegate.frameRect != frameRect || oldDelegate.colors != colors;
}
