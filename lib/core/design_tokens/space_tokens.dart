import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'primitives.dart';

/// Semantic spacing tokens for insets and gaps.
@immutable
class AppSpace extends ThemeExtension<AppSpace> {
  const AppSpace({
    required this.insetScreen,
    required this.insetBrandScreen,
    required this.insetCard,
    required this.insetCardComfortable,
    required this.insetCardCompact,
    required this.insetDialog,
    required this.insetControlSm,
    required this.insetControlMd,
    required this.insetControlLg,
    required this.insetControlXl,
    required this.insetInput,
    required this.insetTag,
    required this.insetTagSm,
    required this.stackText,
    required this.stackTight,
    required this.stackItem,
    required this.stackFormField,
    required this.stackSection,
    required this.stackHero,
    required this.stackPageBottom,
    required this.inlineMicro,
    required this.inlineIconLabel,
    required this.inlineButtonGroup,
    required this.inlineItem,
    required this.gutterGrid,
  });

  // ─── Inset Tokens (return EdgeInsets) ────────────────────────────────
  final EdgeInsets insetScreen;
  final EdgeInsets insetBrandScreen;
  final EdgeInsets insetCard;
  final EdgeInsets insetCardComfortable;
  final EdgeInsets insetCardCompact;
  final EdgeInsets insetDialog;
  final EdgeInsets insetControlSm;
  final EdgeInsets insetControlMd;
  final EdgeInsets insetControlLg;
  final EdgeInsets insetControlXl;
  final EdgeInsets insetInput;
  final EdgeInsets insetTag;
  final EdgeInsets insetTagSm;

  // ─── Stack Gap Tokens (vertical, return double) ──────────────────────
  final double stackText;
  final double stackTight;
  final double stackItem;
  final double stackFormField;
  final double stackSection;
  final double stackHero;
  final double stackPageBottom;

  // ─── Inline Gap Tokens (horizontal, return double) ───────────────────
  final double inlineMicro;
  final double inlineIconLabel;
  final double inlineButtonGroup;
  final double inlineItem;

  // ─── Gutter Tokens (return double) ───────────────────────────────────
  final double gutterGrid;

  static const comfortable = AppSpace(
    insetScreen: EdgeInsets.symmetric(horizontal: Prim.s16, vertical: Prim.s24),
    insetBrandScreen: EdgeInsets.symmetric(
      horizontal: Prim.s32,
      vertical: Prim.s24,
    ),
    insetCard: EdgeInsets.all(Prim.s16),
    insetCardComfortable: EdgeInsets.all(Prim.s20),
    insetCardCompact: EdgeInsets.all(Prim.s12),
    insetDialog: EdgeInsets.all(Prim.s24),
    insetControlSm: EdgeInsets.symmetric(
      horizontal: Prim.s12,
      vertical: Prim.s8,
    ),
    insetControlMd: EdgeInsets.symmetric(
      horizontal: Prim.s16,
      vertical: Prim.s12,
    ),
    insetControlLg: EdgeInsets.symmetric(
      horizontal: Prim.s24,
      vertical: Prim.s16,
    ),
    insetControlXl: EdgeInsets.symmetric(
      horizontal: Prim.s24,
      vertical: Prim.s18,
    ),
    insetInput: EdgeInsets.symmetric(horizontal: Prim.s16, vertical: Prim.s14),
    insetTag: EdgeInsets.symmetric(horizontal: Prim.s8, vertical: Prim.s4),
    insetTagSm: EdgeInsets.symmetric(horizontal: Prim.s6, vertical: Prim.s2),
    stackText: Prim.s4,
    stackTight: Prim.s6,
    stackItem: Prim.s8,
    stackFormField: Prim.s16,
    stackSection: Prim.s24,
    stackHero: Prim.s32,
    stackPageBottom: Prim.s48,
    inlineMicro: Prim.s4,
    inlineIconLabel: Prim.s8,
    inlineButtonGroup: Prim.s12,
    inlineItem: Prim.s16,
    gutterGrid: Prim.s16,
  );

  static const compact = AppSpace(
    insetScreen: EdgeInsets.symmetric(horizontal: Prim.s12, vertical: Prim.s16),
    insetBrandScreen: EdgeInsets.symmetric(
      horizontal: Prim.s24,
      vertical: Prim.s16,
    ),
    insetCard: EdgeInsets.all(Prim.s12),
    insetCardComfortable: EdgeInsets.all(Prim.s16),
    insetCardCompact: EdgeInsets.all(Prim.s8),
    insetDialog: EdgeInsets.all(Prim.s16),
    insetControlSm: EdgeInsets.symmetric(
      horizontal: Prim.s8,
      vertical: Prim.s6,
    ),
    insetControlMd: EdgeInsets.symmetric(
      horizontal: Prim.s12,
      vertical: Prim.s10,
    ),
    insetControlLg: EdgeInsets.symmetric(
      horizontal: Prim.s16,
      vertical: Prim.s12,
    ),
    insetControlXl: EdgeInsets.symmetric(
      horizontal: Prim.s16,
      vertical: Prim.s14,
    ),
    insetInput: EdgeInsets.symmetric(horizontal: Prim.s12, vertical: Prim.s10),
    insetTag: EdgeInsets.symmetric(horizontal: Prim.s6, vertical: Prim.s2),
    insetTagSm: EdgeInsets.symmetric(horizontal: Prim.s4, vertical: Prim.s2),
    stackText: Prim.s2,
    stackTight: Prim.s4,
    stackItem: Prim.s6,
    stackFormField: Prim.s12,
    stackSection: Prim.s16,
    stackHero: Prim.s24,
    stackPageBottom: Prim.s32,
    inlineMicro: Prim.s2,
    inlineIconLabel: Prim.s6,
    inlineButtonGroup: Prim.s8,
    inlineItem: Prim.s12,
    gutterGrid: Prim.s12,
  );

  @override
  AppSpace copyWith({
    EdgeInsets? insetScreen,
    EdgeInsets? insetBrandScreen,
    EdgeInsets? insetCard,
    EdgeInsets? insetCardComfortable,
    EdgeInsets? insetCardCompact,
    EdgeInsets? insetDialog,
    EdgeInsets? insetControlSm,
    EdgeInsets? insetControlMd,
    EdgeInsets? insetControlLg,
    EdgeInsets? insetControlXl,
    EdgeInsets? insetInput,
    EdgeInsets? insetTag,
    EdgeInsets? insetTagSm,
    double? stackText,
    double? stackTight,
    double? stackItem,
    double? stackFormField,
    double? stackSection,
    double? stackHero,
    double? stackPageBottom,
    double? inlineMicro,
    double? inlineIconLabel,
    double? inlineButtonGroup,
    double? inlineItem,
    double? gutterGrid,
  }) {
    return AppSpace(
      insetScreen: insetScreen ?? this.insetScreen,
      insetBrandScreen: insetBrandScreen ?? this.insetBrandScreen,
      insetCard: insetCard ?? this.insetCard,
      insetCardComfortable: insetCardComfortable ?? this.insetCardComfortable,
      insetCardCompact: insetCardCompact ?? this.insetCardCompact,
      insetDialog: insetDialog ?? this.insetDialog,
      insetControlSm: insetControlSm ?? this.insetControlSm,
      insetControlMd: insetControlMd ?? this.insetControlMd,
      insetControlLg: insetControlLg ?? this.insetControlLg,
      insetControlXl: insetControlXl ?? this.insetControlXl,
      insetInput: insetInput ?? this.insetInput,
      insetTag: insetTag ?? this.insetTag,
      insetTagSm: insetTagSm ?? this.insetTagSm,
      stackText: stackText ?? this.stackText,
      stackTight: stackTight ?? this.stackTight,
      stackItem: stackItem ?? this.stackItem,
      stackFormField: stackFormField ?? this.stackFormField,
      stackSection: stackSection ?? this.stackSection,
      stackHero: stackHero ?? this.stackHero,
      stackPageBottom: stackPageBottom ?? this.stackPageBottom,
      inlineMicro: inlineMicro ?? this.inlineMicro,
      inlineIconLabel: inlineIconLabel ?? this.inlineIconLabel,
      inlineButtonGroup: inlineButtonGroup ?? this.inlineButtonGroup,
      inlineItem: inlineItem ?? this.inlineItem,
      gutterGrid: gutterGrid ?? this.gutterGrid,
    );
  }

  @override
  AppSpace lerp(ThemeExtension<AppSpace>? other, double t) {
    if (other is! AppSpace) return this;
    return AppSpace(
      insetScreen: EdgeInsets.lerp(insetScreen, other.insetScreen, t)!,
      insetBrandScreen: EdgeInsets.lerp(
        insetBrandScreen,
        other.insetBrandScreen,
        t,
      )!,
      insetCard: EdgeInsets.lerp(insetCard, other.insetCard, t)!,
      insetCardComfortable: EdgeInsets.lerp(
        insetCardComfortable,
        other.insetCardComfortable,
        t,
      )!,
      insetCardCompact: EdgeInsets.lerp(
        insetCardCompact,
        other.insetCardCompact,
        t,
      )!,
      insetDialog: EdgeInsets.lerp(insetDialog, other.insetDialog, t)!,
      insetControlSm: EdgeInsets.lerp(insetControlSm, other.insetControlSm, t)!,
      insetControlMd: EdgeInsets.lerp(insetControlMd, other.insetControlMd, t)!,
      insetControlLg: EdgeInsets.lerp(insetControlLg, other.insetControlLg, t)!,
      insetControlXl: EdgeInsets.lerp(insetControlXl, other.insetControlXl, t)!,
      insetInput: EdgeInsets.lerp(insetInput, other.insetInput, t)!,
      insetTag: EdgeInsets.lerp(insetTag, other.insetTag, t)!,
      insetTagSm: EdgeInsets.lerp(insetTagSm, other.insetTagSm, t)!,
      stackText: lerpDouble(stackText, other.stackText, t)!,
      stackTight: lerpDouble(stackTight, other.stackTight, t)!,
      stackItem: lerpDouble(stackItem, other.stackItem, t)!,
      stackFormField: lerpDouble(stackFormField, other.stackFormField, t)!,
      stackSection: lerpDouble(stackSection, other.stackSection, t)!,
      stackHero: lerpDouble(stackHero, other.stackHero, t)!,
      stackPageBottom: lerpDouble(stackPageBottom, other.stackPageBottom, t)!,
      inlineMicro: lerpDouble(inlineMicro, other.inlineMicro, t)!,
      inlineIconLabel: lerpDouble(inlineIconLabel, other.inlineIconLabel, t)!,
      inlineButtonGroup: lerpDouble(
        inlineButtonGroup,
        other.inlineButtonGroup,
        t,
      )!,
      inlineItem: lerpDouble(inlineItem, other.inlineItem, t)!,
      gutterGrid: lerpDouble(gutterGrid, other.gutterGrid, t)!,
    );
  }
}
