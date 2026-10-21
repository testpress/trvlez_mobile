import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/verification/presentation/state/processing_stage.dart';

/// Animated visual representing a document or video frame being processed.
///
/// Shows a passport or video frame icon with stage-appropriate subtle animation:
/// - **Uploading**: gentle upward pulse on an arrow indicator
/// - **Checking**: horizontal scan-line moves across the document
/// - **Quality passed**: static document with a brief green checkmark
/// - **Reading**: scan-line focused on the lower (MRZ) area
/// - **Completed**: static document with a success checkmark overlay
/// - **Failed**: static document with a warning indicator
///
/// Built entirely with Flutter canvas — no images or external assets.
/// Respects reduced-motion accessibility settings.
class DocumentProcessingVisual extends StatefulWidget {
  final ProcessingStageType stageType;
  final ProcessingType processingType;

  const DocumentProcessingVisual({
    super.key,
    required this.stageType,
    required this.processingType,
  });

  @override
  State<DocumentProcessingVisual> createState() =>
      _DocumentProcessingVisualState();
}

class _DocumentProcessingVisualState extends State<DocumentProcessingVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _animatingStages = {
    ProcessingStageType.preparing,
    ProcessingStageType.uploading,
    ProcessingStageType.checking,
    ProcessingStageType.reading,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(DocumentProcessingVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stageType != widget.stageType) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (_animatingStages.contains(widget.stageType)) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final sizes = context.sizes;
    final shape = context.shape;
    final successColor = context.colors.feedbackSuccess;

    return SizedBox(
      width: sizes.thumbPhotoMd,
      height: sizes.thumbPhotoMd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DocumentPainter(
              stageType: widget.stageType,
              processingType: widget.processingType,
              animationValue: reduceMotion ? 0.0 : _controller.value,
              primaryColor: colorScheme.primary,
              surfaceColor: colorScheme.surface,
              outlineColor: colorScheme.outline,
              successColor: successColor,
              errorColor: colorScheme.error,
              mutedColor: colorScheme.onSurface.withValues(alpha: 0.15),
              shape: shape,
            ),
          );
        },
      ),
    );
  }
}

class _DocumentPainter extends CustomPainter {
  final ProcessingStageType stageType;
  final ProcessingType processingType;
  final double animationValue;
  final Color primaryColor;
  final Color surfaceColor;
  final Color outlineColor;
  final Color successColor;
  final Color errorColor;
  final Color mutedColor;
  final AppShape shape;

  const _DocumentPainter({
    required this.stageType,
    required this.processingType,
    required this.animationValue,
    required this.primaryColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.successColor,
    required this.errorColor,
    required this.mutedColor,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (processingType == ProcessingType.passport) {
      _paintPassport(canvas, size);
    } else {
      _paintVideoFrame(canvas, size);
    }
  }

  void _paintPassport(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Document dimensions (passport-like rectangle)
    const docWidth = 72.0;
    const docHeight = 50.0;
    final docRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: docWidth,
      height: docHeight,
    );

    _paintBackgroundCircle(canvas, centerX, centerY, size);
    _paintDocumentBody(canvas, docRect);
    _paintMrzLines(canvas, docRect);
    _paintPhotoPlaceholder(canvas, docRect);
    _paintTextLines(canvas, docRect);
    _paintStageOverlay(canvas, size, docRect, centerX, centerY);
  }

  void _paintVideoFrame(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Video frame dimensions (16:9-ish)
    const frameWidth = 68.0;
    const frameHeight = 48.0;
    final frameRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: frameWidth,
      height: frameHeight,
    );

    _paintBackgroundCircle(canvas, centerX, centerY, size);

    // Frame body
    final framePaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    final frameBorderPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final frameRRect = RRect.fromRectAndRadius(
      frameRect,
      Radius.circular(
        shape.radiusSubtle.topLeft.x + shape.radiusMicro.topLeft.x,
      ),
    );
    canvas.drawRRect(frameRRect, framePaint);
    canvas.drawRRect(frameRRect, frameBorderPaint);

    // Play triangle in center
    final playPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final playPath = Path()
      ..moveTo(centerX - 6, centerY - 10)
      ..lineTo(centerX - 6, centerY + 10)
      ..lineTo(centerX + 10, centerY)
      ..close();
    canvas.drawPath(playPath, playPaint);

    _paintStageOverlay(canvas, size, frameRect, centerX, centerY);
  }

  // ── Shared painting helpers ──────────────────────────────────────────

  void _paintBackgroundCircle(
    Canvas canvas,
    double centerX,
    double centerY,
    Size size,
  ) {
    final bgPaint = Paint()..color = mutedColor;
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.42, bgPaint);
  }

  void _paintDocumentBody(Canvas canvas, Rect docRect) {
    final docPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    final docBorderPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final docRRect = RRect.fromRectAndRadius(
      docRect,
      shape.radiusSubtle.topLeft,
    );
    canvas.drawRRect(docRRect, docPaint);
    canvas.drawRRect(docRRect, docBorderPaint);
  }

  void _paintMrzLines(Canvas canvas, Rect docRect) {
    final mrzPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.2)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final mrzLeft = docRect.left + 8;
    final mrzRight = docRect.right - 8;

    canvas.drawLine(
      Offset(mrzLeft, docRect.bottom - 14),
      Offset(mrzRight, docRect.bottom - 14),
      mrzPaint,
    );
    canvas.drawLine(
      Offset(mrzLeft, docRect.bottom - 8),
      Offset(mrzRight, docRect.bottom - 8),
      mrzPaint,
    );
  }

  void _paintPhotoPlaceholder(Canvas canvas, Rect docRect) {
    final photoRect = Rect.fromLTWH(docRect.left + 8, docRect.top + 8, 16, 20);
    final photoPaint = Paint()..color = outlineColor.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(photoRect, shape.radiusMicro.topLeft),
      photoPaint,
    );
  }

  void _paintTextLines(Canvas canvas, Rect docRect) {
    final linePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final photoRight = docRect.left + 8 + 16; // photoRect.right

    for (int i = 0; i < 3; i++) {
      final lineY = docRect.top + 12 + (i * 8.0);
      final lineRight = docRect.right - 8 - (i == 2 ? 12 : 0);
      canvas.drawLine(
        Offset(photoRight + 6, lineY),
        Offset(lineRight, lineY),
        linePaint,
      );
    }
  }

  void _paintStageOverlay(
    Canvas canvas,
    Size size,
    Rect contentRect,
    double centerX,
    double centerY,
  ) {
    switch (stageType) {
      case ProcessingStageType.preparing:
      case ProcessingStageType.uploading:
        _paintUploadIndicator(canvas, centerX, contentRect);
      case ProcessingStageType.checking:
        _paintScanLine(canvas, contentRect, fullHeight: true);
      case ProcessingStageType.qualityPassed:
        _paintCheckmark(canvas, centerX, centerY);
      case ProcessingStageType.reading:
        _paintScanLine(canvas, contentRect, fullHeight: false);
      case ProcessingStageType.completed:
        _paintCheckmark(canvas, centerX, centerY);
      case ProcessingStageType.failed:
        _paintWarning(canvas, centerX, centerY);
    }
  }

  void _paintUploadIndicator(Canvas canvas, double centerX, Rect docRect) {
    final arrowY = docRect.bottom + 12 - (animationValue * 6);
    final arrowOpacity = (1.0 - (animationValue - 0.5).abs() * 2).clamp(
      0.3,
      1.0,
    );

    final arrowPaint = Paint()
      ..color = primaryColor.withValues(alpha: arrowOpacity * 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, arrowY + 8),
      Offset(centerX, arrowY),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(centerX - 4, arrowY + 4),
      Offset(centerX, arrowY),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(centerX + 4, arrowY + 4),
      Offset(centerX, arrowY),
      arrowPaint,
    );
  }

  void _paintScanLine(Canvas canvas, Rect docRect, {required bool fullHeight}) {
    final scanTop = fullHeight ? docRect.top + 4 : docRect.bottom - 18;
    final scanBottom = fullHeight ? docRect.bottom - 4 : docRect.bottom - 4;
    final scanRange = scanBottom - scanTop;
    final scanY = scanTop + (animationValue * scanRange);

    final scanPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(docRect.left + 4, scanY),
      Offset(docRect.right - 4, scanY),
      scanPaint,
    );

    // Subtle glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(
      Offset(docRect.left + 4, scanY),
      Offset(docRect.right - 4, scanY),
      glowPaint,
    );
  }

  void _paintCheckmark(Canvas canvas, double centerX, double centerY) {
    final badgeCenter = Offset(centerX + 24, centerY + 20);
    const badgeRadius = 12.0;

    canvas.drawCircle(badgeCenter, badgeRadius, Paint()..color = successColor);

    final checkPaint = Paint()
      ..color = surfaceColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final checkPath = Path()
      ..moveTo(badgeCenter.dx - 5, badgeCenter.dy)
      ..lineTo(badgeCenter.dx - 1, badgeCenter.dy + 4)
      ..lineTo(badgeCenter.dx + 5, badgeCenter.dy - 3);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _paintWarning(Canvas canvas, double centerX, double centerY) {
    final badgeCenter = Offset(centerX + 24, centerY + 20);
    const badgeRadius = 12.0;

    canvas.drawCircle(badgeCenter, badgeRadius, Paint()..color = errorColor);

    final excPaint = Paint()
      ..color = surfaceColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(badgeCenter.dx, badgeCenter.dy - 5),
      Offset(badgeCenter.dx, badgeCenter.dy + 1),
      excPaint,
    );
    canvas.drawCircle(
      Offset(badgeCenter.dx, badgeCenter.dy + 5),
      1.2,
      Paint()..color = surfaceColor,
    );
  }

  @override
  bool shouldRepaint(_DocumentPainter oldDelegate) {
    return oldDelegate.stageType != stageType ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.processingType != processingType;
  }
}
