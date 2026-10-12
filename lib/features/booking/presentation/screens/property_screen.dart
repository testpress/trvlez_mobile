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
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_empty_dates_card.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_no_selection_view.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_occupancy_note.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_pick_row.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_room_card.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/guests_sheet.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/property_foot_bar.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/property_info_card.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/property_picture_band.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/room_dates_sheet.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';

/// Screen displaying property details, date selection, guest counts, and bookable room types.
class PropertyScreen extends ConsumerWidget {
  const PropertyScreen({
    super.key,
    this.property,
    this.propertyId,
  });

  final Property? property;
  final String? propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (property != null) {
      final currentDraft = ref.read(bookingDraftProvider);
      final prop = property;
      if (prop != null &&
          (currentDraft == null || currentDraft.propertyId != prop.id)) {
        Future.microtask(() {
          ref.read(bookingDraftProvider.notifier).beginBooking(prop);
        });
      }
    } else if (propertyId != null && propertyId!.isNotEmpty) {
      final propAsync = ref.watch(propertyDetailNotifierProvider(propertyId!));
      return propAsync.when(
        loading: () => Scaffold(
          backgroundColor: context.colors.page,
          body: const Column(
            children: [
              _PropertyHeader(),
              Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
        error: (error, _) => Scaffold(
          backgroundColor: context.colors.page,
          body: Column(
            children: [
              const _PropertyHeader(),
              Expanded(
                child: Center(
                  child: Text(
                    'Failed to load property details.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: context.colors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (loadedProp) {
          final currentDraft = ref.read(bookingDraftProvider);
          if (currentDraft == null ||
              currentDraft.propertyId != loadedProp.id) {
            Future.microtask(() {
              ref.read(bookingDraftProvider.notifier).beginBooking(loadedProp);
            });
          }
          final draft = ref.watch(bookingDraftProvider);
          if (draft == null) {
            return const BookingNoSelectionView();
          }
          return _PropertyContent(draft: draft);
        },
      );
    }

    final draft = ref.watch(bookingDraftProvider);

    if (draft == null) {
      return const BookingNoSelectionView();
    }

    return _PropertyContent(draft: draft);
  }
}

class _PropertyHeader extends StatelessWidget {
  const _PropertyHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppPinnedHeader(
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.pop(),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  AppIcons.arrowLeft,
                  size: 20.0,
                  color: colors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          EzWord(
            rest: 'Stays',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16.0,
              fontWeight: TypeScale.bold,
              color: colors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyContent extends ConsumerWidget {
  const _PropertyContent({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final range = draft.range;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          const _PropertyHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PropertyPictureBand(draft: draft),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    child: PropertyInfoCard(draft: draft),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.cardRadius,
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BookingPickRow(
                            label: 'Dates',
                            value: range == null
                                ? 'Add dates'
                                : '${DateFormatter.dayMonth(range.from)} – ${DateFormatter.dayMonth(range.to)}',
                            isPlaceholder: range == null,
                            onTap: () => context.push(AppRoutes.bookingDates),
                          ),
                          BookingPickRow(
                            label: 'Guests',
                            value: draft.guests.summary,
                            isPlaceholder: false,
                            isLast: true,
                            onTap: () => showGuestsSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      'Rooms',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16.0,
                        fontWeight: TypeScale.bold,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  if (range == null)
                    const BookingEmptyDatesCard()
                  else ...[
                    BookingOccupancyNote(
                      rooms: draft.roomCount,
                      sleeps: draft.sleeps,
                      needed: draft.guests.sleepingCount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final pick in draft.picks)
                      BookingRoomCard(
                        pick: pick,
                        differs: !pick.range.sameAs(range),
                        currencyCode: draft.currencyCode,
                        onQuantity: (q) => ref
                            .read(bookingDraftProvider.notifier)
                            .setRoomQuantity(pick.type.id, q),
                        onChangeDates: () => showRoomDatesSheet(context, pick),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          PropertyFootBar(draft: draft),
        ],
      ),
    );
  }
}
