import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

/// Standard property photo box supporting images with graceful fallback.
class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    this.imageUrl,
    this.width,
    this.height = 120,
    this.borderRadius,
    this.iconSize = 24,
  });

  final String? imageUrl;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppRadius.cardRadius;

    final placeholder = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: radius,
      ),
      child: Icon(AppIcons.photo, size: iconSize, color: colors.inkTertiary),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder;
          },
        ),
      ),
    );
  }
}
