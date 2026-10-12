import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_stepper.dart';

/// Opens the modal bottom sheet for selecting guest counts.
Future<void> showGuestsSheet(BuildContext context) => showModalBottomSheet<void>(
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
    final draft = ref.watch(bookingDraftProvider);
    final guests = draft?.guests ?? const GuestCounts();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18.0),
          ),
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
                'Guests',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: TypeScale.bold,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Everyone 18 and over verifies with us. Under-18s are checked in at reception.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.0,
                  color: colors.inkSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We pass the hotel a count of children and infants and nothing else — no names, no dates of birth.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.0,
                  color: colors.inkTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.line)),
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
                const SizedBox(height: 1),
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
