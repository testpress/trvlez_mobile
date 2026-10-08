import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/models/reservation_dto.dart';
import 'package:trvlez_mobile/features/reservations/data/repositories/reservation_repository_impl.dart';

class MockReservationRemoteDataSource extends Fake
    implements ReservationRemoteDataSource {
  ReservationDto? reservationDtoToReturn;
  ReservationListResponseDto? listResponseToReturn;
  CheckInTokenDto? tokenDtoToReturn;
  Map<String, dynamic>? lastCreatedBody;
  String? lastFetchedId;
  String? lastCancelledId;
  String? lastTokenReservationId;
  DioException? exceptionToThrow;

  @override
  Future<ReservationDto> createReservation({
    required Map<String, dynamic> body,
  }) async {
    lastCreatedBody = body;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<ReservationListResponseDto> getReservations({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return listResponseToReturn ??
        ReservationListResponseDto(
          items:
              reservationDtoToReturn != null ? [reservationDtoToReturn!] : [],
          total: reservationDtoToReturn != null ? 1 : 0,
        );
  }

  @override
  Future<ReservationDto> getReservation(String id) async {
    lastFetchedId = id;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<ReservationDto> cancelReservation(String id) async {
    lastCancelledId = id;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return reservationDtoToReturn!;
  }

  @override
  Future<CheckInTokenDto> generateCheckInToken(String reservationId) async {
    lastTokenReservationId = reservationId;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return tokenDtoToReturn ??
        CheckInTokenDto(
          token: 'mock-qr-token',
          reservationId: reservationId,
          expiresAt:
              DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        );
  }
}

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
    'total_amount': 450.00,
    'currency_code': 'USD',
    'rooms': [
      {
        'id': 'room-summary-1',
        'room_number': '302',
        'room_type_id': 'rt-deluxe',
        'room_type_name': 'Deluxe Ocean Suite',
        'price_per_night': 150.00,
        'currency_code': 'USD',
        'number_of_nights': 3,
        'line_total': 450.00,
      },
    ],
    'special_requests': 'Quiet room on upper floor',
    'property_summary': {
      'id': 'prop-azure-1',
      'name': 'Azure Coastal Resort',
      'city': 'Goa',
      'country_code': 'IN',
      'hero_image_url': 'https://example.com/azure.jpg',
      'currency_code': 'USD',
      'requires_prearrival_form': false,
    },
    'created_at': '2026-09-01T10:00:00Z',
  };

  group('ReservationRepositoryImpl Unit Tests', () {
    late MockReservationRemoteDataSource mockRemote;
    late ReservationRepositoryImpl repository;

    setUp(() {
      mockRemote = MockReservationRemoteDataSource();
      mockRemote.reservationDtoToReturn = ReservationDto.fromJson(
        testReservationDtoJson,
      );
      repository = ReservationRepositoryImpl(remoteDataSource: mockRemote);
    });

    test(
      'createReservation constructs payload and returns domain model',
      () async {
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
      },
    );

    test('createReservation maps DioException into AppException', () async {
      mockRemote.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/traveler/reservations'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => repository.createReservation(
          propertyId: 'prop-1',
          checkInDate: '2026-10-15T14:00:00Z',
          checkOutDate: '2026-10-18T11:00:00Z',
          guestName: 'Alex',
          roomTypeIds: ['rt-1'],
        ),
        throwsA(isA<NetworkException>()),
      );
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
}
