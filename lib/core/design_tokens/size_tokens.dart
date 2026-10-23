import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'primitives.dart';

/// Semantic sizing tokens for controls, icons, avatars, and layout elements.
@immutable
class AppSize extends ThemeExtension<AppSize> {
  const AppSize({
    required this.iconXs,
    required this.iconSm,
    required this.iconMd,
    required this.iconDefault,
    required this.iconLg,
    required this.iconXl,
    required this.iconFeature,
    required this.iconHero,
    required this.controlSm,
    required this.controlMd,
    required this.controlLg,
    required this.controlXl,
    required this.controlHero,
    required this.containerPhone,
    required this.touchTargetMin,
    required this.avatarSm,
    required this.avatarMd,
    required this.avatarLg,
    required this.avatarXl,
    required this.indicatorDot,
    required this.indicatorProgressHeight,
    required this.pulseIndicator,
    required this.appBarHeight,
    required this.thumbPhotoSm,
    required this.thumbPhotoMd,
    required this.thumbPhotoLg,
    required this.cardWidthCarousel,
  });

  // ─── Icon Sizing Tokens (return double) ──────────────────────────────
  final double iconXs;
  final double iconSm;
  final double iconMd;
  final double iconDefault;
  final double iconLg;
  final double iconXl;
  final double iconFeature;
  final double iconHero;

  // ─── Control Sizing Tokens (return double) ───────────────────────────
  final double controlSm;
  final double controlMd;
  final double controlLg;
  final double controlXl;
  final double controlHero;
  final double containerPhone;
  final double touchTargetMin;

  // ─── Avatar Sizing Tokens (return double) ────────────────────────────
  final double avatarSm;
  final double avatarMd;
  final double avatarLg;
  final double avatarXl;

  // ─── Indicator & Component Sizing Tokens (return double) ─────────────
  final double indicatorDot;
  final double indicatorProgressHeight;
  final double pulseIndicator;
  final double appBarHeight;
  final double thumbPhotoSm;
  final double thumbPhotoMd;
  final double thumbPhotoLg;
  final double cardWidthCarousel;

  static const regular = AppSize(
    iconXs: Prim.s14,
    iconSm: Prim.s18,
    iconMd: Prim.s20,
    iconDefault: Prim.s24,
    iconLg: Prim.s28,
    iconXl: Prim.s32,
    iconFeature: Prim.s40,
    iconHero: Prim.s48,
    controlSm: Prim.s36,
    controlMd: Prim.s44,
    controlLg: Prim.s48,
    controlXl: Prim.s56,
    controlHero: Prim.s64,
    containerPhone: Prim.s440,
    touchTargetMin: Prim.s48,
    avatarSm: Prim.s28,
    avatarMd: Prim.s36,
    avatarLg: Prim.s48,
    avatarXl: Prim.s80,
    indicatorDot: Prim.s8,
    indicatorProgressHeight: Prim.s4,
    pulseIndicator: Prim.s64,
    appBarHeight: Prim.s56,
    thumbPhotoSm: Prim.s80,
    thumbPhotoMd: Prim.s120,
    thumbPhotoLg: Prim.s160,
    cardWidthCarousel: Prim.s220,
  );

  @override
  AppSize copyWith({
    double? iconXs,
    double? iconSm,
    double? iconMd,
    double? iconDefault,
    double? iconLg,
    double? iconXl,
    double? iconFeature,
    double? iconHero,
    double? controlSm,
    double? controlMd,
    double? controlLg,
    double? controlXl,
    double? controlHero,
    double? containerPhone,
    double? touchTargetMin,
    double? avatarSm,
    double? avatarMd,
    double? avatarLg,
    double? avatarXl,
    double? indicatorDot,
    double? indicatorProgressHeight,
    double? pulseIndicator,
    double? appBarHeight,
    double? thumbPhotoSm,
    double? thumbPhotoMd,
    double? thumbPhotoLg,
    double? cardWidthCarousel,
  }) {
    return AppSize(
      iconXs: iconXs ?? this.iconXs,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconDefault: iconDefault ?? this.iconDefault,
      iconLg: iconLg ?? this.iconLg,
      iconXl: iconXl ?? this.iconXl,
      iconFeature: iconFeature ?? this.iconFeature,
      iconHero: iconHero ?? this.iconHero,
      controlSm: controlSm ?? this.controlSm,
      controlMd: controlMd ?? this.controlMd,
      controlLg: controlLg ?? this.controlLg,
      controlXl: controlXl ?? this.controlXl,
      controlHero: controlHero ?? this.controlHero,
      containerPhone: containerPhone ?? this.containerPhone,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
      avatarSm: avatarSm ?? this.avatarSm,
      avatarMd: avatarMd ?? this.avatarMd,
      avatarLg: avatarLg ?? this.avatarLg,
      avatarXl: avatarXl ?? this.avatarXl,
      indicatorDot: indicatorDot ?? this.indicatorDot,
      indicatorProgressHeight:
          indicatorProgressHeight ?? this.indicatorProgressHeight,
      pulseIndicator: pulseIndicator ?? this.pulseIndicator,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      thumbPhotoSm: thumbPhotoSm ?? this.thumbPhotoSm,
      thumbPhotoMd: thumbPhotoMd ?? this.thumbPhotoMd,
      thumbPhotoLg: thumbPhotoLg ?? this.thumbPhotoLg,
      cardWidthCarousel: cardWidthCarousel ?? this.cardWidthCarousel,
    );
  }

  @override
  AppSize lerp(ThemeExtension<AppSize>? other, double t) {
    if (other is! AppSize) return this;
    return AppSize(
      iconXs: lerpDouble(iconXs, other.iconXs, t)!,
      iconSm: lerpDouble(iconSm, other.iconSm, t)!,
      iconMd: lerpDouble(iconMd, other.iconMd, t)!,
      iconDefault: lerpDouble(iconDefault, other.iconDefault, t)!,
      iconLg: lerpDouble(iconLg, other.iconLg, t)!,
      iconXl: lerpDouble(iconXl, other.iconXl, t)!,
      iconFeature: lerpDouble(iconFeature, other.iconFeature, t)!,
      iconHero: lerpDouble(iconHero, other.iconHero, t)!,
      controlSm: lerpDouble(controlSm, other.controlSm, t)!,
      controlMd: lerpDouble(controlMd, other.controlMd, t)!,
      controlLg: lerpDouble(controlLg, other.controlLg, t)!,
      controlXl: lerpDouble(controlXl, other.controlXl, t)!,
      controlHero: lerpDouble(controlHero, other.controlHero, t)!,
      containerPhone: lerpDouble(containerPhone, other.containerPhone, t)!,
      touchTargetMin: lerpDouble(touchTargetMin, other.touchTargetMin, t)!,
      avatarSm: lerpDouble(avatarSm, other.avatarSm, t)!,
      avatarMd: lerpDouble(avatarMd, other.avatarMd, t)!,
      avatarLg: lerpDouble(avatarLg, other.avatarLg, t)!,
      avatarXl: lerpDouble(avatarXl, other.avatarXl, t)!,
      indicatorDot: lerpDouble(indicatorDot, other.indicatorDot, t)!,
      indicatorProgressHeight: lerpDouble(
        indicatorProgressHeight,
        other.indicatorProgressHeight,
        t,
      )!,
      pulseIndicator: lerpDouble(pulseIndicator, other.pulseIndicator, t)!,
      appBarHeight: lerpDouble(appBarHeight, other.appBarHeight, t)!,
      thumbPhotoSm: lerpDouble(thumbPhotoSm, other.thumbPhotoSm, t)!,
      thumbPhotoMd: lerpDouble(thumbPhotoMd, other.thumbPhotoMd, t)!,
      thumbPhotoLg: lerpDouble(thumbPhotoLg, other.thumbPhotoLg, t)!,
      cardWidthCarousel: lerpDouble(
        cardWidthCarousel,
        other.cardWidthCarousel,
        t,
      )!,
    );
  }
}
