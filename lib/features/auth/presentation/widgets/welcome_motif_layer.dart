import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// The drawn background with compass, coins, passport, shopping bag, flight paths
/// and the animated shuffling currency glyphs matching reference launch design.
class WelcomeMotifLayer extends StatefulWidget {
  const WelcomeMotifLayer({
    super.key,
    this.artboardWidth = 236.0,
    this.artboardHeight = 472.0,
  });

  final double artboardWidth;
  final double artboardHeight;

  @override
  State<WelcomeMotifLayer> createState() => _WelcomeMotifLayerState();
}

class _WelcomeMotifLayerState extends State<WelcomeMotifLayer> {
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
          box.maxWidth / widget.artboardWidth,
          box.maxHeight / widget.artboardHeight,
        );
        final w = widget.artboardWidth * s;
        final h = widget.artboardHeight * s;

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
                    style: context.text.labelSmall?.copyWith(
                      fontSize: (text.length > 1 ? 6.3 : 8.5) * s,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
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

