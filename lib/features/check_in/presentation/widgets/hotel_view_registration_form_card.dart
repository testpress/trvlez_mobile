import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Card previewing paper registration form guidance when required by local regulation.
class HotelViewRegistrationFormCard extends StatelessWidget {
  const HotelViewRegistrationFormCard({super.key, required this.hotelName});

  final String hotelName;

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
          Row(
            children: [
              Icon(
                AppIcons.alertTriangle,
                size: sizes.iconSm,
                color: colors.feedbackWarning,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  'Paper Registration Form',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackText),
          Text(
            'If $hotelName asks you to complete a paper card at reception, only share the required identity fields.',
            style: context.text.labelMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: space.stackFormField),
          Center(
            child: SvgPicture.asset(
              'assets/art/registration_form.svg',
              width: 140,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
