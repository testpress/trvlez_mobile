import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    final made = ref.watch(lastCreatedBookingsProvider);

    final total = made.fold<int>(0, (sum, b) => sum + b.total);
    final deadline =
        made.isEmpty ? null : made.first.range.freeCancellationUntil;
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
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: TypeScale.bold,
                  color: colors.ink,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: 36.0),
                  Center(
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.okFill,
                      ),
                      child: Icon(
                        AppIcons.check,
                        size: 26.0,
                        color: colors.okInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(
                      made.length > 1 ? "You're booked, twice" : "You're booked",
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20.0,
                        fontWeight: TypeScale.bold,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final booking in made)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        children: [
                          if (booking.confirmationCode != null &&
                              booking.confirmationCode!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.pillRadius,
                              ),
                              child: Text(
                                'Confirmation code: ${booking.confirmationCode}',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.0,
                                  fontWeight: TypeScale.bold,
                                  color: colors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            '${booking.propertyName} · ${booking.roomLine}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14.0,
                              fontWeight: TypeScale.bold,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormatter.dayMonth(booking.range.from)} – ${DateFormatter.dayMonth(booking.range.to)} · ${booking.guests.summary}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.0,
                              color: colors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (deadline != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Text(
                        made.length > 1
                            ? 'Each booking has its own free cancellation date. The first is ${DateFormatter.dayMonth(deadline)}.'
                            : 'Free cancellation until ${DateFormatter.dayMonth(deadline)}. We take ${PriceFormatter.formatPrice(total.toDouble(), currencyCode: currencyCode)} at 23:59 that day.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.0,
                          color: colors.inkTertiary,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Text(
                        'This stay starts too soon for free cancellation, so ${PriceFormatter.formatPrice(total.toDouble(), currencyCode: currencyCode)} is taken now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.0,
                          color: colors.inkTertiary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Check-in opens on the day you arrive.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.0,
                      color: colors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.line)),
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
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      deadline == null
                          ? 'Your card has been charged.'
                          : 'Nothing has been charged.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.0,
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
