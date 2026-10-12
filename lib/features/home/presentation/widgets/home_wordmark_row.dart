import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Header top row displaying the TRVLez wordmark and notification bell.
class HomeWordmarkRow extends StatelessWidget {
  const HomeWordmarkRow({
    super.key,
    this.unreadCount = 0,
    this.onBellTap,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  final int unreadCount;
  final VoidCallback? onBellTap;
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'TRVL',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 20,
                  fontWeight: TypeScale.extraBold,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'ez',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 20,
                  fontWeight: TypeScale.extraBold,
                  letterSpacing: -0.5,
                  color: colors.brandPrimary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (onThemeToggle != null) ...[
          Semantics(
            button: true,
            label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onThemeToggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isDarkMode ? AppIcons.sun : AppIcons.bulb,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Semantics(
          button: true,
          label: unreadCount > 0
              ? 'Notifications, $unreadCount unread'
              : 'Notifications',
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onBellTap,
            child: Padding(
              padding: const EdgeInsets.all(8), // Ensures minimum 48dp hit area
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(AppIcons.bell, size: 22, color: colors.textPrimary),
                  if (unreadCount > 0)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
