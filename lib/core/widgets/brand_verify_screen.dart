import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// The standard scaffold shell for all Section 02 verification screens.
///
/// Features a brand red background, optional full-bleed SVG motif,
/// top navigation header with centered title and >=48dp tap target back/close button,
/// structured flex body, and an optional bottom foot pinned above the navigation bar
/// with an integrated help inquiry line.
class BrandVerifyScreen extends StatelessWidget {
  const BrandVerifyScreen({
    super.key,
    required this.title,
    this.body = const [],
    List<Widget>? children,
    this.backgroundAsset,
    this.foot,
    this.onBack,
    this.closeIcon = false,
    this.helpLine = true,
    this.helpArea = ProblemArea.verification,
    this.helpPrefix = 'Having difficulties? ',
    this.helpLinkText = "Tell us what's wrong",
    this.onHelpTap,
    this.padHorizontal,
    this.padTop,
    this.padBottom,
    this.isScrollable = false,
  }) : children = children ?? body;

  /// The header title (e.g. 'Verification', 'Report a problem').
  final String title;

  /// Content widgets placed between header and foot.
  final List<Widget> body;
  final List<Widget> children;

  /// Optional background SVG asset path.
  final String? backgroundAsset;

  /// Pinned bottom widgets (e.g., action buttons, security notice).
  final List<Widget>? foot;

  /// Optional back / dismissal callback.
  final VoidCallback? onBack;

  /// When true, renders an 'X' close icon instead of a back arrow.
  final bool closeIcon;

  /// When true, renders the help inquiry link at the bottom of the foot.
  final bool helpLine;

  /// Problem area passed to problem reporting.
  final ProblemArea helpArea;

  /// Text before the help link.
  final String helpPrefix;

  /// Tappable underlined text for help.
  final String helpLinkText;

  /// Custom callback when tapping the help link. Defaults to opening report screen.
  final VoidCallback? onHelpTap;

  /// Horizontal padding for content.
  final double? padHorizontal;

  /// Top padding for content below header.
  final double? padTop;

  /// Bottom padding for the foot.
  final double? padBottom;

  /// Whether the screen should scroll internally if content exceeds the viewport.
  final bool isScrollable;

  void _defaultOnHelpTap(BuildContext context) {
    if (onHelpTap != null) {
      onHelpTap!();
    } else {
      context.push(
        AppRoutes.reportProblem,
        extra: ProblemReportContext(
          area: helpArea,
          screen: GoRouterState.of(context).uri.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    final hPad = padHorizontal ?? space.insetScreen.left;
    final tPad = padTop ?? space.stackItem;
    final bPad = padBottom ?? space.insetScreen.left;

    return Scaffold(
      backgroundColor: colors.brandSurface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Background motif ──────────────────────────────────────────
            if (backgroundAsset != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: SvgPicture.asset(
                    backgroundAsset!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),

            // ── Screen structure ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, tPad, hPad, bPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Bar
                  _VerifyHeader(
                    title: title,
                    onBack: onBack,
                    closeIcon: closeIcon,
                  ),
                  SizedBox(height: space.stackItem),

                  // Body Content
                  Expanded(
                    child: isScrollable
                        ? SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: children,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [...children, const Spacer()],
                          ),
                  ),

                  // Pinned Foot
                  if (foot != null || helpLine) ...[
                    SizedBox(height: space.stackItem),
                    ...?foot,
                    if (helpLine) ...[
                      SizedBox(height: space.stackItem),
                      _VerifyHelpLine(
                        prefix: helpPrefix,
                        linkText: helpLinkText,
                        onTap: () => _defaultOnHelpTap(context),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifyHeader extends StatelessWidget {
  const _VerifyHeader({
    required this.title,
    required this.onBack,
    required this.closeIcon,
  });

  final String title;
  final VoidCallback? onBack;
  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;

    return SizedBox(
      height: sizes.touchTargetMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Title
          Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15.0,
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
                height: 1.2,
              ),
            ),
          ),

          // Left Back/Close button with compliant >=48dp tap target
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: closeIcon ? 'Close' : 'Back',
                child: IconButton(
                  onPressed: onBack,
                  constraints: BoxConstraints(
                    minWidth: sizes.touchTargetMin,
                    minHeight: sizes.touchTargetMin,
                  ),
                  splashRadius: sizes.iconDefault,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    closeIcon ? AppIcons.close : AppIcons.arrowLeft,
                    size: sizes.iconSm,
                    color: colors.brandOnSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerifyHelpLine extends StatelessWidget {
  const _VerifyHelpLine({
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              prefix,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: TypeScale.regular,
                color: colors.brandSecondaryBody,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.only(bottom: shape.borderDefault),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.brandUnderline,
                      width: shape.borderDefault,
                    ),
                  ),
                ),
                child: Text(
                  linkText,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: TypeScale.medium,
                    color: colors.brandOnSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
