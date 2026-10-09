/// Domain payload representing verified MRZ passport data to confirm and persist.
class ConfirmMrzPayload {
  final String firstName;
  final String lastName;
  final String passportNumber;
  final String nationality;
  final String dateOfBirth;
  final String dateOfExpiry;
  final String? sex;
  final String? issuingCountry;

  const ConfirmMrzPayload({
    required this.firstName,
    required this.lastName,
    required this.passportNumber,
    required this.nationality,
    required this.dateOfBirth,
    required this.dateOfExpiry,
    this.sex,
    this.issuingCountry,
  });

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfirmMrzPayload &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.passportNumber == passportNumber &&
        other.nationality == nationality &&
        other.dateOfBirth == dateOfBirth &&
        other.dateOfExpiry == dateOfExpiry &&
        other.sex == sex &&
        other.issuingCountry == issuingCountry;
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    lastName,
    passportNumber,
    nationality,
    dateOfBirth,
    dateOfExpiry,
    sex,
    issuingCountry,
  );
}
