import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';

/// DTO for serializing MRZ confirmation payload to `/traveler/verification/confirm-mrz`.
class ConfirmMrzRequestDto {
  final String firstName;
  final String lastName;
  final String passportNumber;
  final String nationality;
  final String dateOfBirth;
  final String dateOfExpiry;
  final String? sex;
  final String? issuingCountry;

  const ConfirmMrzRequestDto({
    required this.firstName,
    required this.lastName,
    required this.passportNumber,
    required this.nationality,
    required this.dateOfBirth,
    required this.dateOfExpiry,
    this.sex,
    this.issuingCountry,
  });

  factory ConfirmMrzRequestDto.fromDomain(ConfirmMrzPayload payload) {
    return ConfirmMrzRequestDto(
      firstName: payload.firstName,
      lastName: payload.lastName,
      passportNumber: payload.passportNumber,
      nationality: payload.nationality,
      dateOfBirth: payload.dateOfBirth,
      dateOfExpiry: payload.dateOfExpiry,
      sex: payload.sex,
      issuingCountry: payload.issuingCountry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'passport_number': passportNumber,
      'nationality': nationality,
      'date_of_birth': dateOfBirth,
      'date_of_expiry': dateOfExpiry,
      if (sex != null) 'sex': sex,
      if (issuingCountry != null) 'issuing_country': issuingCountry,
    };
  }
}
