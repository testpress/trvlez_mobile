import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'primitives.dart';

/// Semantic shape tokens for corner radii, border widths, strokes, and dividers.
@immutable
class AppShape extends ThemeExtension<AppShape> {
  const AppShape({
    required this.radiusMicro,
    required this.radiusSubtle,
    required this.radiusControlSm,
    required this.radiusControl,
    required this.radiusSurface,
    required this.radiusCard,
    required this.radiusOverlay,
    required this.radiusHeader,
    required this.radiusPill,
    required this.borderHairline,
    required this.borderDefault,
    required this.borderMedium,
    required this.borderFocus,
    required this.strokeProgress,
    required this.dividerDefault,
  });

  // ─── Corner Radii (return BorderRadius) ──────────────────────────────
  final BorderRadius radiusMicro;
  final BorderRadius radiusSubtle;
  final BorderRadius radiusControlSm;
  final BorderRadius radiusControl;
  final BorderRadius radiusSurface;
  final BorderRadius radiusCard;
  final BorderRadius radiusOverlay;
  final BorderRadius radiusHeader;
  final BorderRadius radiusPill;

  // ─── Border & Stroke Widths (return double) ──────────────────────────
  final double borderHairline;
  final double borderDefault;
  final double borderMedium;
  final double borderFocus;
  final double strokeProgress;
  final double dividerDefault;

  static const standard = AppShape(
    radiusMicro: BorderRadius.all(Radius.circular(Prim.r2)),
    radiusSubtle: BorderRadius.all(Radius.circular(Prim.r4)),
    radiusControlSm: BorderRadius.all(Radius.circular(Prim.r8)),
    radiusControl: BorderRadius.all(Radius.circular(Prim.r12)),
    radiusSurface: BorderRadius.all(Radius.circular(Prim.r16)),
    radiusCard: BorderRadius.all(Radius.circular(Prim.r28)),
    radiusOverlay: BorderRadius.all(Radius.circular(Prim.r20)),
    radiusHeader: BorderRadius.all(Radius.circular(Prim.r28)),
    radiusPill: BorderRadius.all(Radius.circular(Prim.rFull)),
    borderHairline: Prim.bHairline,
    borderDefault: Prim.bDefault,
    borderMedium: Prim.bMedium,
    borderFocus: Prim.bFocus,
    strokeProgress: Prim.bProgress,
    dividerDefault: Prim.bDefault,
  );

  /// Nested radius rule: inner radius = outer radius minus padding, floored at 0.
  BorderRadius inner(BorderRadius outer, EdgeInsets padding) {
    return BorderRadius.only(
      topLeft: Radius.circular(math.max(0.0, outer.topLeft.x - padding.left)),
      topRight: Radius.circular(
        math.max(0.0, outer.topRight.x - padding.right),
      ),
      bottomLeft: Radius.circular(
        math.max(0.0, outer.bottomLeft.x - padding.left),
      ),
      bottomRight: Radius.circular(
        math.max(0.0, outer.bottomRight.x - padding.right),
      ),
    );
  }

  @override
  AppShape copyWith({
    BorderRadius? radiusMicro,
    BorderRadius? radiusSubtle,
    BorderRadius? radiusControlSm,
    BorderRadius? radiusControl,
    BorderRadius? radiusSurface,
    BorderRadius? radiusCard,
    BorderRadius? radiusOverlay,
    BorderRadius? radiusHeader,
    BorderRadius? radiusPill,
    double? borderHairline,
    double? borderDefault,
    double? borderMedium,
    double? borderFocus,
    double? strokeProgress,
    double? dividerDefault,
  }) {
    return AppShape(
      radiusMicro: radiusMicro ?? this.radiusMicro,
      radiusSubtle: radiusSubtle ?? this.radiusSubtle,
      radiusControlSm: radiusControlSm ?? this.radiusControlSm,
      radiusControl: radiusControl ?? this.radiusControl,
      radiusSurface: radiusSurface ?? this.radiusSurface,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusOverlay: radiusOverlay ?? this.radiusOverlay,
      radiusHeader: radiusHeader ?? this.radiusHeader,
      radiusPill: radiusPill ?? this.radiusPill,
      borderHairline: borderHairline ?? this.borderHairline,
      borderDefault: borderDefault ?? this.borderDefault,
      borderMedium: borderMedium ?? this.borderMedium,
      borderFocus: borderFocus ?? this.borderFocus,
      strokeProgress: strokeProgress ?? this.strokeProgress,
      dividerDefault: dividerDefault ?? this.dividerDefault,
    );
  }

  @override
  AppShape lerp(ThemeExtension<AppShape>? other, double t) {
    if (other is! AppShape) return this;
    return AppShape(
      radiusMicro: BorderRadius.lerp(radiusMicro, other.radiusMicro, t)!,
      radiusSubtle: BorderRadius.lerp(radiusSubtle, other.radiusSubtle, t)!,
      radiusControlSm: BorderRadius.lerp(
        radiusControlSm,
        other.radiusControlSm,
        t,
      )!,
      radiusControl: BorderRadius.lerp(radiusControl, other.radiusControl, t)!,
      radiusSurface: BorderRadius.lerp(radiusSurface, other.radiusSurface, t)!,
      radiusCard: BorderRadius.lerp(radiusCard, other.radiusCard, t)!,
      radiusOverlay: BorderRadius.lerp(radiusOverlay, other.radiusOverlay, t)!,
      radiusHeader: BorderRadius.lerp(radiusHeader, other.radiusHeader, t)!,
      radiusPill: BorderRadius.lerp(radiusPill, other.radiusPill, t)!,
      borderHairline: lerpDouble(borderHairline, other.borderHairline, t)!,
      borderDefault: lerpDouble(borderDefault, other.borderDefault, t)!,
      borderMedium: lerpDouble(borderMedium, other.borderMedium, t)!,
      borderFocus: lerpDouble(borderFocus, other.borderFocus, t)!,
      strokeProgress: lerpDouble(strokeProgress, other.strokeProgress, t)!,
      dividerDefault: lerpDouble(dividerDefault, other.dividerDefault, t)!,
    );
  }
}
