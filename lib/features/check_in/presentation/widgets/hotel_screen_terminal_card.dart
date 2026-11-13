import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Dark terminal panel illustrating the minimal hotel check-in dashboard view.
class HotelScreenTerminalCard extends StatelessWidget {
  const HotelScreenTerminalCard({
    super.key,
    required this.guestName,
    required this.bookingRef,
    required this.dates,
    required this.roomType,
  });

  final String guestName;
  final String bookingRef;
  final String dates;
  final String roomType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.hotelScreen,
        borderRadius: shape.radiusSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: shape.radiusControlSm,
                child: SvgPicture.asset(
                  'assets/art/guest_photo.svg',
                  width: 48,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      bookingRef,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.hotelMeta,
                      ),
                    ),
                    SizedBox(height: space.stackTight),
                    Container(
                      padding: space.insetTag,
                      decoration: BoxDecoration(
                        color: colors.hotelOkFill,
                        borderRadius: shape.radiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: sizes.iconXs,
                            color: colors.hotelOkInk,
                          ),
                          SizedBox(width: space.inlineMicro),
                          Text(
                            'ID VERIFIED',
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.hotelOkInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackFormField),
          Divider(color: colors.hotelLine, height: shape.dividerDefault),
          SizedBox(height: space.stackItem),
          _TerminalRow(label: 'Stay', value: dates),
          SizedBox(height: space.stackText),
          _TerminalRow(label: 'Room', value: roomType),
        ],
      ),
    );
  }
}

class _TerminalRow extends StatelessWidget {
  const _TerminalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Row(
      children: [
        SizedBox(
          width: sizes.controlXl + space.inlineMicro,
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(color: colors.hotelLabel),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.text.labelMedium?.copyWith(
              color: colors.brandOnSurface,
            ),
          ),
        ),
      ],
    );
  }
}
