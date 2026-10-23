import 'package:flutter/animation.dart';

/// Standard animation durations and curves.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  /// Standard duration for button state cross-fade (disabled <-> enabled), per design spec.
  static const buttonFade = Duration(milliseconds: 220);

  static const curve = Curves.easeOutCubic;
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
}
