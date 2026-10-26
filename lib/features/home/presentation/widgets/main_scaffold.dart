import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Top-level scaffold managing the 4-tab bottom navigation shell for authenticated users.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      body: child,
      bottomNavigationBar: _BottomTabBar(),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;
    final sizes = context.sizes;
    final location = GoRouterState.of(context).matchedLocation;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.myTrips)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.favorites)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.profile)) {
      currentIndex = 3;
    } else {
      currentIndex = 0;
    }

    final barHeight = math.max(
      sizes.appBarHeight,
      sizes.touchTargetMin + bottomInset,
    );

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.cardBorderSoft,
            width: shape.borderDefault,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Row(
          children: [
            _TabBarItem(
              index: 0,
              currentIndex: currentIndex,
              icon: AppIcons.home,
              label: 'Home',
              route: AppRoutes.home,
            ),
            _TabBarItem(
              index: 1,
              currentIndex: currentIndex,
              icon: AppIcons.calendar,
              label: 'Bookings',
              route: AppRoutes.myTrips,
            ),
            _TabBarItem(
              index: 2,
              currentIndex: currentIndex,
              icon: AppIcons.heart,
              label: 'Saved',
              route: AppRoutes.favorites,
            ),
            _TabBarItem(
              index: 3,
              currentIndex: currentIndex,
              icon: AppIcons.user,
              label: 'Account',
              route: AppRoutes.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.route,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final isSelected = index == currentIndex;
    final activeColor = colors.brandPrimary;
    final inactiveColor = colors.inkTertiary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              context.go(route);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: sizes.iconSm,
                color: isSelected ? activeColor : inactiveColor,
              ),
              SizedBox(height: space.stackText),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
