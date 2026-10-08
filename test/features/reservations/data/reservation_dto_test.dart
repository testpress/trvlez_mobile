import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/reservations/data/models/reservation_dto.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

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
    'cancelled_at': null,
    'checked_in_at': null,
    'checked_out_at': null,
  };

  group('ReservationDto JSON Parsing & Serialization', () {
    test('deserializes complete backend payload to domain model', () {
      final dto = ReservationDto.fromJson(testReservationDtoJson);
      expect(dto.id, 'res-101');
      expect(dto.confirmationCode, 'TRV-12345678');
      expect(dto.status, 'confirmed');
      expect(dto.numberOfGuests, 2);
      expect(dto.totalAmount, 450.0);
      expect(dto.currencyCode, 'USD');
      expect(dto.rooms.length, 1);
      expect(dto.rooms.first['room_type_name'], 'Deluxe Ocean Suite');
      expect(dto.rooms.first['price_per_night'], 150.0);
      expect(dto.rooms.first['currency_code'], 'USD');
      expect(dto.rooms.first['number_of_nights'], 3);
      expect(dto.rooms.first['line_total'], 450.0);
      expect(dto.propertySummary['name'], 'Azure Coastal Resort');

      final domain = dto.toDomain();
      expect(domain.id, 'res-101');
      expect(domain.confirmationCode, 'TRV-12345678');
      expect(domain.status, ReservationStatus.confirmed);
      expect(domain.guestName, 'Alex Traveler');
      expect(domain.guestEmail, 'alex@example.com');
      expect(domain.guestPhone, '+15551234567');
      expect(domain.totalAmount, 450.0);
      expect(domain.currencyCode, 'USD');
      expect(domain.rooms.first.roomNumber, '302');
      expect(domain.rooms.first.roomTypeName, 'Deluxe Ocean Suite');
      expect(domain.rooms.first.pricePerNight, 150.0);
      expect(domain.rooms.first.currencyCode, 'USD');
      expect(domain.rooms.first.numberOfNights, 3);
      expect(domain.rooms.first.lineTotal, 450.0);
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

    test(
      'deserializes string-encoded total_amount and room snapshot line_total without error',
      () {
        final json = {
          'id': 'res-str',
          'confirmation_code': 'TRV-STR',
          'status': 'confirmed',
          'check_in_date': '2026-10-15T14:00:00Z',
          'check_out_date': '2026-10-18T11:00:00Z',
          'guest_name': 'String Price User',
          'total_amount': '6000.00',
          'currency_code': 'USD',
          'rooms': [
            {
              'id': 'room-1',
              'room_number': '101',
              'room_type_id': 'rt-1',
              'room_type_name': 'Villa',
              'price_per_night': '2000.0',
              'currency_code': 'USD',
              'number_of_nights': 3,
              'line_total': '6000.00',
            },
          ],
          'created_at': '2026-09-01T10:00:00Z',
        };

        final dto = ReservationDto.fromJson(json);
        final domain = dto.toDomain();

        expect(dto.totalAmount, 6000.0);
        expect(domain.totalAmount, 6000.0);
        expect(domain.rooms.first.pricePerNight, 2000.0);
        expect(domain.rooms.first.lineTotal, 6000.0);
      },
    );

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
}
