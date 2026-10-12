import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
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

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              children: [
                // ── 1. Full-Bleed Opening Motifs Layer ────────────────────────
                Opacity(
                  opacity: (1.0 - _motifsOut.value).clamp(0.0, 1.0),
                  child: IgnorePointer(
                    child: SizedBox.expand(
                      child: SvgPicture.asset(
                        'assets/art/launch_motifs.svg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                // ── 2. City Skyline Layer ─────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: screenHeight * 0.22,
                  child: Opacity(
                    opacity: _artRise.value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _artRise.value)),
                      child: SvgPicture.asset(
                        'assets/art/launch_skyline.svg',
                        width: screenWidth,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),

                // ── 3. Centered / Lifted Wordmark ─────────────────────────────
                Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, -screenHeight * 0.28 * _lift.value),
                      child: Transform.scale(
                        scale: 1.0 - (0.12 * _lift.value),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // "TRVL"
                            Opacity(
                              opacity: _trvl.value,
                              child: Transform.translate(
                                offset: Offset(-20 * (1 - _trvl.value), 0),
                                child: Text(
                                  'TRVL',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 34,
                                    fontWeight: TypeScale.bold,
                                    letterSpacing: 0.5,
                                    height: 1.0,
                                    color: colors.brandOnSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Plane Glyph
                            Opacity(
                              opacity: _plane.value,
                              child: Transform.translate(
                                offset: Offset(-240 * (1 - _plane.value), 0),
                                child: SvgPicture.asset(
                                  'assets/art/plane_glyph.svg',
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                    colors.brandSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // "ez"
                            Opacity(
                              opacity: _ez.value,
                              child: Transform.translate(
                                offset: Offset(20 * (1 - _ez.value), 0),
                                child: Text(
                                  'ez',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 34,
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

                // ── 4. CTA and Security Footer ────────────────────────────────
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                  child: SafeArea(
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
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              label: 'Create account',
                              variant: AppButtonVariant.brandWhite,
                              onPressed: () => context.go(AppRoutes.register),
                            ),
                            const SizedBox(height: AppSpacing.md),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
