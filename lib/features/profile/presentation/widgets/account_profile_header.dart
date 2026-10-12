import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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

    return AppPinnedHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Account',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: TypeScale.bold,
              letterSpacing: -0.3,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            borderRadius: AppRadius.mdRadius,
            onTap: () => context.push(AppRoutes.profileSetup),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.redTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initials.isNotEmpty ? initials : 'T',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: TypeScale.bold,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: TypeScale.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  size: 16,
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
