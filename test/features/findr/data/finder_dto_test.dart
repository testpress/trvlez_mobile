import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';

void main() {
  group('FinderDto Tests', () {
    test('deserializes JSON payload into FinderDto and maps to domain entity', () {
      final json = {
        'id': 'f-12345',
        'user_id': 'u-67890',
        'status': 'active',
        'address_line_1': '10 Downing Street',
        'address_line_2': 'Flat 2',
        'city': 'London',
        'region': 'Greater London',
        'postal_code': 'SW1A 2AA',
        'residential_country_code': 'GB',
        'agreement_version': '1.0',
        'activated_at': '2026-05-01T12:00:00Z',
        'suspended_at': null,
        'suspension_ends_at': null,
        'verification_lapsed_at': null,
        'created_at': '2026-05-01T12:00:00Z',
        'updated_at': '2026-05-01T12:00:00Z',
      };

      final dto = FinderDto.fromJson(json);
      expect(dto.id, 'f-12345');
      expect(dto.userId, 'u-67890');
      expect(dto.status, 'active');
      expect(dto.addressLine1, '10 Downing Street');
      expect(dto.residentialCountryCode, 'GB');

      final domain = dto.toDomain();
      expect(domain.id, 'f-12345');
      expect(domain.userId, 'u-67890');
      expect(domain.status, FinderStatusType.active);
      expect(domain.isActive, isTrue);
      expect(domain.isSuspended, isFalse);
      expect(domain.address?.city, 'London');
      expect(domain.address?.postalCode, 'SW1A 2AA');
      expect(domain.address?.residentialCountryCode, 'GB');
      expect(domain.activatedAt, DateTime.parse('2026-05-01T12:00:00Z'));
    });

    test('deserializes suspended and terminal states correctly', () {
      final suspendedJson = {
        'id': 'f-999',
        'user_id': 'u-888',
        'status': 'suspended_temporary',
        'suspended_at': '2026-06-01T00:00:00Z',
        'suspension_ends_at': '2026-07-01T00:00:00Z',
        'created_at': '2026-05-01T00:00:00Z',
        'updated_at': '2026-06-01T00:00:00Z',
      };

      final suspendedDomain = FinderDto.fromJson(suspendedJson).toDomain();
      expect(suspendedDomain.status, FinderStatusType.suspendedTemporary);
      expect(suspendedDomain.isSuspended, isTrue);
      expect(suspendedDomain.isTerminated, isFalse);
      expect(suspendedDomain.suspensionEndsAt,
          DateTime.parse('2026-07-01T00:00:00Z'));

      final deactivatedJson = {
        'id': 'f-000',
        'user_id': 'u-111',
        'status': 'deactivated',
        'created_at': '2026-05-01T00:00:00Z',
        'updated_at': '2026-06-01T00:00:00Z',
      };

      final deactivatedDomain = FinderDto.fromJson(deactivatedJson).toDomain();
      expect(deactivatedDomain.status, FinderStatusType.deactivated);
      expect(deactivatedDomain.isTerminated, isTrue);
    });

    test('deserializes aggregated FinderStatusResponseDto', () {
      final json = {
        'finder': {
          'id': 'f-abc',
          'user_id': 'u-xyz',
          'status': 'active',
          'address_line_1': '221B Baker St',
          'city': 'London',
          'postal_code': 'NW1 6XE',
          'residential_country_code': 'GB',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        },
        'eligibility': {
          'is_eligible': true,
          'reason': 'eligible',
        },
        'reverification_required': true,
        'reverification_url': '/api/v1/traveler/verification/reverify',
      };

      final dto = FinderStatusResponseDto.fromJson(json);
      expect(dto.reverificationRequired, isTrue);
      expect(dto.reverificationUrl, '/api/v1/traveler/verification/reverify');

      final domain = dto.toDomain();
      expect(domain.hasActiveFinder, isTrue);
      expect(domain.reverificationRequired, isTrue);
      expect(domain.eligibility.reason, FinderEligibilityReason.eligible);
      expect(domain.finder?.address?.city, 'London');
    });

    test('serializes FinderActivationRequestDto to JSON correctly', () {
      const params = FinderActivationParams(
        addressLine1: '742 Evergreen Terrace',
        addressLine2: 'Apt 1',
        city: 'Springfield',
        region: 'Oregon',
        postalCode: '97477',
        residentialCountryCode: 'GB',
        agreementVersion: '1.0',
        agreementAccepted: true,
      );

      final dto = FinderActivationRequestDto.fromDomain(params);
      final json = dto.toJson();

      expect(json['address_line_1'], '742 Evergreen Terrace');
      expect(json['address_line_2'], 'Apt 1');
      expect(json['city'], 'Springfield');
      expect(json['region'], 'Oregon');
      expect(json['postal_code'], '97477');
      expect(json['residential_country_code'], 'GB');
      expect(json['agreement_version'], '1.0');
      expect(json['agreement_accepted'], isTrue);
    });

    test('serializes FinderProfileUpdateDto omitting nulls', () {
      const params = FinderProfileUpdateParams(
        city: 'Manchester',
        postalCode: 'M1 1AE',
        email: 'traveler@example.com',
      );

      final dto = FinderProfileUpdateDto.fromDomain(params);
      final json = dto.toJson();

      expect(json['city'], 'Manchester');
      expect(json['postal_code'], 'M1 1AE');
      expect(json['email'], 'traveler@example.com');
      expect(json.containsKey('address_line_1'), isFalse);
    });
  });
}
