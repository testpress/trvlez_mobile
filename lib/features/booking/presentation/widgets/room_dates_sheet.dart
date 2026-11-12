import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_line.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_picker.dart';

/// Opens the modal bottom sheet to configure custom dates for a single room.
Future<void> showRoomDatesSheet(BuildContext context, RoomPick pick) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.transparent,
      isScrollControlled: true,
      builder: (_) => RoomDatesSheet(pick: pick),
    );

/// Modal sheet for modifying dates scoped specifically to one room.
class RoomDatesSheet extends ConsumerStatefulWidget {
  const RoomDatesSheet({super.key, required this.pick});

  final RoomPick pick;

  @override
  ConsumerState<RoomDatesSheet> createState() => _RoomDatesSheetState();
}

class _RoomDatesSheetState extends ConsumerState<RoomDatesSheet> {
  late BookingDateRange? _range = widget.pick.range;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final draft = ref.watch(bookingDraftProvider);
    final bookingRange = draft?.range;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
        ),
        padding: EdgeInsets.fromLTRB(
          space.insetCard.left,
          space.stackItem,
          space.insetCard.right,
          space.insetCard.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: sizes.avatarMd,
                  height: space.stackText,
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: shape.radiusPill,
                  ),
                ),
              ),
              SizedBox(height: space.stackFormField),
              Text(
                widget.pick.type.name,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.ink,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                bookingRange == null
                    ? 'These dates apply to this room only.'
                    : 'These dates apply to this room only. The rest of the booking keeps ${DateFormatter.dayMonth(bookingRange.from)} – ${DateFormatter.dayMonth(bookingRange.to)}.',
                style: context.text.labelMedium?.copyWith(
                  color: colors.inkSecondary,
                ),
              ),
              SizedBox(height: space.stackItem),
              Flexible(
                child: SingleChildScrollView(
                  child: BookingRangePicker(
                    initial: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                ),
              ),
              SizedBox(height: space.stackItem),
              BookingRangeLine(range: _range),
              SizedBox(height: space.stackItem),
              BookingAppButton(
                label: 'Done',
                onPressed: _range == null
                    ? null
                    : () {
                        final selectedRange = _range;
                        if (selectedRange != null) {
                          ref
                              .read(bookingDraftProvider.notifier)
                              .setRoomRange(widget.pick.type.id, selectedRange);
                        }
                        Navigator.pop(context);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
