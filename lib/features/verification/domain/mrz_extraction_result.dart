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
      success: json['success'] ?? false,
      documentNumber: json['document_number'],
      dateOfBirth: json['date_of_birth'],
      dateOfExpiry: json['date_of_expiry'],
      nationality: json['nationality'],
      issuingCountry: json['issuing_country'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      sex: json['sex'],
      errorMessage: json['error_message'],
    );
  }

  /// Builds the request payload for the confirm-mrz endpoint.
  Map<String, dynamic> toConfirmPayload() {
    return {
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'passport_number': documentNumber ?? '',
      'nationality': nationality ?? '',
      'date_of_birth': dateOfBirth ?? '',
      'date_of_expiry': dateOfExpiry ?? '',
      'sex': sex,
      'issuing_country': issuingCountry,
    };
  }
}
