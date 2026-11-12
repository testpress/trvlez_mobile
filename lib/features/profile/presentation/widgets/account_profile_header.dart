import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';

/// Pinned header for the Account screen showing title, avatar, traveler name, and status.
class AccountProfileHeader extends StatelessWidget {
  const AccountProfileHeader({
    required this.name,
    required this.initials,
    required this.subtitle,
    super.key,
  });

  final String name;
  final String initials;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return AppPinnedHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Account',
            style: context.text.headlineMedium?.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackFormField),
          InkWell(
            borderRadius: shape.radiusControl,
            onTap: () => context.push(AppRoutes.profileSetup),
            child: Row(
              children: [
                Container(
                  width: sizes.avatarLg,
                  height: sizes.avatarLg,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.redTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initials.isNotEmpty ? initials : 'T',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
                SizedBox(width: space.inlineItem),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: space.stackText),
                      Text(
                        subtitle,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  size: sizes.iconSm,
                  color: colors.inkTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
