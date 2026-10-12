import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/profile/data/dto/profile_dto.dart';

void main() {
  group('ProfileDto Tests', () {
    test(
      'deserializes JSON payload into ProfileDto and converts to domain',
      () {
        final json = {
          'id': 'prof-dto-1',
          'phone': '+1234567890',
          'nationality': 'Spain',
          'gender': 'female',
          'date_of_birth': '1992-04-12',
          'passport_number': 'ESP998877',
          'passport_expiry': '2032-04-12',
          'onboarding_step': 'profile_pending',
        };

        final dto = ProfileDto.fromJson(json);
        expect(dto.id, 'prof-dto-1');
        expect(dto.phone, '+1234567890');
        expect(dto.nationality, 'Spain');
        expect(dto.gender, 'female');
        expect(dto.dateOfBirth, '1992-04-12');
        expect(dto.passportNumber, 'ESP998877');
        expect(dto.passportExpiry, '2032-04-12');
        expect(dto.onboardingStep, 'profile_pending');

        final domain = dto.toDomain();
        expect(domain.id, 'prof-dto-1');
        expect(domain.phone, '+1234567890');
        expect(domain.nationality, 'Spain');
        expect(domain.gender, 'female');
        expect(domain.dateOfBirth, DateTime.parse('1992-04-12'));
        expect(domain.passportNumber, 'ESP998877');
        expect(domain.passportExpiry, DateTime.parse('2032-04-12'));
        expect(domain.onboardingStep, 'profile_pending');
      },
    );

    test('serializes ProfileDto to JSON correctly', () {
      const dto = ProfileDto(
        id: 'prof-dto-2',
        phone: '+98765',
        nationality: 'France',
        gender: 'other',
        dateOfBirth: '1988-11-20',
        passportNumber: 'FRA123',
        passportExpiry: '2028-11-20',
        onboardingStep: 'document_scan',
      );

      final json = dto.toJson();
      expect(json['id'], 'prof-dto-2');
      expect(json['phone'], '+98765');
      expect(json['nationality'], 'France');
      expect(json['gender'], 'other');
      expect(json['date_of_birth'], '1988-11-20');
      expect(json['passport_number'], 'FRA123');
      expect(json['passport_expiry'], '2028-11-20');
      expect(json['onboarding_step'], 'document_scan');
    });
  });
}
