import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/data/dto/confirm_mrz_dto.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';

void main() {
  group('ConfirmMrzPayload', () {
    const payload = ConfirmMrzPayload(
      firstName: 'JOHN',
      lastName: 'DOE',
      passportNumber: 'P12345678',
      nationality: 'USA',
      dateOfBirth: '1990-01-01',
      dateOfExpiry: '2030-01-01',
      sex: 'M',
      issuingCountry: 'USA',
    );

    test('serializes to JSON correctly', () {
      final json = payload.toJson();

      expect(json['first_name'], 'JOHN');
      expect(json['last_name'], 'DOE');
      expect(json['passport_number'], 'P12345678');
      expect(json['nationality'], 'USA');
      expect(json['date_of_birth'], '1990-01-01');
      expect(json['date_of_expiry'], '2030-01-01');
      expect(json['sex'], 'M');
      expect(json['issuing_country'], 'USA');
    });

    test('omits optional fields in JSON when null', () {
      const minimalPayload = ConfirmMrzPayload(
        firstName: 'JANE',
        lastName: 'DOE',
        passportNumber: 'P87654321',
        nationality: 'GBR',
        dateOfBirth: '1992-05-15',
        dateOfExpiry: '2032-05-15',
      );

      final json = minimalPayload.toJson();
      expect(json.containsKey('sex'), isFalse);
      expect(json.containsKey('issuing_country'), isFalse);
    });

    test('supports value equality and hashCode', () {
      const identicalPayload = ConfirmMrzPayload(
        firstName: 'JOHN',
        lastName: 'DOE',
        passportNumber: 'P12345678',
        nationality: 'USA',
        dateOfBirth: '1990-01-01',
        dateOfExpiry: '2030-01-01',
        sex: 'M',
        issuingCountry: 'USA',
      );

      expect(payload, equals(identicalPayload));
      expect(payload.hashCode, equals(identicalPayload.hashCode));
    });

    test('ConfirmMrzRequestDto.fromDomain maps correctly', () {
      final dto = ConfirmMrzRequestDto.fromDomain(payload);
      final json = dto.toJson();

      expect(json['first_name'], 'JOHN');
      expect(json['last_name'], 'DOE');
      expect(json['passport_number'], 'P12345678');
      expect(json['nationality'], 'USA');
      expect(json['date_of_birth'], '1990-01-01');
      expect(json['date_of_expiry'], '2030-01-01');
      expect(json['sex'], 'M');
      expect(json['issuing_country'], 'USA');
    });
  });
}
