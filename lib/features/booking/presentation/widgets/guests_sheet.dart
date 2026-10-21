import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_stepper.dart';

/// Opens the modal bottom sheet for selecting guest counts.
Future<void> showGuestsSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const GuestsSheet(),
    );

/// Modal sheet for selecting adults, children, and infants on a booking.
class GuestsSheet extends ConsumerWidget {
  const GuestsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final draft = ref.watch(bookingDraftProvider);
    final guests = draft?.guests ?? const GuestCounts();

    return Material(
      type: MaterialType.transparency,
      child: Container(
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
                'Guests',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: TypeScale.bold,
                  color: colors.ink,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                'Everyone 18 and over verifies with us. Under-18s are checked in at reception.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.0,
                  color: colors.inkSecondary,
                ),
              ),
              SizedBox(height: space.stackItem),
              for (final kind in GuestKind.values)
                _GuestCountRow(
                  kind: kind,
                  value: guests.of(kind),
                  min: guests.floorFor(kind),
                  last: kind == GuestKind.values.last,
                  onChanged: (v) => ref
                      .read(bookingDraftProvider.notifier)
                      .setBookingGuests(guests.withKind(kind, v)),
                ),
              SizedBox(height: space.stackItem),
              Text(
                'We pass the hotel a count of children and infants and nothing else — no names, no dates of birth.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.0,
                  color: colors.inkTertiary,
                ),
              ),
              SizedBox(height: space.stackFormField),
              BookingAppButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestCountRow extends StatelessWidget {
  const _GuestCountRow({
    required this.kind,
    required this.value,
    required this.min,
    required this.last,
    required this.onChanged,
  });

  final GuestKind kind;
  final int value;
  final int min;
  final bool last;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.symmetric(vertical: space.stackItem),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.line,
                  width: shape.borderDefault,
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kind.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14.0,
                    fontWeight: TypeScale.bold,
                    color: colors.ink,
                  ),
                ),
                SizedBox(height: space.stackText),
                Text(
                  kind.hint,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.0,
                    color: colors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          BookingStepper(
            value: value,
            min: min,
            max: 30,
            label: kind.label.toLowerCase(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
