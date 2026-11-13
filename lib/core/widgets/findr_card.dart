import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

enum FindrState { locked, processing, notJoined, active }

/// The Findr loyalty and referral card supporting locked, processing, not joined, and active states.
///
/// Component Contract (Playbook 04):
/// - Owner & Role: Findr loyalty status summary and primary conversion card.
/// - Variants: FindrState (locked, processing, notJoined, active).
/// - Applicable States: Default, locked, in-review, joined/active with earnings breakdown.
/// - Accessibility: Semantic stats summary, 48dp CTA touch target, scalable typography.
/// - Validation Owner: Screen test matrices consuming FindrCard.
class FindrCard extends StatelessWidget {
  const FindrCard({
    super.key,
    required this.state,
    this.ctaLabel,
    this.earned = '£0.00',
    this.joined = 0,
    this.inReview = 0,
    this.due = '£0.00',
    this.dueDate = '—',
    this.onCta,
  });

  final FindrState state;
  final String? ctaLabel;
  final String earned;
  final int joined;
  final int inReview;
  final String due;
  final String dueDate;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final effectiveCtaLabel =
        ctaLabel ??
        switch (state) {
          FindrState.locked => 'Start verification',
          FindrState.processing => 'Verification in review',
          FindrState.notJoined => 'Activate Findr',
          FindrState.active => 'Recommend a hotel',
        };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.paper,
        borderRadius: shape.radiusSurface,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // SVG background motif
          Positioned.fill(
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/art/findr_card_motif.svg',
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
          ),
          Padding(
            padding: space.insetCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const FindrHeading(),
                if (state == FindrState.active) ...[
                  _FindrEarnedRow(earned: earned),
                  _FindrMiniStats(
                    joined: joined,
                    inReview: inReview,
                    due: due,
                    dueDate: dueDate,
                  ),
                ] else
                  Padding(
                    padding: EdgeInsets.only(top: space.stackItem),
                    child: Text(
                      'Know a hotel worth staying in? Recommend it. When they '
                      'join TRVLez, you earn a share of what they book.',
                      style: context.text.labelMedium?.copyWith(
                        color: colors.paperInk2,
                        height: 1.4,
                      ),
                    ),
                  ),
                SizedBox(height: space.stackFormField),
                ElevatedButton(
                  onPressed: onCta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: colors.textOnAction,
                    elevation: 0,
                    minimumSize: Size.fromHeight(sizes.controlMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: shape.radiusPill,
                    ),
                  ),
                  child: Text(
                    effectiveCtaLabel,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textOnAction,
                    ),
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

class FindrHeading extends StatelessWidget {
  const FindrHeading({super.key, this.prefix = 'Find', this.iconBox});

  final String prefix;
  final double? iconBox;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final boxSize = iconBox ?? sizes.iconXl;

    return Row(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: shape.radiusControl,
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            AppIcons.mapSearch,
            size: boxSize * 0.5,
            color: colors.brandPrimary,
          ),
        ),
        SizedBox(width: space.inlineIconLabel),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: prefix,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.paperInk,
                ),
              ),
              TextSpan(
                text: 'r',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.brandPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FindrEarnedRow extends StatelessWidget {
  const _FindrEarnedRow({required this.earned});

  final String earned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Padding(
      padding: EdgeInsets.only(top: space.stackItem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            earned,
            style: context.text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.paperInk,
            ),
          ),
          SizedBox(width: space.stackTight),
          Text(
            'earned so far',
            style: context.text.labelMedium?.copyWith(color: colors.paperInk2),
          ),
        ],
      ),
    );
  }
}

class _FindrMiniStats extends StatelessWidget {
  const _FindrMiniStats({
    required this.joined,
    required this.inReview,
    required this.due,
    required this.dueDate,
  });

  final int joined;
  final int inReview;
  final String due;
  final String dueDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      margin: EdgeInsets.only(top: space.stackItem),
      padding: EdgeInsets.only(top: space.stackItem),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.paperLine, width: shape.borderDefault),
        ),
      ),
      child: Row(
        children: [
          _FindrStatItem(value: '$joined', label: 'joined'),
          SizedBox(width: space.stackSection),
          _FindrStatItem(value: '$inReview', label: 'in review'),
          SizedBox(width: space.stackSection),
          _FindrStatItem(value: due, label: 'due $dueDate'),
        ],
      ),
    );
  }
}

class _FindrStatItem extends StatelessWidget {
  const _FindrStatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.paperInk,
          ),
        ),
        SizedBox(height: shape.borderDefault),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(color: colors.paperInk2),
        ),
      ],
    );
  }
}
