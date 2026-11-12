import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_line.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_picker.dart';

/// Screen for selecting stay dates across a scrollable calendar.
class BookingDatesScreen extends ConsumerStatefulWidget {
  const BookingDatesScreen({super.key});

  @override
  ConsumerState<BookingDatesScreen> createState() => _BookingDatesScreenState();
}

class _BookingDatesScreenState extends ConsumerState<BookingDatesScreen> {
  BookingDateRange? _range;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final draft = ref.watch(bookingDraftProvider);

    if (!_initialized) {
      _initialized = true;
      _range = draft?.range;
    }

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
                  'Your dates',
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
              padding: EdgeInsets.symmetric(horizontal: space.insetCard.left),
              child: BookingRangePicker(
                initial: _range,
                onChanged: (r) => setState(() => _range = r),
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
                    child: BookingRangeLine(range: _range),
                  ),
                  BookingAppButton(
                    label: 'Done',
                    onPressed: _range == null
                        ? null
                        : () {
                            final selectedRange = _range;
                            if (selectedRange != null) {
                              ref
                                  .read(bookingDraftProvider.notifier)
                                  .setBookingRange(selectedRange);
                            }
                            context.pop();
                          },
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
