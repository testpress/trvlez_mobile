import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Single selectable row in the booking detail card (e.g. Dates, Guests).
class BookingPickRow extends StatelessWidget {
  const BookingPickRow({
    super.key,
    required this.label,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label: '$label, $value',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: space.stackFormField),
          decoration: isLast
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.line,
                      width: shape.borderDefault,
                    ),
                  ),
                ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.0,
                  color: colors.ink,
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14.0,
                    fontWeight: isPlaceholder
                        ? TypeScale.regular
                        : TypeScale.bold,
                    color: isPlaceholder ? colors.textDisabled : colors.ink,
                  ),
                ),
              ),
              SizedBox(width: space.inlineMicro),
              Icon(
                AppIcons.chevronRight,
                size: sizes.iconSm,
                color: colors.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
