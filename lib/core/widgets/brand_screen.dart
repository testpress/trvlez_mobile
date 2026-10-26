import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    this.contentPadding,
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
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    final effectivePadding = contentPadding ?? space.insetBrandScreen;

    return Scaffold(
      backgroundColor: colors.brandSurface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ─── Background Motif Layer ──────────────────────────────────────
          if (backgroundAsset case final assetPath?)
            Positioned.fill(
              child: ClipRect(
                child: SvgPicture.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),

          // ─── Content Layer ───────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sizes.containerPhone),
                child: Column(
                  children: [
                    // ── Header Bar ──────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.only(
                        top: space.stackSection,
                        bottom: space.stackItem,
                      ),
                      child: SizedBox(
                        height: sizes.iconXl,
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
                                      size: sizes.iconMd,
                                    ),
                                    onPressed: onBack,
                                    splashRadius: sizes.iconDefault,
                                    constraints: BoxConstraints(
                                      minWidth: sizes.touchTargetMin,
                                      minHeight: sizes.touchTargetMin,
                                    ),
                                    padding: space.insetControlSm,
                                  ),
                                ),
                              ),
                            if (showWordmark)
                              const Center(child: BrandWordmark()),
                          ],
                        ),
                      ),
                    ),

                    // ── Screen Body ─────────────────────────────────────────────
                    Expanded(
                      child: isScrollable
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                final resolvedPadding = effectivePadding
                                    .resolve(
                                      Directionality.maybeOf(context) ??
                                          TextDirection.ltr,
                                    );
                                return SingleChildScrollView(
                                  padding: effectivePadding,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          constraints.maxHeight -
                                          resolvedPadding.vertical,
                                    ),
                                    child: IntrinsicHeight(child: body),
                                  ),
                                );
                              },
                            )
                          : Padding(padding: effectivePadding, child: body),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
