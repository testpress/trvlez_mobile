import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// One guest on the "Who's staying" check-in screen.
class CheckInGuestRow extends StatelessWidget {
  const CheckInGuestRow({
    super.key,
    required this.initials,
    required this.name,
    required this.detail,
    required this.chip,
    required this.ready,
    this.onTap,
  });

  /// Null displays generic user icon (for uninvited guests).
  final String? initials;
  final String name;
  final String detail;
  final String chip;
  final bool ready;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(top: space.stackFormField),
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.checkInStepPanel,
            borderRadius: shape.radiusControl,
          ),
          child: Row(
            children: [
              Container(
                width: sizes.avatarMd,
                height: sizes.avatarMd,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ready
                      ? colors.brandOnSurface
                      : colors.checkInGuestAvatar,
                  shape: BoxShape.circle,
                ),
                child: initials == null
                    ? Icon(
                        AppIcons.user,
                        size: sizes.iconSm,
                        color: ready
                            ? colors.brandPrimary
                            : colors.brandOnSurface,
                      )
                    : Text(
                        initials!,
                        style: context.text.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ready
                              ? colors.brandActionLabel
                              : colors.brandOnSurface,
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
                      name,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      detail,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.inlineMicro),
              Container(
                padding: space.insetTag,
                decoration: BoxDecoration(
                  color: ready
                      ? colors.brandOnSurface
                      : colors.checkInGuestAvatar,
                  borderRadius: shape.radiusPill,
                ),
                child: Text(
                  chip,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ready
                        ? colors.brandActionLabel
                        : colors.brandOnSurface,
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
