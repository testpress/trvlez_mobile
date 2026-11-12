import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Row on Booking Review screen displaying payment method state and navigation to card entry.
class BookingPaymentRow extends StatelessWidget {
  const BookingPaymentRow({super.key, required this.cardAdded});

  final bool cardAdded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label: cardAdded ? 'Change card' : 'Add a card',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(AppRoutes.bookingCard),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: space.stackFormField),
          child: Row(
            children: [
              Text(
                'Payment',
                style: context.text.labelLarge?.copyWith(color: colors.ink),
              ),
              const Spacer(),
              Text(
                cardAdded ? 'Card saved' : 'Add a card',
                style: context.text.labelLarge?.copyWith(
                  fontWeight: cardAdded ? FontWeight.bold : FontWeight.normal,
                  color: cardAdded ? colors.ink : colors.textDisabled,
                ),
              ),
              SizedBox(width: space.inlineMicro),
              Icon(
                AppIcons.chevronRight,
                size: sizes.iconSm,
                color: colors.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
