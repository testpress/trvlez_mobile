import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_outline.dart';

/// Screen displayed immediately after booking confirmation.
class BookedScreen extends ConsumerWidget {
  const BookedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final made = ref.watch(lastCreatedBookingsProvider);

    final total = made.fold<int>(0, (sum, b) => sum + b.total);
    final deadline = made.isEmpty
        ? null
        : made.first.range.freeCancellationUntil;
    final currencyCode = made.isNotEmpty
        ? (made.first.reservation?.currencyCode ?? 'GBP')
        : 'GBP';

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          AppPinnedHeader(
            child: Center(
              child: Text(
                'Booked',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.ink,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: space.insetCard.left),
              child: Column(
                children: [
                  SizedBox(height: sizes.avatarMd),
                  Center(
                    child: Container(
                      width: sizes.controlXl,
                      height: sizes.controlXl,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.okFill,
                      ),
                      child: Icon(
                        AppIcons.check,
                        size: sizes.iconLg,
                        color: colors.okInk,
                      ),
                    ),
                  ),
                  SizedBox(height: space.stackFormField),
                  Center(
                    child: Text(
                      made.length > 1
                          ? "You're booked, twice"
                          : "You're booked",
                      style: context.text.headlineMedium?.copyWith(
                        color: colors.ink,
                      ),
                    ),
                  ),
                  SizedBox(height: space.stackFormField),
                  for (final booking in made)
                    Padding(
                      padding: EdgeInsets.only(bottom: space.stackItem),
                      child: Column(
                        children: [
                          if (booking.confirmationCode != null &&
                              booking.confirmationCode!.isNotEmpty) ...[
                            Container(
                              padding: space.insetTag,
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: shape.radiusPill,
                              ),
                              child: Text(
                                'Confirmation code: ${booking.confirmationCode}',
                                style: context.text.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.ink,
                                ),
                              ),
                            ),
                            SizedBox(height: space.stackTight),
                          ],
                          Text(
                            '${booking.propertyName} · ${booking.roomLine}',
                            textAlign: TextAlign.center,
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.ink,
                            ),
                          ),
                          SizedBox(height: space.stackText),
                          Text(
                            '${DateFormatter.dayMonth(booking.range.from)} – ${DateFormatter.dayMonth(booking.range.to)} · ${booking.guests.summary}',
                            textAlign: TextAlign.center,
                            style: context.text.titleSmall?.copyWith(
                              color: colors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (deadline != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        space.stackSection,
                        space.stackItem,
                        space.stackSection,
                        0,
                      ),
                      child: Text(
                        made.length > 1
                            ? 'Each booking has its own free cancellation date. The first is ${DateFormatter.dayMonth(deadline)}.'
                            : 'Free cancellation until ${DateFormatter.dayMonth(deadline)}. We take ${PriceFormatter.formatPrice(total.toDouble(), currencyCode: currencyCode)} at 23:59 that day.',
                        textAlign: TextAlign.center,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.inkTertiary,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        space.stackSection,
                        space.stackItem,
                        space.stackSection,
                        0,
                      ),
                      child: Text(
                        'This stay starts too soon for free cancellation, so ${PriceFormatter.formatPrice(total.toDouble(), currencyCode: currencyCode)} is taken now.',
                        textAlign: TextAlign.center,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.inkTertiary,
                        ),
                      ),
                    ),
                  SizedBox(height: space.stackFormField),
                  Text(
                    'Check-in opens on the day you arrive.',
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium?.copyWith(
                      color: colors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              space.insetCard.left,
              space.stackItem,
              space.insetCard.right,
              space.insetCard.bottom,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.line, width: shape.borderDefault),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookingAppButton(
                    label: 'View booking',
                    onPressed: () => context.go(AppRoutes.myTrips),
                  ),
                  BookingAppOutline(
                    label: 'Back to ezStays',
                    onPressed: () => context.go(AppRoutes.ezStays),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: space.stackItem),
                    child: Text(
                      deadline == null
                          ? 'Your card has been charged.'
                          : 'Nothing has been charged.',
                      textAlign: TextAlign.center,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.inkTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
