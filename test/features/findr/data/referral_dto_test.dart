import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/findr/data/models/referral_dto.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';

void main() {
  group('Referral DTO Tests', () {
    test(
      'HotelReferralDto.fromJson parses full payload and maps to domain',
      () {
        final json = {
          'id': 'ref-123',
          'finder_id': 'f-456',
          'status': 'converted',
          'hotel_name': 'Grand Hotel Riviera',
          'target_email': 'gm@grandriviera.com',
          'target_phone': '+39 081 123456',
          'street_address': 'Via Marina 10',
          'city': 'Sorrento',
          'postal_code': '80067',
          'country_code': 'IT',
          'personal_note': 'Met GM during holiday',
          'created_at': '2026-10-15T12:00:00Z',
        };

        final dto = HotelReferralDto.fromJson(json);
        expect(dto.id, 'ref-123');
        expect(dto.hotelName, 'Grand Hotel Riviera');

        final domain = dto.toDomain();
        expect(domain.id, 'ref-123');
        expect(domain.hotelName, 'Grand Hotel Riviera');
        expect(domain.isLive, isTrue);
        expect(domain.statusLabel, 'Joined');
        expect(domain.state, FindrRecommendationState.confirmed);
        expect(domain.location, 'Sorrento, IT');
        expect(domain.fullAddress, 'Via Marina 10, Sorrento, 80067, IT');
      },
    );

    test('HotelReferralDto maps outreach statuses correctly', () {
      final statuses = {
        'introduction_sent': ('Invited', FindrRecommendationState.awaiting),
        'follow_up_call_due': (
          'Follow-up due',
          FindrRecommendationState.awaiting,
        ),
        'second_email_available': (
          'Follow-up ready',
          FindrRecommendationState.awaiting,
        ),
        'second_email_sent': (
          'Follow-up sent',
          FindrRecommendationState.awaiting,
        ),
        'final_call_due': ('Final call due', FindrRecommendationState.awaiting),
        'outreach_complete': (
          'Outreach complete',
          FindrRecommendationState.awaiting,
        ),
        'onboarding_started': (
          'Onboarding started',
          FindrRecommendationState.awaiting,
        ),
        'declined': ('Declined', FindrRecommendationState.declined),
        'expired': ('Expired', FindrRecommendationState.declined),
      };

      for (final entry in statuses.entries) {
        final dto = HotelReferralDto.fromJson({
          'id': '1',
          'finder_id': '2',
          'status': entry.key,
          'hotel_name': 'Hotel Test',
          'created_at': '2026-10-15T12:00:00Z',
        });
        final domain = dto.toDomain();
        expect(domain.statusLabel, entry.value.$1);
        expect(domain.state, entry.value.$2);
      }
    });

    test('TravelerShareLinkDto maps to domain accurately', () {
      final json = {
        'share_code': 'TRV-FIND-ABC123',
        'share_url': 'https://app.trvlez.com/r/TRV-FIND-ABC123',
      };

      final dto = TravelerShareLinkDto.fromJson(json);
      final domain = dto.toDomain();

      expect(domain.shareCode, 'TRV-FIND-ABC123');
      expect(domain.shareUrl, 'https://app.trvlez.com/r/TRV-FIND-ABC123');
    });

    test('HotelReferralCreateRequestDto formats JSON correctly', () {
      const params = HotelReferralCreateParams(
        hotelName: '  Alpine Palace  ',
        streetAddress: 'Hauptstrasse 1',
        city: 'Interlaken',
        postalCode: '3800',
        countryCode: 'ch',
        targetEmail: '  gm@alpinepalace.ch  ',
        targetPhone: '+41 33 123 45 67',
        personalNote: 'Great property',
      );

      final dto = HotelReferralCreateRequestDto.fromDomain(params);
      final json = dto.toJson();

      expect(json['hotel_name'], 'Alpine Palace');
      expect(json['country_code'], 'CH');
      expect(json['target_email'], 'gm@alpinepalace.ch');
      expect(json['target_phone'], '+41 33 123 45 67');
      expect(json['personal_note'], 'Great property');
    });

    test('HotelReferralsListResponseDto parses list properly', () {
      final json = {
        'items': [
          {
            'id': 'ref-1',
            'finder_id': 'f-1',
            'status': 'introduction_sent',
            'hotel_name': 'Hotel One',
            'created_at': '2026-10-01T10:00:00Z',
          },
          {
            'id': 'ref-2',
            'finder_id': 'f-1',
            'status': 'converted',
            'hotel_name': 'Hotel Two',
            'created_at': '2026-10-02T10:00:00Z',
          },
        ],
        'count': 2,
      };

      final listDto = HotelReferralsListResponseDto.fromJson(json);
      expect(listDto.count, 2);
      expect(listDto.items.length, 2);
      expect(listDto.items[0].hotelName, 'Hotel One');
      expect(listDto.items[1].hotelName, 'Hotel Two');
    });
  });
}
