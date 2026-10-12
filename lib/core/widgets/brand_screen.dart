import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/brand_wordmark.dart';

/// The foundational full-screen scaffold for TrvlEz brand screens (Auth & Verification).
///
/// Features the brand red surface, full-bleed motif artwork, the brand wordmark header,
/// and a layout-safe body area adhering to craftsmanship anti-slop guidelines.
class BrandScreen extends StatelessWidget {
  const BrandScreen({
    super.key,
    required this.body,
    this.backgroundAsset,
    this.onBack,
    this.showWordmark = true,
    this.isScrollable = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  });

  /// The primary content widget.
  final Widget body;

  /// Optional SVG motif asset (e.g., 'assets/art/bg_log_in.svg').
  final String? backgroundAsset;

  /// Optional back navigation callback. Displays a compliant ≥48dp tap target arrow.
  final VoidCallback? onBack;

  /// Controls visibility of the top centered brand wordmark.
  final bool showWordmark;

  /// When true, wraps the body in a [SingleChildScrollView] to prevent keyboard overflows.
  final bool isScrollable;

  /// Outer padding for screen content.
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.brandSurface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ─── Background Motif Layer ──────────────────────────────────────
          if (backgroundAsset != null)
            Positioned.fill(
              child: ClipRect(
                child: SvgPicture.asset(
                  backgroundAsset!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),

          // ─── Content Layer ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header Bar ──────────────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (onBack != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Semantics(
                            button: true,
                            label: 'Back',
                            child: IconButton(
                              icon: Icon(
                                AppIcons.arrowLeft,
                                color: colors.brandOnSurface,
                                size: 20,
                              ),
                              onPressed: onBack,
                              splashRadius: 24,
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.sm),
                            ),
                          ),
                        ),
                      if (showWordmark) const Center(child: BrandWordmark()),
                    ],
                  ),
                ),

                // ── Screen Body ─────────────────────────────────────────────
                Expanded(
                  child: isScrollable
                      ? SingleChildScrollView(
                          padding: contentPadding,
                          child: body,
                        )
                      : Padding(padding: contentPadding, child: body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
