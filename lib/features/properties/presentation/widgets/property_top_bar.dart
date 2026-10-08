import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Top bar with back button and favorite toggle for property detail.
class PropertyTopBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PropertyTopBar({
    super.key,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 12,
      left: AppSpacing.screenPadding,
      right: AppSpacing.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: colors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite ? colors.feedbackError : colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
