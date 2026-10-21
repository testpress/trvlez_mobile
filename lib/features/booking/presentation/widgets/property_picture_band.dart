import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';
import 'package:trvlez_mobile/core/widgets/photo_box.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';

/// Photo banner displaying property category tag and favorite toggle.
class PropertyPictureBand extends StatefulWidget {
  const PropertyPictureBand({super.key, required this.draft});

  final BookingDraft draft;

  @override
  State<PropertyPictureBand> createState() => _PropertyPictureBandState();
}

class _PropertyPictureBandState extends State<PropertyPictureBand> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return SizedBox(
      height: sizes.thumbPhotoMd + sizes.iconMd,
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoBox(
              imageUrl: widget.draft.heroImageUrl,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: space.stackItem,
            left: space.inlineIconLabel,
            child: Container(
              padding: space.insetTag,
              decoration: BoxDecoration(
                color: colors.photoChip,
                borderRadius: shape.radiusPill,
              ),
              child: Text(
                widget.draft.propertyTag,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.0,
                  fontWeight: TypeScale.bold,
                  color: colors.ink,
                ),
              ),
            ),
          ),
          Positioned(
            top: space.stackItem,
            right: space.inlineIconLabel,
            child: HeartButton(
              saved: _isSaved,
              onPhoto: true,
              onTap: () => setState(() => _isSaved = !_isSaved),
            ),
          ),
        ],
      ),
    );
  }
}
