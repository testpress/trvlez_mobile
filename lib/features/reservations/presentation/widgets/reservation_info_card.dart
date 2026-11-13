import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Card container for grouping reservation details under a header title.
class ReservationInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ReservationInfoCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.titleLarge?.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: space.stackItem),
          ...children,
        ],
      ),
    );
  }
}

/// Key-value information row within a [ReservationInfoCard].
class ReservationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ReservationInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.stackText),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: sizes.iconSm, color: colors.textSecondary),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.text.labelLarge?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
