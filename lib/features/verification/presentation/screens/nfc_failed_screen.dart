import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen displayed when one specific step needs redoing during the verification process.
///
/// Clearly indicates that all other steps remain saved and allows the traveler to jump
/// directly into retrying the single required action or skipping optional hardware steps.
class NfcFailedScreen extends ConsumerWidget {
  const NfcFailedScreen({
    super.key,
    this.failedStepTitle = 'Chip scan',
    this.redoButtonLabel,
    this.redoRoute,
    this.reason,
    this.mitigation,
  });

  final String failedStepTitle;
  final String? redoButtonLabel;
  final String? redoRoute;
  final String? reason;
  final String? mitigation;

  bool get _isChipScan =>
      failedStepTitle.toLowerCase().contains('chip') ||
      failedStepTitle.toLowerCase().contains('nfc');

  bool get _isSelfie =>
      failedStepTitle.toLowerCase().contains('selfie') ||
      failedStepTitle.toLowerCase().contains('face') ||
      failedStepTitle.toLowerCase().contains('liveness');

  String _getResolvedButtonLabel() {
    final label = redoButtonLabel;
    if (label != null && label.isNotEmpty) {
      return label;
    }
    if (_isChipScan) return 'Try chip scan again';
    if (_isSelfie) return 'Record the video again';
    return 'Retake photo';
  }

  String _getResolvedRedoRoute() {
    final route = redoRoute;
    if (route != null && route.isNotEmpty) {
      return route;
    }
    if (_isChipScan) return AppRoutes.nfcScan;
    if (_isSelfie) return AppRoutes.selfieCapture;
    return AppRoutes.passportCapture;
  }

  String _getSubtitle(String? errorFromState) {
    final r = reason;
    if (r != null && r.isNotEmpty) return r;
    if (errorFromState != null && errorFromState.isNotEmpty) {
      return errorFromState;
    }
    if (_isChipScan) {
      return "We couldn't read the chip inside your passport. You can try again or skip this step.";
    }
    if (_isSelfie) {
      return "Everything else is fine — we just couldn't read your face clearly in the video.";
    }
    return "Everything else is fine — we couldn't clearly read your passport document.";
  }

  String _getMitigation() {
    final m = mitigation;
    if (m != null && m.isNotEmpty) return m;
    if (_isChipScan) {
      return 'Hold the top of your phone flat against the passport cover, remove thick phone cases, and keep it still for a few seconds.';
    }
    if (_isSelfie) {
      return "Better light on your face, nothing covering it, and holding the phone at arm's length rather than close up.";
    }
    return 'Place the passport on a flat, well-lit surface with no glare or reflections.';
  }

  List<VerifyStatusItem> _buildRows(bool isNfcSkipped) {
    if (_isChipScan) {
      return const [
        VerifyStatusRow(title: 'Your details', state: VerifyRowStatus.done),
        VerifyStatusRow(title: 'Passport photo', state: VerifyRowStatus.done),
        VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.done),
        VerifyStatusRow(title: 'Chip scan', state: VerifyRowStatus.redo),
      ];
    }
    if (_isSelfie) {
      return [
        const VerifyStatusRow(
          title: 'Your details',
          state: VerifyRowStatus.done,
        ),
        const VerifyStatusRow(
          title: 'Passport photo',
          state: VerifyRowStatus.done,
        ),
        const VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.redo),
        if (!isNfcSkipped)
          const VerifyStatusRow(
            title: 'Chip scan',
            state: VerifyRowStatus.done,
          ),
      ];
    }
    return [
      const VerifyStatusRow(title: 'Your details', state: VerifyRowStatus.redo),
      const VerifyStatusRow(
        title: 'Passport photo',
        state: VerifyRowStatus.redo,
      ),
      const VerifyStatusRow(title: 'Selfie', state: VerifyRowStatus.done),
      if (!isNfcSkipped)
        const VerifyStatusRow(title: 'Chip scan', state: VerifyRowStatus.done),
    ];
  }

  void _onRedoTap(
    BuildContext context,
    WidgetRef ref,
    String route,
    String label,
  ) {
    final notifier = ref.read(verificationNotifierProvider.notifier);
    if (label.toLowerCase().contains('start over') ||
        route == AppRoutes.passportCapture) {
      notifier.reset();
    } else if (_isSelfie) {
      notifier.clearVideo();
    } else if (!_isChipScan) {
      notifier.clearImage();
    }
    context.pushReplacement(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);

    final resolvedLabel = _getResolvedButtonLabel();
    final resolvedRoute = _getResolvedRedoRoute();
    final subtitle = _getSubtitle(state.errorMessage);
    final fixText = _getMitigation();
    final rows = _buildRows(state.isNfcSkipped);

    void navigateExit() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        navigateExit();
      },
      child: BrandVerifyScreen(
        backgroundAsset: 'assets/art/bg_nfc_scan.svg',
        title: 'Verification',
        helpLine: false,
        isScrollable: true,
        onBack: navigateExit,
        body: [
          SizedBox(height: space.stackSection),
          Center(
            child: Container(
              width: sizes.pulseIndicator,
              height: sizes.pulseIndicator,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brandOnSurface,
              ),
              child: Icon(
                AppIcons.refresh,
                size: sizes.iconXl,
                color: colors.brandPrimary,
              ),
            ),
          ),
          SizedBox(height: space.stackFormField),
          Text(
            'One step needs redoing',
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.brandOnSurface,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: space.stackText),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: space.inlineItem),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: space.stackFormField),
          VerifyStatusRows(dimCompleted: true, rows: rows),
          SizedBox(height: space.stackFormField),
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.brandCardIconBackground,
              borderRadius: shape.radiusControl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What usually fixes it',
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.brandOnSurface,
                  ),
                ),
                SizedBox(height: space.stackText),
                Text(
                  fixText,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.brandSecondaryBody,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        foot: [
          AppButton(
            label: resolvedLabel,
            variant: AppButtonVariant.brandWhite,
            onPressed: () =>
                _onRedoTap(context, ref, resolvedRoute, resolvedLabel),
          ),
          if (_isChipScan) ...[
            SizedBox(height: space.stackText),
            AppButton(
              label: 'Skip chip scan and continue',
              variant: AppButtonVariant.brandOutline,
              onPressed: () {
                ref.read(verificationNotifierProvider.notifier).skipNfc();
                ref
                    .read(verificationNotifierProvider.notifier)
                    .submitVerificationAsync();
                context.go(AppRoutes.verificationFinalCheck);
              },
            ),
          ],
          SizedBox(height: space.stackItem),
          const BrandSecurityNote(
            text: "Your other steps are saved. You won't repeat them.",
          ),
          SizedBox(height: space.stackText),
          Center(
            child: InkWell(
              onTap: () {
                context.push(
                  AppRoutes.reportProblem,
                  extra: const ProblemReportContext(
                    area: ProblemArea.verification,
                    screen: AppRoutes.nfcFailed,
                  ),
                );
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizes.touchTargetMin),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: context.text.bodySmall?.copyWith(
                        color: colors.brandSecondaryBody,
                      ),
                      children: [
                        const TextSpan(text: 'Still stuck? '),
                        TextSpan(
                          text: "Tell us what's wrong",
                          style: context.text.bodySmall?.copyWith(
                            color: colors.brandSecondary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
