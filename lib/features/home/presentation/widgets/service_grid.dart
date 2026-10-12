import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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

    return Semantics(
      button: !soon,
      label: 'ez$title service: $subtitle${soon ? ", coming soon" : ""}',
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: soon ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: soon ? colors.page : colors.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: colors.cardBorderSoft, width: 1),
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: soon ? colors.surface : colors.redTint,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: soon ? colors.inkTertiary : colors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  EzWord(
                    rest: title,
                    ezColor: soon ? colors.inkTertiary : colors.brandPrimary,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: TypeScale.bold,
                      color: soon ? colors.inkTertiary : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (soon)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadius.fullRadius,
                      border: Border.all(color: colors.cardBorderSoft),
                    ),
                    child: Text(
                      'SOON',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 8,
                        fontWeight: TypeScale.bold,
                        color: colors.inkTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
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
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: AppSpacing.md));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: AppSpacing.md),
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
