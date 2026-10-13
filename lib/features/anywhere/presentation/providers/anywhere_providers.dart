import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/features/anywhere/domain/entities/anywhere_stay.dart';

export 'package:trvlez_mobile/features/anywhere/domain/entities/anywhere_stay.dart';

/// Pre-populated partner hotel directory items.
const List<HotelDirectoryItem> kHotelDirectory = [
  HotelDirectoryItem(name: 'Casa Verde Villas', place: 'Seville, Spain'),
  HotelDirectoryItem(
    name: 'Alpine Lodge Interlaken',
    place: 'Interlaken, Switzerland',
  ),
  HotelDirectoryItem(name: 'Grand Ocean Resort', place: 'Tenerife, Spain'),
];

/// In-progress anywhere check-in draft state.
@immutable
class AnywhereDraft {
  const AnywhereDraft({
    this.hotelName = '',
    this.place = '',
    this.email = '',
    this.dates = '',
    this.guests = 2,
    this.route = AnywhereRoute.onTrvlez,
    this.isCustom = false,
  });

  final String hotelName;
  final String place;
  final String email;
  final String dates;
  final int guests;
  final AnywhereRoute route;
  final bool isCustom;

  bool get canLeaveHotel =>
      hotelName.trim().isNotEmpty && email.trim().contains('@');

  bool get canLeaveStay => dates.trim().isNotEmpty && guests > 0;

  AnywhereDraft copyWith({
    String? hotelName,
    String? place,
    String? email,
    String? dates,
    int? guests,
    AnywhereRoute? route,
    bool? isCustom,
  }) {
    return AnywhereDraft(
      hotelName: hotelName ?? this.hotelName,
      place: place ?? this.place,
      email: email ?? this.email,
      dates: dates ?? this.dates,
      guests: guests ?? this.guests,
      route: route ?? this.route,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

final anywhereDraftProvider =
    StateNotifierProvider<AnywhereDraftNotifier, AnywhereDraft>((ref) {
  return AnywhereDraftNotifier(ref);
});

class AnywhereDraftNotifier extends StateNotifier<AnywhereDraft> {
  AnywhereDraftNotifier(this.ref) : super(const AnywhereDraft());

  final Ref ref;

  void begin() {
    state = const AnywhereDraft();
  }

  void pickHotel(HotelDirectoryItem hotel) {
    state = state.copyWith(
      hotelName: hotel.name,
      place: hotel.place,
      email: '',
      route: AnywhereRoute.onTrvlez,
      isCustom: false,
    );
  }

  void setCustomHotel({
    required String name,
    required String place,
    required String email,
  }) {
    state = state.copyWith(
      hotelName: name,
      place: place,
      email: email,
      route: AnywhereRoute.byEmail,
      isCustom: true,
    );
  }

  void setStay({required String dates, required int guests}) {
    state = state.copyWith(dates: dates, guests: guests);
  }

  void submit() {
    final now = DateFormat('d MMM').format(DateTime.now());
    final newStay = AnywhereStay(
      id: 'anywhere_${DateTime.now().millisecondsSinceEpoch}',
      hotel: state.hotelName,
      place: state.place,
      dates: state.dates.isEmpty ? 'Upcoming stay' : state.dates,
      guests: state.guests,
      route: state.route,
      status: AnywhereStatus.sent,
      hotelEmail: state.email,
      sentOn: now,
    );

    ref.read(anywhereStaysProvider.notifier).addStay(newStay);
  }
}

final anywhereStaysProvider =
    StateNotifierProvider<AnywhereStaysNotifier, List<AnywhereStay>>((ref) {
  return AnywhereStaysNotifier();
});

class AnywhereStaysNotifier extends StateNotifier<List<AnywhereStay>> {
  AnywhereStaysNotifier() : super(const []);

  void addStay(AnywhereStay stay) {
    state = [stay, ...state];
  }
}
