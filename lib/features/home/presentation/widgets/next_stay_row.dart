import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';

/// Row previewing the traveller's nearest upcoming stay.
class NextStayRow extends StatelessWidget {
  const NextStayRow({
    super.key,
    required this.title,
    required this.detail,
    this.badge,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String detail;
  final String? badge;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label:
          'Your next stay: $title, $detail${badge != null ? ", $badge" : ""}',
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(space.stackItem),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.cardBorderSoft,
              width: shape.borderDefault,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              PhotoBox(
                width: sizes.controlMd,
                height: sizes.controlMd,
                imageUrl: imageUrl,
                borderRadius: shape.radiusControl,
                iconSize: sizes.iconSm,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      detail,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: space.inlineMicro),
                Container(
                  padding: space.insetTag,
                  decoration: BoxDecoration(
                    color: colors.redTint,
                    borderRadius: shape.radiusPill,
                  ),
                  child: Text(
                    badge!,
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
