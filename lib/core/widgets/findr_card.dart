import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

enum FindrState { locked, notJoined, active }

/// The Findr loyalty and referral card supporting locked, not joined, and active states.
class FindrCard extends StatelessWidget {
  const FindrCard({
    super.key,
    required this.state,
    this.earned = '£0.00',
    this.joined = 0,
    this.inReview = 0,
    this.due = '£0.00',
    this.dueDate = '—',
    this.onCta,
  });

  final FindrState state;
  final String earned;
  final int joined;
  final int inReview;
  final String due;
  final String dueDate;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final ctaLabel = switch (state) {
      FindrState.locked => 'Start verification',
      FindrState.notJoined => 'Activate Findr',
      FindrState.active => 'Recommend a hotel',
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.paper,
        borderRadius: AppRadius.cardRadius,
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
            padding: const EdgeInsets.all(AppSpacing.md),
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
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Know a hotel worth staying in? Recommend it. When they '
                      'join TRVLez, you earn a share of what they book.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: colors.paperInk,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: onCta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: colors.textOnAction,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.fullRadius,
                    ),
                  ),
                  child: Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: TypeScale.semiBold,
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
  const FindrHeading({super.key, this.prefix = 'Find', this.iconBox = 32});

  final String prefix;
  final double iconBox;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: iconBox,
          height: iconBox,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.mdRadius,
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
            size: iconBox * 0.5,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: prefix,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: TypeScale.bold,
                  color: colors.paperInk,
                ),
              ),
              TextSpan(
                text: 'r',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: TypeScale.bold,
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
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            earned,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: TypeScale.extraBold,
              color: colors.paperInk,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'earned so far',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colors.paperInk,
            ),
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

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.paperLine, width: 1)),
      ),
      child: Row(
        children: [
          _FindrStatItem(value: '$joined', label: 'joined'),
          const SizedBox(width: AppSpacing.lg),
          _FindrStatItem(value: '$inReview', label: 'in review'),
          const SizedBox(width: AppSpacing.lg),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: TypeScale.bold,
            color: colors.paperInk,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            color: colors.paperInk.withAlpha(160),
          ),
        ),
      ],
    );
  }
}
