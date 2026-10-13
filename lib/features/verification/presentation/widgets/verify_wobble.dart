import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Single-play 800ms rotational wobble animation for verification failure illustrations.
class VerifyWobble extends StatefulWidget {
  const VerifyWobble({super.key, required this.child});
  final Widget child;

  @override
  State<VerifyWobble> createState() => _VerifyWobbleState();
}

class _VerifyWobbleState extends State<VerifyWobble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  static const _frames = <(double, double)>[
    (0.00, 0.0),
    (0.15, -4.5),
    (0.32, 3.5),
    (0.50, -2.5),
    (0.68, 1.5),
    (0.84, -0.6),
    (1.00, 0.0),
  ];

  @override
  void initState() {
    super.initState();
    if (!WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _angleAt(double t) {
    for (int i = 0; i < _frames.length - 1; i++) {
      final (at, deg) = _frames[i];
      final (nextAt, nextDeg) = _frames[i + 1];
      if (t >= at && t <= nextAt) {
        final span = nextAt - at;
        final f = span == 0 ? 0.0 : (t - at) / span;
        return deg + (nextDeg - deg) * f;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        alignment: const Alignment(0, 0.1),
        angle: _angleAt(_controller.value) * math.pi / 180,
        child: child,
      ),
      child: widget.child,
    );
  }
}
