import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show findrPortfolioProvider;
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';

/// Helper function to display the Findr onboarding and terms sheet.
Future<bool?> showJoinFindrSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const JoinFindrSheet(),
  );
}

/// Modal bottom sheet allowing verified travelers to review Findr programme
/// terms and activate their membership.
class JoinFindrSheet extends ConsumerStatefulWidget {
  const JoinFindrSheet({super.key});

  @override
  ConsumerState<JoinFindrSheet> createState() => _JoinFindrSheetState();
}

class _JoinFindrSheetState extends ConsumerState<JoinFindrSheet> {
  bool _agreed = false;

  static const _steps = [
    (
      'Recommend a hotel',
      'Send us the name and where it is. We approach them on your behalf.',
    ),
    (
      'We review and invite',
      'A person checks every recommendation before we contact anyone.',
    ),
    ('You earn', '5% of TRVLez commission on their bookings, for 12 months.'),
  ];

  static const _terms = [
    'Paid monthly once your balance passes £50.',
    'You may not contact hotels as a TRVLez representative.',
    'Any tax on what you earn is your responsibility.',
    'We can decline a recommendation without giving a reason.',
    "Either of us can leave the programme with 30 days' notice.",
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sheet Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              space.insetCard.left,
              space.insetCard.top,
              space.insetCard.right,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FindrHeading(prefix: 'Join Find', iconBox: sizes.iconXl),
                      SizedBox(height: space.stackItem),
                      Text(
                        'Recommend hotels you rate. Earn when they join and start taking bookings through TRVLez.',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(
                    AppIcons.x,
                    size: sizes.iconSm,
                    color: colors.inkSecondary,
                  ),
                  splashRadius: sizes.iconMd,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          SizedBox(height: space.stackItem),

          // ── Scrollable Body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: space.insetCard.left,
                vertical: space.stackText,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, step) in _steps.indexed)
                    _StepItem(number: i + 1, title: step.$1, body: step.$2),
                  Padding(
                    padding: EdgeInsets.only(
                      top: space.stackFormField,
                      bottom: space.stackText,
                    ),
                    child: Text(
                      'The terms, in short',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  for (final term in _terms) _TermItem(text: term),
                  SizedBox(height: space.stackItem),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Full terms: trvlez.com/terms/findr',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          backgroundColor: colors.surfaceSubtle,
                        ),
                      );
                    },
                    child: Text(
                      'Read the full terms',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: space.stackFormField),
                ],
              ),
            ),
          ),

          // ── Sticky Footer ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              space.insetCard.left,
              space.stackItem,
              space.insetCard.right,
              space.insetCard.left + viewPadding.bottom,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.line, width: shape.borderDefault),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    children: [
                      Container(
                        width: sizes.iconSm,
                        height: sizes.iconSm,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _agreed
                              ? colors.brandPrimary
                              : Colors.transparent,
                          borderRadius: shape.radiusSubtle,
                          border: Border.all(
                            color: _agreed
                                ? colors.brandPrimary
                                : colors.border,
                            width: shape.borderMedium,
                          ),
                        ),
                        child: _agreed
                            ? Icon(
                                AppIcons.check,
                                size: sizes.iconXs,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Expanded(
                        child: Text(
                          'I agree to the Findr programme terms',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: TypeScale.medium,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.stackFormField),
                AppButton(
                  label: 'Activate Findr',
                  enabled: _agreed,
                  onPressed: () {
                    ref.read(findrPortfolioProvider.notifier).joinFindr();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.body,
  });

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackItem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sizes.iconDefault,
            height: sizes.iconDefault,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: TypeScale.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: shape.strokeProgress),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  const _TermItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackTight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: space.stackTight,
              right: space.inlineIconLabel,
            ),
            child: Container(
              width: sizes.indicatorProgressHeight,
              height: sizes.indicatorProgressHeight,
              decoration: BoxDecoration(
                color: colors.inkTertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
