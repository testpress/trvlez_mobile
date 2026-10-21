import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/created_booking.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/guest_counts.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

export 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
export 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';
export 'package:trvlez_mobile/features/booking/domain/entities/created_booking.dart';
export 'package:trvlez_mobile/features/booking/domain/entities/guest_counts.dart';
export 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';

/// Holds the most recently finalized bookings for display on the confirmation screen.
final lastCreatedBookingsProvider = StateProvider<List<CreatedBooking>>(
  (ref) => [],
);

/// Notifier managing the in-flight booking draft.
final bookingDraftProvider = NotifierProvider<BookingNotifier, BookingDraft?>(
  BookingNotifier.new,
);

class BookingNotifier extends Notifier<BookingDraft?> {
  @override
  BookingDraft? build() => null;

  /// Initializes a draft for the given property.
  void beginBooking(Property property) {
    final roomTypes = BookingRoomCatalogue.forProperty(property);
    final nightly =
        property.pricePerNight?.round() ??
        (roomTypes.isNotEmpty
            ? roomTypes.map((r) => r.nightly).reduce((a, b) => a < b ? a : b)
            : 0);

    // Default range is null until traveler selects dates.
    // If draft already exists for this same property, keep its progress.
    final current = state;
    if (current != null &&
        current.propertyId == property.id &&
        (current.picks.isNotEmpty || roomTypes.isEmpty)) {
      return;
    }

    final isSameProperty = current != null && current.propertyId == property.id;
    final savedRange = isSameProperty ? current.range : null;
    final savedGuests = isSameProperty ? current.guests : const GuestCounts();
    final savedCard = isSameProperty ? current.cardAdded : false;

    state = BookingDraft(
      propertyId: property.id,
      propertyName: property.name,
      propertyPlace: property.locationString,
      propertyTag: property.propertyType ?? 'Hotel',
      propertyNightly: nightly,
      heroImageUrl: property.heroImageUrl,
      currencyCode: property.currencyCode ?? 'GBP',
      range: savedRange,
      guests: savedGuests,
      cardAdded: savedCard,
      picks: [
        for (final rt in roomTypes)
          RoomPick(
            type: rt,
            quantity: 0,
            range:
                savedRange ??
                BookingDateRange(
                  DateTime.now().add(const Duration(days: 7)),
                  DateTime.now().add(const Duration(days: 10)),
                ),
          ),
      ],
    );
  }

  /// Sets the overarching booking date range.
  void setBookingRange(BookingDateRange range) {
    final current = state;
    if (current == null) return;

    // Propagate range to unpicked rooms and rooms that matched previous range.
    final prevRange = current.range;
    final updatedPicks = current.picks.map((pick) {
      if (pick.quantity == 0 ||
          prevRange == null ||
          pick.range.sameAs(prevRange)) {
        return pick.withRange(range);
      }
      return pick;
    }).toList();

    state = current.copyWith(range: range, picks: updatedPicks);
  }

  /// Updates the guest counts.
  void setBookingGuests(GuestCounts guests) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(guests: guests);
  }

  /// Updates the quantity of a specific room type.
  void setRoomQuantity(String roomTypeId, int quantity) {
    final current = state;
    if (current == null) return;

    final updatedPicks = current.picks.map((pick) {
      if (pick.type.id == roomTypeId) {
        return pick.withQuantity(quantity);
      }
      return pick;
    }).toList();

    state = current.copyWith(picks: updatedPicks);
  }

  /// Updates the date range for an individual room.
  void setRoomRange(String roomTypeId, BookingDateRange range) {
    final current = state;
    if (current == null) return;

    final updatedPicks = current.picks.map((pick) {
      if (pick.type.id == roomTypeId) {
        return pick.withRange(range);
      }
      return pick;
    }).toList();

    state = current.copyWith(picks: updatedPicks);
  }

  /// Marks payment card as saved.
  void addBookingCard() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(cardAdded: true);
  }

  /// Confirms the current draft by creating real backend reservations.
  Future<List<CreatedBooking>> confirmBooking() async {
    final draft = state;
    if (draft == null || !draft.canConfirm) return [];

    if (draft.propertyId.isEmpty) {
      throw const ValidationException('Invalid property for reservation.');
    }

    final splitGroups = draft.split();
    final createdList = <CreatedBooking>[];

    // Derive guest name from verified state or profile
    final verState = ref.read(verificationNotifierProvider);
    final mrz = verState.mrzExtractionResult;
    final nfc = verState.nfcResult;
    final givenName = nfc?.parsedMrz?.firstName ?? mrz?.firstName;
    final lastName = nfc?.parsedMrz?.lastName ?? mrz?.lastName;
    final verName = [
      givenName,
      lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    final profile = ref.read(currentProfileProvider).valueOrNull;
    final guestName = verName.isNotEmpty
        ? verName
        : (profile?.phone?.isNotEmpty == true
              ? 'Traveler'
              : 'Primary Traveler');

    final repository = ref.read(reservationRepositoryProvider);

    for (var i = 0; i < splitGroups.length; i++) {
      final group = splitGroups[i];
      if (group.isEmpty) continue;
      final range = group.first.range;

      final roomTypeIds = <String>[];
      for (final pick in group) {
        for (int q = 0; q < pick.quantity; q++) {
          roomTypeIds.add(pick.type.id);
        }
      }

      if (roomTypeIds.isEmpty) {
        throw const ValidationException('Please select at least one room.');
      }

      final checkInExact = DateTime.utc(
        range.from.year,
        range.from.month,
        range.from.day,
        14,
        0,
        0,
      );
      final checkOutExact = DateTime.utc(
        range.to.year,
        range.to.month,
        range.to.day,
        11,
        0,
        0,
      );

      final reservation = await repository.createReservation(
        propertyId: draft.propertyId,
        checkInDate: checkInExact.toIso8601String(),
        checkOutDate: checkOutExact.toIso8601String(),
        guestName: guestName,
        guestPhone: profile?.phone,
        numberOfGuests: draft.guests.sleepingCount > 0
            ? draft.guests.sleepingCount
            : 1,
        roomTypeIds: roomTypeIds,
      );

      // Add to live reservations list provider
      ref.read(reservationListProvider.notifier).addReservation(reservation);

      final booking = CreatedBooking(
        id: reservation.id,
        confirmationCode: reservation.confirmationCode,
        propertyId: draft.propertyId,
        propertyName: draft.propertyName,
        propertyPlace: draft.propertyPlace,
        range: range,
        guests: draft.guests,
        picks: group,
        reservation: reservation,
      );
      createdList.add(booking);
    }

    ref.read(lastCreatedBookingsProvider.notifier).state = createdList;
    state = null; // Reset draft
    return createdList;
  }
}
