import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// 3D tipping and twisting hourglass for the final verification check screen.
class VerifyHourglass extends StatefulWidget {
  const VerifyHourglass({super.key, this.size = 64.0, this.glyphSize = 30.0});
  final double size;
  final double glyphSize;

  @override
  State<VerifyHourglass> createState() => _VerifyHourglassState();
}

class _VerifyHourglassState extends State<VerifyHourglass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  bool get _reducedMotion => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  @override
  void initState() {
    super.initState();
    if (!_reducedMotion) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const double _turnStart = 0.55;
  static const double _turnEnd = 0.72;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.verificationCardIconFill,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final targetChild = child ?? const SizedBox.shrink();
            if (_reducedMotion) return targetChild;

            final t = _controller.value;
            if (t < _turnStart || t > _turnEnd) return targetChild;

            final p = (t - _turnStart) / (_turnEnd - _turnStart);
            final eased = Curves.easeInOut.transform(p);

            return Transform.rotate(
              angle: math.pi * eased,
              child: Transform.scale(
                scaleX: math.cos(math.pi * eased).abs().clamp(0.12, 1.0),
                scaleY: 1.0,
                child: targetChild,
              ),
            );
          },
          child: Icon(
            AppIcons.hourglass,
            size: widget.glyphSize,
            color: colors.brandOnSurface,
          ),
        ),
      ),
    );
  }
}
