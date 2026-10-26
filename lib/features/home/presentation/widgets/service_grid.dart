import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';

/// Single interactive card representing an ez-service.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.soon = false,
    this.onTap,
  });

  final IconData icon;

  /// Suffix following "ez" (e.g. 'Stays', 'Money', 'Shop', 'Chat').
  final String title;

  final String subtitle;
  final bool soon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: !soon,
      label: 'ez$title service: $subtitle${soon ? ", coming soon" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: shape.radiusCard,
          onTap: soon ? null : onTap,
          child: Container(
            padding: space.insetCardComfortable,
            decoration: BoxDecoration(
              color: soon ? colors.soonCard : colors.surface,
              borderRadius: shape.radiusCard,
              border: Border.all(
                color: colors.cardBorderSoft,
                width: shape.borderDefault,
              ),
              boxShadow: soon
                  ? null
                  : [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: sizes.controlXl,
                      height: sizes.controlXl,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: soon ? colors.page : colors.redTint,
                        borderRadius: shape.radiusSurface,
                      ),
                      child: Icon(
                        icon,
                        size: sizes.iconLg,
                        color: soon ? colors.soonIcon : colors.brandPrimary,
                      ),
                    ),
                    if (soon)
                      Container(
                        padding: space.insetTag,
                        decoration: BoxDecoration(
                          color: colors.page,
                          borderRadius: shape.radiusPill,
                        ),
                        child: Text(
                          'SOON',
                          style: (context.text.labelSmall ?? const TextStyle())
                              .copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.inkTertiary,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: space.stackFormField),
                EzWord(
                  rest: title,
                  ezColor: soon ? colors.inkTertiary : colors.brandPrimary,
                  style: (context.text.headlineSmall ?? const TextStyle())
                      .copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: soon ? colors.inkTertiary : colors.textPrimary,
                      ),
                ),
                SizedBox(height: space.stackTight),
                Text(
                  subtitle,
                  style: (context.text.bodyMedium ?? const TextStyle())
                      .copyWith(
                        fontSize: 13.5,
                        height: 1.35,
                        color: colors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 2x2 grid displaying the four core TrvlEz services.
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: space.stackFormField));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[i]),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: i + 1 < cards.length
                    ? cards[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}
