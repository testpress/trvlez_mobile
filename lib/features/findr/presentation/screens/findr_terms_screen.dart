import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_terms_step_view.dart';

/// Screen 4.2 · Step 1 of 2: Findr Terms & Conditions of Participation.
/// Renders backend-delivered versioned agreement sections and requires explicit acceptance.
class FindrTermsScreen extends ConsumerStatefulWidget {
  const FindrTermsScreen({super.key});

  @override
  ConsumerState<FindrTermsScreen> createState() => _FindrTermsScreenState();
}

class _FindrTermsScreenState extends ConsumerState<FindrTermsScreen> {
  bool _hasAcceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final terms = ref.watch(finderTermsProvider);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    AppIcons.arrowLeft,
                    size: sizes.iconMd,
                    color: colors.textPrimary,
                  ),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    'Terms & Conditions',
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: sizes.controlLg),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: FinderTermsStepView(
              terms: terms,
              hasAcceptedTerms: _hasAcceptedTerms,
              onAcceptanceChanged: (value) {
                setState(() => _hasAcceptedTerms = value);
              },
              showHeaderPills: true,
            ),
          ),

          // ── Sticky Footer ──────────────────────────────────────────────
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.borderSubtle,
                  width: shape.borderDefault,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: sizes.containerForm),
                  child: AppButton(
                    label: 'Continue to Address',
                    icon: Icon(
                      AppIcons.arrowRight,
                      size: sizes.iconSm,
                      color: colors.textOnAction,
                    ),
                    onPressed: _hasAcceptedTerms
                        ? () => context.push(AppRoutes.findrAddress)
                        : null,
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
