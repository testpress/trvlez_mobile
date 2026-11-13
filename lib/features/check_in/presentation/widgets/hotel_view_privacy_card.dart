import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Card listing sensitive data types protected from hotel reception access.
class HotelViewPrivacyCard extends StatelessWidget {
  const HotelViewPrivacyCard({super.key});

  static const _notSharedItems = [
    'Passport scans or documents',
    'Selfie video or biometric data',
    'Credit card or payment numbers',
    'Past trips or other bookings',
    'Address or contact details',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusControl,
        border: Border.all(color: colors.line, width: shape.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not shared with the hotel',
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackItem),
          for (final item in _notSharedItems) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: space.stackText),
              child: Row(
                children: [
                  Icon(
                    AppIcons.eyeOff,
                    size: sizes.iconXs,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: space.inlineIconLabel),
                  Expanded(
                    child: Text(
                      item,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

