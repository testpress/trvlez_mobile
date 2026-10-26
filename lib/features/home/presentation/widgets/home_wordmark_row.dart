import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final wordmarkBaseStyle = context.text.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );

    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'TRVL',
                style: wordmarkBaseStyle?.copyWith(color: colors.textPrimary),
              ),
              TextSpan(
                text: 'ez',
                style: wordmarkBaseStyle?.copyWith(color: colors.brandPrimary),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (onThemeToggle != null) ...[
          Semantics(
            button: true,
            label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: sizes.touchTargetMin,
                minHeight: sizes.touchTargetMin,
              ),
              child: InkWell(
                borderRadius: shape.radiusOverlay,
                onTap: onThemeToggle,
                child: Center(
                  child: Icon(
                    isDarkMode ? AppIcons.sun : AppIcons.bulb,
                    size: sizes.iconMd,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: space.inlineMicro),
        ],
        Semantics(
          button: true,
          label: unreadCount > 0
              ? 'Notifications, $unreadCount unread'
              : 'Notifications',
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: sizes.touchTargetMin,
              minHeight: sizes.touchTargetMin,
            ),
            child: InkWell(
              borderRadius: shape.radiusOverlay,
              onTap: onBellTap,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      AppIcons.bell,
                      size: sizes.iconDefault,
                      color: colors.textPrimary,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: sizes.indicatorDot,
                          height: sizes.indicatorDot,
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: shape.borderMedium,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
