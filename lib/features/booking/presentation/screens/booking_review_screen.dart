import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_no_selection_view.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_note_card.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_payment_row.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_review_breakdown_card.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_review_property_card.dart';

/// Screen summarizing all booking choices before payment and confirmation.
class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key});

  @override
  ConsumerState<BookingReviewScreen> createState() =>
      _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final made = await ref
          .read(bookingDraftProvider.notifier)
          .confirmBooking();
      if (!mounted) return;
      if (made.isNotEmpty) {
        context.pushReplacement(AppRoutes.bookingDone);
      }
    } catch (error, stackTrace) {
      AppLogger.warning('Booking submission failed', error, stackTrace);
      if (!mounted) return;
      final String message = AppException.userMessage(
        error,
        'Unable to complete booking. Please try again.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final draft = ref.watch(bookingDraftProvider);

    if (draft == null || draft.chosen.isEmpty) {
      return const BookingNoSelectionView();
    }

    final bookingRange = draft.range;
    final deadline = draft.ranges.isNotEmpty
        ? draft.ranges.first.freeCancellationUntil
        : null;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          AppPinnedHeader(
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Back',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: EdgeInsets.all(space.stackText),
                      child: Icon(
                        AppIcons.arrowLeft,
                        size: sizes.iconMd,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: space.inlineIconLabel),
                Text(
                  'Review',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: space.stackFormField),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      space.insetCard.left,
                      space.stackFormField,
                      space.insetCard.right,
                      0,
                    ),
                    child: BookingReviewPropertyCard(draft: draft),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      space.insetCard.left,
                      space.stackItem,
                      space.insetCard.right,
                      0,
                    ),
                    child: BookingReviewBreakdownCard(
                      draft: draft,
                      bookingRange: bookingRange,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      space.insetCard.left,
                      space.stackText,
                      space.insetCard.right,
                      0,
                    ),
                    child: Text(
                      'Local city taxes may be payable directly at the property.',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.inkTertiary,
                      ),
                    ),
                  ),
                  if (draft.splits)
                    BookingNoteCard(
                      title: 'This becomes ${draft.ranges.length} bookings',
                      body:
                          'One room runs to different dates, so it gets its own booking, its own check-in and its own cancellation date. They all appear under Upcoming.',
                    ),
                  if (deadline != null)
                    BookingNoteCard(
                      amber: true,
                      title:
                          'Free cancellation until ${DateFormatter.dayMonth(deadline)}',
                      body:
                          'We charge ${PriceFormatter.formatPrice(draft.total.toDouble(), currencyCode: draft.currencyCode)} at 23:59 that day, not now. Cancel before it and you pay nothing.',
                    )
                  else
                    BookingNoteCard(
                      amber: true,
                      title: 'No free cancellation',
                      body:
                          'This stay starts soon, so ${PriceFormatter.formatPrice(draft.total.toDouble(), currencyCode: draft.currencyCode)} is charged when you confirm.',
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
                  Padding(
                    padding: EdgeInsets.only(bottom: space.stackItem),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.insetCard.left,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(
                          color: colors.line,
                          width: shape.borderDefault,
                        ),
                        borderRadius: shape.radiusSurface,
                      ),
                      child: BookingPaymentRow(cardAdded: draft.cardAdded),
                    ),
                  ),
                  BookingAppButton(
                    label: _isSubmitting ? 'Confirming…' : 'Confirm booking',
                    onPressed: (draft.canConfirm && !_isSubmitting)
                        ? _handleConfirm
                        : null,
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
