import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Small muted group heading in settings/account lists.
class SettingsGroupHeading extends StatelessWidget {
  const SettingsGroupHeading(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        space.inlineMicro,
        space.stackFormField,
        0,
        space.stackText,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: TypeScale.semiBold,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

/// Settings row inside a card group.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.count,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final int? count;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final tileColor = danger ? colors.redTint : colors.page;
    final iconColor = danger ? colors.brandPrimary : colors.inkSecondary;
    final labelColor = danger ? colors.brandPrimary : colors.textPrimary;

    return Semantics(
      button: true,
      label: '$label${value != null ? ", $value" : ""}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: space.insetCard.left,
            vertical: space.stackItem,
          ),
          child: Row(
            children: [
              Container(
                width: sizes.avatarSm,
                height: sizes.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Icon(icon, size: sizes.iconXs, color: iconColor),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.medium,
                    color: labelColor,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
              ] else ...[
                if (value != null) ...[
                  Text(
                    value!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(width: space.inlineMicro),
                ],
                if (count != null) ...[
                  Container(
                    padding: space.insetTagSm,
                    decoration: BoxDecoration(
                      color: colors.brandPrimary,
                      borderRadius: shape.radiusPill,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: TypeScale.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: space.inlineMicro),
                ],
                Icon(
                  AppIcons.chevronRight,
                  size: sizes.iconXs,
                  color: colors.inkTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card container for a group of settings rows with hairline separators.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.rows});

  final List<SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      clipBehavior: Clip.antiAlias,
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
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: shape.dividerDefault,
                indent:
                    space.insetCard.left +
                    sizes.avatarSm +
                    space.inlineIconLabel,
                color: colors.cardBorderSoft,
              ),
          ],
        ],
      ),
    );
  }
}
