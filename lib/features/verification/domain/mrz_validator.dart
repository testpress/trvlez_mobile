class MrzValidator {
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Try standard parse first (handles YYYY-MM-DD)
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Validates extracted MRZ data and returns parsed dates.
  /// Returns null if any required data is missing or invalid.
  static ({String documentNumber, DateTime dateOfBirth, DateTime dateOfExpiry})? validate({
    required String? documentNumber,
    required String? dateOfBirthStr,
    required String? dateOfExpiryStr,
  }) {
    if (documentNumber == null || documentNumber.isEmpty) return null;

    final dob = _parseDate(dateOfBirthStr);
    final doe = _parseDate(dateOfExpiryStr);

    if (dob != null && doe != null) {
      return (
        documentNumber: documentNumber,
        dateOfBirth: dob,
        dateOfExpiry: doe,
      );
    }
    
    return null;
  }
}
