import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Red-surface consent checkbox.
class CheckInConsentTick extends StatelessWidget {
  const CheckInConsentTick({
    super.key,
    required this.agreed,
    required this.label,
    required this.onTap,
    this.marginTop,
  });

  final bool agreed;
  final String label;
  final VoidCallback onTap;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      checked: agreed,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: marginTop ?? space.stackFormField),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizes.iconMd,
                height: sizes.iconMd,
                margin: EdgeInsets.only(top: shape.borderMedium),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: agreed ? colors.brandOnSurface : null,
                  border: Border.all(
                    color: agreed
                        ? colors.brandOnSurface
                        : colors.checkInConsentBox,
                    width: shape.borderMedium,
                  ),
                  borderRadius: shape.radiusSubtle,
                ),
                child: agreed
                    ? Icon(
                        AppIcons.check,
                        size: sizes.iconXs,
                        color: colors.brandActionLabel,
                      )
                    : null,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.brandSecondary,
                    height: 1.35,
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
