import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/routes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    
    int currentIndex = 0;
    if (location.startsWith(AppRoutes.home)) {
      currentIndex = 0;
    } else if (location.startsWith(AppRoutes.myTrips)) {
      currentIndex = 1;
    } else if (location.startsWith('/favorites')) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.profile)) {
      currentIndex = 3;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(13), // 0.05 * 255
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, Icons.home_filled, Icons.home_outlined, 0, currentIndex, AppRoutes.home),
              _buildNavItem(context, Icons.luggage, Icons.luggage_outlined, 1, currentIndex, AppRoutes.myTrips),
              _buildNavItem(context, Icons.favorite, Icons.favorite_outline, 2, currentIndex, '/favorites'),
              _buildNavItem(context, Icons.person, Icons.person_outline, 3, currentIndex, AppRoutes.profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData activeIcon, IconData inactiveIcon, int index, int currentIndex, String route) {
    final theme = Theme.of(context);
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withAlpha(26) : Colors.transparent, // 0.1 * 255
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          size: 26,
        ),
      ),
    );
  }
}
