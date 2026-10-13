import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_line.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_range_picker.dart';

/// Opens the modal bottom sheet to configure custom dates for a single room.
Future<void> showRoomDatesSheet(BuildContext context, RoomPick pick) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18.0)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: AppRadius.pillRadius,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.pick.type.name,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: TypeScale.bold,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bookingRange == null
                    ? 'These dates apply to this room only.'
                    : 'These dates apply to this room only. The rest of the booking keeps ${DateFormatter.dayMonth(bookingRange.from)} – ${DateFormatter.dayMonth(bookingRange.to)}.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.0,
                  color: colors.inkSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: BookingRangePicker(
                    initial: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              BookingRangeLine(range: _range),
              const SizedBox(height: AppSpacing.sm),
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
