import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Hero header image for the property detail view.
class PropertyHeaderImage extends StatelessWidget {
  final Property property;

  const PropertyHeaderImage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.42,
      child: Stack(
        fit: StackFit.expand,
        children: [
          property.heroImageUrl.isNotEmpty
              ? Image.network(
                  property.heroImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(colors),
                )
              : _buildFallback(colors),
          // Subtle top gradient for back button contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.textPrimary.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(AppColors colors) {
    return Container(
      color: colors.surfaceSubtle,
      child: Center(
        child: Icon(Icons.hotel_outlined, size: 64, color: colors.textDisabled),
      ),
    );
  }
}
