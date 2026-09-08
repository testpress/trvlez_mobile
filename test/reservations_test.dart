import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_dto.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

// ─── Test Mocks ──────────────────────────────────────────────────

class MockReservationRemoteDataSource extends Fake
    implements ReservationRemoteDataSource {
  ReservationDto? reservationDtoToReturn;
  ReservationListResponseDto? listResponseToReturn;
  CheckInTokenDto? tokenDtoToReturn;
  Map<String, dynamic>? lastCreatedBody;
  String? lastFetchedId;
  String? lastCancelledId;
  String? lastTokenReservationId;
  bool shouldThrow = false;

  @override
  Future<ReservationDto> createReservation({
    required Map<String, dynamic> body,
  }) async {
    lastCreatedBody = body;
    if (shouldThrow) {
      throw Exception('Network error during creation');
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<ReservationListResponseDto> getReservations({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    if (shouldThrow) {
      throw Exception('Network error fetching reservations');
    }
    return listResponseToReturn ??
        ReservationListResponseDto(
          items: reservationDtoToReturn != null ? [reservationDtoToReturn!] : [],
          total: reservationDtoToReturn != null ? 1 : 0,
        );
  }

  @override
  Future<ReservationDto> getReservation(String id) async {
    lastFetchedId = id;
    if (shouldThrow) {
      throw Exception('Network error fetching reservation');
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<ReservationDto> cancelReservation(String id) async {
    lastCancelledId = id;
    if (shouldThrow) {
      throw Exception('Network error cancelling reservation');
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<CheckInTokenDto> generateCheckInToken(String reservationId) async {
    lastTokenReservationId = reservationId;
    if (shouldThrow) {
      throw Exception('Network error generating token');
    }
    return tokenDtoToReturn ??
        CheckInTokenDto(
          token: 'tok_test_1234567890',
          reservationId: reservationId,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        );
  }
}

class MockReservationRepository extends Fake implements ReservationRepository {
  List<Reservation> reservationsToReturn = [];
  Reservation? singleReservationToReturn;
  CheckInToken? tokenToReturn;
  bool shouldThrow = false;
  String? lastCancelledId;

  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    if (shouldThrow) throw Exception('Failed to get reservations');
    return reservationsToReturn;
  }

  @override
  Future<Reservation> getReservation(String id) async {
    if (shouldThrow) throw Exception('Failed to get reservation');
    return singleReservationToReturn!;
  }

  @override
  Future<Reservation> cancelReservation(String id) async {
    lastCancelledId = id;
    if (shouldThrow) throw Exception('Failed to cancel reservation');
    return singleReservationToReturn!;
  }

  @override
  Future<Reservation> createReservation({
    required String propertyId,
    required String checkInDate,
    required String checkOutDate,
    required String guestName,
    String? guestEmail,
    String? guestPhone,
    int numberOfGuests = 1,
    required List<String> roomTypeIds,
    String? specialRequests,
  }) async {
    if (shouldThrow) throw Exception('Failed to create reservation');
    return singleReservationToReturn!;
  }

  @override
  Future<CheckInToken> generateCheckInToken(String reservationId) async {
    if (shouldThrow) throw Exception('Failed to generate token');
    return tokenToReturn ??
        CheckInToken(
          token: 'tok_res_test',
          reservationId: reservationId,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );
  }
}

// ─── Test Main ───────────────────────────────────────────────────

void main() {
  final testReservationDtoJson = {
    'id': 'res-101',
    'confirmation_code': 'TRV-12345678',
    'status': 'confirmed',
    'form_status': 'completed',
    'check_in_date': '2026-10-15T14:00:00Z',
    'check_out_date': '2026-10-18T11:00:00Z',
    'guest_name': 'Alex Traveler',
    'guest_email': 'alex@example.com',
    'guest_phone': '+15551234567',
    'number_of_guests': 2,
    'rooms': [
      {
        'id': 'room-summary-1',
        'room_number': '302',
        'room_type_id': 'rt-deluxe',
      },
    ],
    'special_requests': 'Quiet room on upper floor',
    'property_summary': {
      'id': 'prop-azure-1',
      'name': 'Azure Coastal Resort',
      'city': 'Goa',
      'country_code': 'IN',
      'hero_image_url': 'https://example.com/azure.jpg',
      'requires_prearrival_form': false,
    },
    'created_at': '2026-09-01T10:00:00Z',
    'cancelled_at': null,
    'checked_in_at': null,
    'checked_out_at': null,
  };

  final testDomainReservation = Reservation(
    id: 'res-101',
    confirmationCode: 'TRV-12345678',
    status: ReservationStatus.confirmed,
    formStatus: 'completed',
    checkInDate: DateTime.utc(2026, 10, 15, 14, 0),
    checkOutDate: DateTime.utc(2026, 10, 18, 11, 0),
    guestName: 'Alex Traveler',
    guestEmail: 'alex@example.com',
    guestPhone: '+15551234567',
    numberOfGuests: 2,
    rooms: const [
      RoomSummary(
        id: 'room-summary-1',
        roomNumber: '302',
        roomTypeId: 'rt-deluxe',
      ),
    ],
    specialRequests: 'Quiet room on upper floor',
    propertySummary: const ReservationPropertySummary(
      id: 'prop-azure-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
      heroImageUrl: 'https://example.com/azure.jpg',
      requiresPrearrivalForm: false,
    ),
    createdAt: DateTime.utc(2026, 9, 1, 10, 0),
  );

  group('ReservationStatus Enum', () {
    test('fromString parses all standard backend statuses', () {
      expect(ReservationStatus.fromString('pending'), ReservationStatus.pending);
      expect(ReservationStatus.fromString('confirmed'), ReservationStatus.confirmed);
      expect(ReservationStatus.fromString('checked_in'), ReservationStatus.checkedIn);
      expect(ReservationStatus.fromString('checked_out'), ReservationStatus.checkedOut);
      expect(ReservationStatus.fromString('cancelled'), ReservationStatus.cancelled);
      expect(ReservationStatus.fromString('no_show'), ReservationStatus.noShow);
      expect(ReservationStatus.fromString('unknown_status'), ReservationStatus.pending);
    });

    test('displayLabel formats status correctly for UI display', () {
      expect(ReservationStatus.pending.displayLabel, 'Pending');
      expect(ReservationStatus.confirmed.displayLabel, 'Confirmed');
      expect(ReservationStatus.checkedIn.displayLabel, 'Checked In');
      expect(ReservationStatus.checkedOut.displayLabel, 'Checked Out');
      expect(ReservationStatus.cancelled.displayLabel, 'Cancelled');
      expect(ReservationStatus.noShow.displayLabel, 'No Show');
    });

    test('lifecycle helpers categorize reservation status correctly', () {
      expect(ReservationStatus.pending.isUpcoming, isTrue);
      expect(ReservationStatus.confirmed.isUpcoming, isTrue);
      expect(ReservationStatus.checkedIn.isUpcoming, isFalse);

      expect(ReservationStatus.checkedIn.isCompleted, isTrue);
      expect(ReservationStatus.checkedOut.isCompleted, isTrue);
      expect(ReservationStatus.confirmed.isCompleted, isFalse);

      expect(ReservationStatus.cancelled.isCancelled, isTrue);
      expect(ReservationStatus.noShow.isCancelled, isTrue);
      expect(ReservationStatus.confirmed.isCancelled, isFalse);
    });

    test('canGenerateQr is true only for confirmed reservations', () {
      expect(ReservationStatus.confirmed.canGenerateQr, isTrue);
      expect(ReservationStatus.pending.canGenerateQr, isFalse);
      expect(ReservationStatus.checkedIn.canGenerateQr, isFalse);
      expect(ReservationStatus.cancelled.canGenerateQr, isFalse);
    });

    test('canCancel is true only for upcoming reservations', () {
      expect(ReservationStatus.pending.canCancel, isTrue);
      expect(ReservationStatus.confirmed.canCancel, isTrue);
      expect(ReservationStatus.checkedIn.canCancel, isFalse);
      expect(ReservationStatus.cancelled.canCancel, isFalse);
    });
  });

  group('ReservationDto JSON Parsing & Serialization', () {
    test('deserializes complete backend payload to domain model', () {
      final dto = ReservationDto.fromJson(testReservationDtoJson);
      expect(dto.id, 'res-101');
      expect(dto.confirmationCode, 'TRV-12345678');
      expect(dto.status, 'confirmed');
      expect(dto.numberOfGuests, 2);
      expect(dto.rooms.length, 1);
      expect(dto.propertySummary['name'], 'Azure Coastal Resort');

      final domain = dto.toDomain();
      expect(domain.id, 'res-101');
      expect(domain.confirmationCode, 'TRV-12345678');
      expect(domain.status, ReservationStatus.confirmed);
      expect(domain.guestName, 'Alex Traveler');
      expect(domain.guestEmail, 'alex@example.com');
      expect(domain.guestPhone, '+15551234567');
      expect(domain.rooms.first.roomNumber, '302');
      expect(domain.propertySummary.name, 'Azure Coastal Resort');
      expect(domain.propertySummary.locationString, 'Goa, IN');
      expect(domain.nights, 3);
    });

    test('handles optional and missing fields gracefully', () {
      final minimalJson = {
        'id': 'res-minimal',
        'confirmation_code': 'TRV-MINIMAL',
        'status': 'pending',
        'check_in_date': '2026-10-01T14:00:00Z',
        'check_out_date': '2026-10-02T11:00:00Z',
        'guest_name': 'Minimal User',
        'created_at': '2026-09-01T10:00:00Z',
      };

      final dto = ReservationDto.fromJson(minimalJson);
      final domain = dto.toDomain();

      expect(domain.id, 'res-minimal');
      expect(domain.guestEmail, isNull);
      expect(domain.guestPhone, isNull);
      expect(domain.specialRequests, isNull);
      expect(domain.numberOfGuests, 1);
      expect(domain.rooms, isEmpty);
      expect(domain.propertySummary.name, '');
      expect(domain.propertySummary.locationString, '');
      expect(domain.nights, 1);
    });

    test('deserializes ReservationListResponseDto correctly', () {
      final listJson = {
        'data': [testReservationDtoJson],
        'count': 1,
      };

      final listDto = ReservationListResponseDto.fromJson(listJson);
      expect(listDto.total, 1);
      expect(listDto.items.length, 1);
      expect(listDto.items.first.confirmationCode, 'TRV-12345678');
    });

    test('deserializes CheckInTokenDto correctly', () {
      final tokenJson = {
        'token': 'tok_url_safe_64_character_string',
        'reservation_id': 'res-101',
        'expires_at': '2026-08-15T14:10:00Z',
      };

      final tokenDto = CheckInTokenDto.fromJson(tokenJson);
      final domainToken = tokenDto.toDomain();

      expect(domainToken.token, 'tok_url_safe_64_character_string');
      expect(domainToken.reservationId, 'res-101');
      expect(domainToken.expiresAt, DateTime.parse('2026-08-15T14:10:00Z'));
      expect(domainToken.isValid, isFalse); // past date
    });
  });

  group('ReservationRepository Unit Tests', () {
    late MockReservationRemoteDataSource mockRemote;
    late ReservationRepository repository;

    setUp(() {
      mockRemote = MockReservationRemoteDataSource();
      mockRemote.reservationDtoToReturn = ReservationDto.fromJson(testReservationDtoJson);
      repository = ReservationRepository(remoteDataSource: mockRemote);
    });

    test('createReservation constructs payload and returns domain model', () async {
      final res = await repository.createReservation(
        propertyId: 'prop-azure-1',
        checkInDate: '2026-10-15T14:00:00Z',
        checkOutDate: '2026-10-18T11:00:00Z',
        guestName: 'Alex Traveler',
        guestEmail: 'alex@example.com',
        guestPhone: '+15551234567',
        numberOfGuests: 2,
        roomTypeIds: ['rt-deluxe'],
        specialRequests: 'Quiet room',
      );

      expect(res.id, 'res-101');
      expect(mockRemote.lastCreatedBody?['property_id'], 'prop-azure-1');
      expect(mockRemote.lastCreatedBody?['guest_name'], 'Alex Traveler');
      expect(mockRemote.lastCreatedBody?['number_of_guests'], 2);
      expect(mockRemote.lastCreatedBody?['room_type_ids'], ['rt-deluxe']);
    });

    test('getReservations returns mapped domain list', () async {
      final list = await repository.getReservations();
      expect(list.length, 1);
      expect(list.first.confirmationCode, 'TRV-12345678');
    });

    test('getReservation fetches single reservation by ID', () async {
      final res = await repository.getReservation('res-101');
      expect(res.id, 'res-101');
      expect(mockRemote.lastFetchedId, 'res-101');
    });

    test('cancelReservation calls remote and returns updated reservation', () async {
      final res = await repository.cancelReservation('res-101');
      expect(res.id, 'res-101');
      expect(mockRemote.lastCancelledId, 'res-101');
    });

    test('generateCheckInToken returns mapped check-in token', () async {
      final token = await repository.generateCheckInToken('res-101');
      expect(token.reservationId, 'res-101');
      expect(token.isValid, isTrue);
      expect(mockRemote.lastTokenReservationId, 'res-101');
    });
  });

  group('ReservationListNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [testDomainReservation];
      mockRepo.singleReservationToReturn = testDomainReservation;
    });

    test('initial build loads reservations from repository', () async {
      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(reservationListProvider.future);
      expect(state.length, 1);
      expect(state.first.id, 'res-101');
    });

    test('addReservation prepends new reservation to state list', () async {
      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reservationListProvider.future);

      final newRes = testDomainReservation.copyWith(
        id: 'res-new-202',
        confirmationCode: 'TRV-99998888',
      );

      container.read(reservationListProvider.notifier).addReservation(newRes);

      final current = container.read(reservationListProvider).value!;
      expect(current.length, 2);
      expect(current.first.id, 'res-new-202');
      expect(current.last.id, 'res-101');
    });

    test('cancelReservation updates reservation status in list', () async {
      final cancelledRes = testDomainReservation.copyWith(
        status: ReservationStatus.cancelled,
      );
      mockRepo.singleReservationToReturn = cancelledRes;

      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reservationListProvider.future);

      final success = await container
          .read(reservationListProvider.notifier)
          .cancelReservation('res-101');

      expect(success, isTrue);
      final current = container.read(reservationListProvider).value!;
      expect(current.first.status, ReservationStatus.cancelled);
    });
  });

  group('CreateReservationNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.singleReservationToReturn = testDomainReservation;
    });

    test('createReservation creates reservation and prepends to list', () async {
      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final created = await container
          .read(createReservationProvider.notifier)
          .createReservation(
            propertyId: 'prop-azure-1',
            checkInDate: '2026-10-15T14:00:00Z',
            checkOutDate: '2026-10-18T11:00:00Z',
            guestName: 'Alex Traveler',
            roomTypeIds: ['rt-deluxe'],
          );

      expect(created, isNotNull);
      expect(created?.id, 'res-101');

      final list = container.read(reservationListProvider).value;
      expect(list, isNotNull);
      expect(list?.first.id, 'res-101');
    });

    test('createReservation sets error state on repository failure', () async {
      mockRepo.shouldThrow = true;

      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final created = await container
          .read(createReservationProvider.notifier)
          .createReservation(
            propertyId: 'prop-azure-1',
            checkInDate: '2026-10-15T14:00:00Z',
            checkOutDate: '2026-10-18T11:00:00Z',
            guestName: 'Alex Traveler',
            roomTypeIds: ['rt-deluxe'],
          );

      expect(created, isNull);
      expect(container.read(createReservationProvider).hasError, isTrue);
    });
  });

  group('ReservationDetailScreen Widget Tests', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.singleReservationToReturn = testDomainReservation;
    });

    testWidgets('renders stay details, guest info, and confirmation code',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(
              reservation: testDomainReservation,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reservation Details'), findsOneWidget);
      expect(find.text('Azure Coastal Resort'), findsOneWidget);
      expect(find.text('TRV-12345678'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Alex Traveler'), findsOneWidget);
      expect(find.text('302'), findsOneWidget);
      expect(find.text('Generate QR Code'), findsOneWidget);
    });

    testWidgets(
        'renders KYC notice and verification required button when traveler is unverified',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(false),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.profilePending,
            ),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(
              reservation: testDomainReservation,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Identity Verification Required'), findsOneWidget);
      expect(find.text('Verify Now'), findsOneWidget);
      expect(find.text('Check-in QR (Verification Required)'), findsOneWidget);
    });

    testWidgets('supports deep linking by ID when reservation is null',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(
              reservationId: 'res-101',
              repository: mockRepo,
            ),
          ),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Azure Coastal Resort'), findsOneWidget);
      expect(find.text('TRV-12345678'), findsOneWidget);
    });

    testWidgets('shows error state with retry button when deep link fetch fails',
        (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(
              reservationId: 'res-fail',
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load reservation'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Retry after fixing error
      mockRepo.shouldThrow = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Azure Coastal Resort'), findsOneWidget);
    });

    testWidgets('shows error snackbar when reservation cancellation fails',
        (tester) async {
      mockRepo.singleReservationToReturn = testDomainReservation;
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: ReservationDetailScreen(
              reservation: testDomainReservation,
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Cancel Reservation
      await tester.ensureVisible(find.text('Cancel Reservation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Reservation'));
      await tester.pumpAndSettle();

      // Dialog confirms
      expect(find.text('Cancel Reservation?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel Reservation'));
      await tester.pumpAndSettle();

      // SnackBar shows failure message
      expect(
        find.textContaining('Failed to cancel reservation'),
        findsOneWidget,
      );
    });
  });

  group('CreateReservationScreen Widget Tests', () {
    final testProperty = Property(
      id: 'prop-azure-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
      shortDescription: 'A serene beachside escape',
      longDescription: 'Experience luxury and tranquility with panoramic ocean views.',
      heroImageUrl: 'https://example.com/azure.jpg',
      roomTypes: const [
        RoomType(
          id: 'rt-deluxe',
          name: 'Deluxe Ocean Suite',
          maxOccupancy: 2,
          maxAdults: 2,
          maxChildren: 0,
          description: 'Spacious ocean-view room with king bed',
        ),
      ],
    );

    testWidgets('renders property title, room type, and disabled button on mount',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateReservationScreen(property: testProperty),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Your Stay'), findsOneWidget);
      expect(find.text('Azure Coastal Resort'), findsOneWidget);
      expect(find.text('Deluxe Ocean Suite'), findsOneWidget);
      expect(find.text('Confirm Reservation'), findsOneWidget);

      // Button is disabled because dates and guest name are not yet provided
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm Reservation'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'enforces occupancy limit and strictly disables submission button when guests exceed capacity',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateReservationScreen(property: testProperty),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter guest name
      await tester.enterText(find.byType(TextField).first, 'John Traveler');
      await tester.pumpAndSettle();

      // Initial state: 1 guest, 1 room (maxOccupancy = 2)
      // Increment guests to 2: still valid
      final guestIncrement = find.byIcon(Icons.add).first;
      await tester.tap(guestIncrement);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Selected rooms accommodate up to'),
        findsNothing,
      );

      // Increment guests to 3: exceeds maxOccupancy 2!
      await tester.tap(guestIncrement);
      await tester.pumpAndSettle();

      // Occupancy warning must appear and button must remain disabled
      expect(
        find.textContaining('Selected rooms accommodate up to 2 guests'),
        findsOneWidget,
      );
      var button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm Reservation'),
      );
      expect(button.onPressed, isNull);

      // Add another room: capacity becomes 4, warning disappears
      final roomIncrement = find.byIcon(Icons.add).last;
      await tester.tap(roomIncrement);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Selected rooms accommodate up to'),
        findsNothing,
      );
    });

    testWidgets('pre-selects specified room type when initialRoomTypeId is passed',
        (tester) async {
      final multiRoomProperty = testProperty.copyWith(
        roomTypes: const [
          RoomType(
            id: 'rt-std',
            name: 'Standard Suite',
            maxOccupancy: 2,
            maxAdults: 2,
            maxChildren: 0,
            description: 'Standard room',
          ),
          RoomType(
            id: 'rt-ocean',
            name: 'Oceanfront Penthouse',
            maxOccupancy: 4,
            maxAdults: 4,
            maxChildren: 2,
            description: 'Penthouse suite',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateReservationScreen(
              property: multiRoomProperty,
              initialRoomTypeId: 'rt-ocean',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oceanfront Penthouse'), findsOneWidget);
      expect(find.text('Standard Suite'), findsOneWidget);
    });
  });

  group('MyTripsScreen Widget Tests', () {
    testWidgets(
        'renders Explore Properties CTA button when upcoming trips list is empty',
        (tester) async {
      final mockRemoteDataSource = MockReservationRemoteDataSource();
      mockRemoteDataSource.listResponseToReturn =
          const ReservationListResponseDto(
        items: [],
        total: 0,
      );
      final repository = ReservationRepository(
        remoteDataSource: mockRemoteDataSource,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: MyTripsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No upcoming trips'), findsOneWidget);
      expect(find.text('Explore Properties'), findsOneWidget);
    });
  });
}
