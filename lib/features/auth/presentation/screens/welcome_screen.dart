import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';

/// The TrvlEz animated launch screen.
///
/// Features sequenced brand entrance:
/// 1. Plane and wordmark slide in from sides
/// 2. Wordmark lifts and centers
/// 3. Opening motif art fades out
/// 4. City skyline rises
/// 5. Onboarding CTAs and privacy commitment animate in
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 3000);

  // Design artboard reference specifications from the design repository
  static const double _artW = 236.0;
  static const double _artH = 472.0;
  static const double _typeReferenceWidth = 212.0;
  static const double _typeShrinkFloor = 0.88;
  static const double _maxScale = 3.0;

  late final AnimationController _controller;
  late final Animation<double> _plane;
  late final Animation<double> _trvl;
  late final Animation<double> _ez;
  late final Animation<double> _lift;
  late final Animation<double> _motifsOut;
  late final Animation<double> _artRise;
  late final Animation<double> _ctaRise;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    Animation<double> phase(int fromMs, int toMs, Curve curve) =>
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            fromMs / _totalDuration.inMilliseconds,
            toMs / _totalDuration.inMilliseconds,
            curve: curve,
          ),
        );

    _plane = phase(0, 1050, const Cubic(0.22, 0.7, 0.3, 1.0));
    _trvl = phase(950, 1450, Curves.easeOut);
    _ez = phase(1050, 1550, Curves.easeOut);
    _lift = phase(1550, 2350, const Cubic(0.4, 0.0, 0.2, 1.0));
    _motifsOut = phase(1550, 2100, Curves.ease);
    _artRise = phase(1900, 2600, Curves.easeOut);
    _ctaRise = phase(2050, 2750, Curves.easeOut);

    _startAnimation();
  }

  void _startAnimation() {
    final reduceMotion = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (reduceMotion) {
      _controller.value = 1.0;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.brandSurface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Compute device-to-artboard scale matching the design repository
          final layout = math.min(
            math.min(screenWidth / _artW, screenHeight / _artH),
            _maxScale,
          );
          final reference = math.min(
            screenWidth / _typeReferenceWidth,
            _maxScale,
          );
          final type = layout.clamp(reference * _typeShrinkFloor, reference);

          // 39px font size on the 236 artboard expressed against reference type
          final wordmarkFontSize = (39.0 * _typeReferenceWidth / _artW) * type;
          final planeWidth = 26.0 * layout;
          final wordmarkGap = 8.0 * layout;
          final planeOffset = 270.0 * layout;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final space = context.space;
              final sizes = context.sizes;
              return Stack(
                children: [
                  // ── 1. Full-Bleed Opening Motifs Layer ────────────────────────
                  Opacity(
                    opacity: (1.0 - _motifsOut.value).clamp(0.0, 1.0),
                    child: const IgnorePointer(
                      child: SizedBox.expand(
                        child: _MotifLayer(),
                      ),
                    ),
                  ),

                  // ── 2. City Skyline Layer ─────────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    top: screenHeight * (148.0 / _artH),
                    child: Opacity(
                      opacity: _artRise.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _artRise.value)),
                        child: SvgPicture.asset(
                          'assets/art/launch_skyline.svg',
                          width: screenWidth,
                          height: screenWidth * 180.0 / _artW,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),

                  // ── 3. Centered / Lifted Wordmark ─────────────────────────────
                  Positioned.fill(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -screenHeight * (124.0 / _artH) * _lift.value,
                        ),
                        child: Transform.scale(
                          scale: 1.0 - (0.1 * _lift.value),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // "TRVL"
                                Opacity(
                                  opacity: _trvl.value,
                                  child: Transform.translate(
                                    offset: Offset(-15 * (1 - _trvl.value), 0),
                                    child: Text(
                                      'TRVL',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: wordmarkFontSize,
                                        fontWeight: TypeScale.bold,
                                        letterSpacing: 0.5,
                                        height: 1.0,
                                        color: colors.brandOnSurface,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: wordmarkGap),
                                // Plane Glyph
                                Opacity(
                                  opacity: _plane.value,
                                  child: Transform.translate(
                                    offset: Offset(
                                      -planeOffset * (1 - _plane.value),
                                      0,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/art/plane_glyph.svg',
                                      width: planeWidth,
                                      colorFilter: ColorFilter.mode(
                                        colors.brandSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: wordmarkGap),
                                // "ez"
                                Opacity(
                                  opacity: _ez.value,
                                  child: Transform.translate(
                                    offset: Offset(15 * (1 - _ez.value), 0),
                                    child: Text(
                                      'ez',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: wordmarkFontSize,
                                        fontWeight: TypeScale.bold,
                                        letterSpacing: 0.5,
                                        height: 1.0,
                                        color: colors.brandSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── 4. CTA and Security Footer ────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: space.stackHero,
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: sizes.containerPhone,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: space.stackHero,
                            ),
                            child: Opacity(
                              opacity: _ctaRise.value,
                              child: Transform.translate(
                                offset: Offset(0, 24 * (1 - _ctaRise.value)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const BrandSecurityNote(
                                      text:
                                          'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
                                    ),
                                    SizedBox(height: space.stackFormField),
                                    AppButton(
                                      label: 'Create account',
                                      variant: AppButtonVariant.brandWhite,
                                      onPressed: () =>
                                          context.go(AppRoutes.register),
                                    ),
                                    SizedBox(height: space.stackFormField),
                                    BrandAltLine(
                                      prefix: 'Already have an account? ',
                                      linkText: 'Log in',
                                      onTap: () => context.go(AppRoutes.login),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The drawn background with compass, coins, passport, shopping bag, flight paths
/// and the animated shuffling currency glyphs matching reference launch design.
class _MotifLayer extends StatefulWidget {
  const _MotifLayer();

  @override
  State<_MotifLayer> createState() => _MotifLayerState();
}

class _MotifLayerState extends State<_MotifLayer> {
  static const _pool = [
    '€',
    '£',
    '¥',
    '₹',
    '₩',
    '₽',
    '₺',
    '₪',
    '฿',
    '₫',
    '₱',
    r'R$',
    'kr',
    'zł',
    'Fr',
  ];

  static const _slots = [
    Offset(196, 89.8), // top
    Offset(212.2, 106), // right
    Offset(179.8, 106), // left
  ];
  static const _pinned = Offset(196, 122.2); // the dollar — never shuffles

  List<String> _current = ['¥', '€', '£'];
  double _opacity = 1.0;
  Timer? _timer;
  Timer? _firstShuffle;
  Timer? _shuffleDelayTimer;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    const kFirstShuffleDelay = Duration(milliseconds: 600);
    _firstShuffle = Timer(kFirstShuffleDelay, () {
      _shuffle();
      _timer = Timer.periodic(
        const Duration(milliseconds: 2600),
        (_) => _shuffle(),
      );
    });
  }

  void _shuffle() {
    if (!mounted) return;
    setState(() => _opacity = 0);
    _shuffleDelayTimer?.cancel();
    _shuffleDelayTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final pool = [..._pool]..shuffle(_rng);
      setState(() {
        _current = pool.take(3).toList();
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _firstShuffle?.cancel();
    _timer?.cancel();
    _shuffleDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final s = math.max(
          box.maxWidth / _WelcomeScreenState._artW,
          box.maxHeight / _WelcomeScreenState._artH,
        );
        final w = _WelcomeScreenState._artW * s;
        final h = _WelcomeScreenState._artH * s;

        final glyphBox = 18.0 * s;
        Widget glyph(Offset at, String text, {required bool pinned}) =>
            Positioned(
              left: at.dx * s - glyphBox / 2,
              top: at.dy * s - glyphBox / 2,
              width: glyphBox,
              height: glyphBox,
              child: AnimatedOpacity(
                opacity: pinned ? 1.0 : _opacity,
                duration: const Duration(milliseconds: 450),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: (text.length > 1 ? 6.3 : 8.5) * s,
                      height: 1.0,
                      fontWeight: TypeScale.semiBold,
                      color: colors.brandOnSurface.withValues(alpha: 0.34),
                    ),
                  ),
                ),
              ),
            );

        return ClipRect(
          child: OverflowBox(
            maxWidth: w,
            maxHeight: h,
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/art/launch_motifs.svg',
                    width: w,
                    height: h,
                    fit: BoxFit.fill,
                  ),
                  for (var i = 0; i < _slots.length; i++)
                    glyph(_slots[i], _current[i], pinned: false),
                  glyph(_pinned, r'$', pinned: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

