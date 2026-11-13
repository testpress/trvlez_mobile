import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Standard property photo box supporting images with graceful fallback.
///
/// Component Contract (Playbook 04):
/// - Owner & Role: Core UI property and media thumbnail display with placeholder fallback.
/// - Variants: Default rectangular rounded thumbnail container.
/// - Applicable States: Image loaded, placeholder/missing image, network error.
/// - Accessibility: Semantic placeholder icon, anti-aliased surface bounds.
/// - Validation Owner: Screen test matrices consuming PhotoBox.
class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.iconSize,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;
    final shape = context.shape;

    final radius = borderRadius ?? shape.radiusSurface;
    final effectiveHeight = height ?? sizes.thumbPhotoMd;
    final effectiveIconSize = iconSize ?? sizes.iconDefault;

    final placeholder = Container(
      width: width,
      height: effectiveHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: radius,
      ),
      child: Icon(
        AppIcons.photo,
        size: effectiveIconSize,
        color: colors.inkTertiary,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: effectiveHeight,
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
