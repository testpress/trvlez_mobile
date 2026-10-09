import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';

class MrzExtractionResult {
  final bool success;
  final String? documentNumber;
  final String? dateOfBirth;
  final String? dateOfExpiry;
  final String? nationality;
  final String? issuingCountry;
  final String? firstName;
  final String? lastName;
  final String? sex;
  final String? errorMessage;

  MrzExtractionResult({
    required this.success,
    this.documentNumber,
    this.dateOfBirth,
    this.dateOfExpiry,
    this.nationality,
    this.issuingCountry,
    this.firstName,
    this.lastName,
    this.sex,
    this.errorMessage,
  });

  factory MrzExtractionResult.fromJson(Map<String, dynamic> json) {
    return MrzExtractionResult(
      success: (json['success'] as bool?) ?? false,
      documentNumber: json['document_number'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      dateOfExpiry: json['date_of_expiry'] as String?,
      nationality: json['nationality'] as String?,
      issuingCountry: json['issuing_country'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      sex: json['sex'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Builds the request payload for the confirm-mrz endpoint.
  ConfirmMrzPayload toConfirmPayload() {
    return ConfirmMrzPayload(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      passportNumber: documentNumber ?? '',
      nationality: nationality ?? '',
      dateOfBirth: dateOfBirth ?? '',
      dateOfExpiry: dateOfExpiry ?? '',
      sex: sex,
      issuingCountry: issuingCountry,
    );
  }
}
