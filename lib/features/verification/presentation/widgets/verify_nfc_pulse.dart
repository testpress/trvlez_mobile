import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';

/// 3 concentric pulsing rings expanding out of the NFC core.
class VerifyNfcPulse extends StatefulWidget {
  const VerifyNfcPulse({super.key, this.size = 132.0});
  final double size;

  @override
  State<VerifyNfcPulse> createState() => _VerifyNfcPulseState();
}

class _VerifyNfcPulseState extends State<VerifyNfcPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2700),
  );

  static const _ease = Cubic(0.3, 0.6, 0.4, 1.0);

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 3; i++) _buildRing(context, widget.size, i),
              _buildCore(context, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRing(BuildContext context, double box, int index) {
    final colors = context.colors;
    if (_reducedMotion) {
      return index == 0
          ? Container(
              width: box,
              height: box,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.verificationStepRing.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            )
          : const SizedBox.shrink();
    }

    final t = (_controller.value + index / 3.0) % 1.0;
    final e = _ease.transform(t);
    final scale = 0.46 + (1.04 - 0.46) * e;
    final opacity = t <= 0.7
        ? 0.8 + (0.14 - 0.8) * (t / 0.7)
        : 0.14 + (0.0 - 0.14) * ((t - 0.7) / 0.3);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.brandOnSurface.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCore(BuildContext context, AppColors colors) {
    final breathe = _reducedMotion
        ? 1.0
        : 1.0 + 0.07 * (1 - (2 * _controller.value - 1).abs());

    return Transform.scale(
      scale: breathe,
      child: Container(
        width: 62.0,
        height: 62.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.verificationCardActiveFill,
        ),
        child: Icon(AppIcons.nfc, size: 30.0, color: colors.brandOnSurface),
      ),
    );
  }
}
