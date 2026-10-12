import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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

    return SizedBox(
      height: 140.0,
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoBox(
              imageUrl: widget.draft.heroImageUrl,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: colors.photoChip,
                borderRadius: AppRadius.pillRadius,
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
            top: AppSpacing.sm,
            right: AppSpacing.sm,
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
