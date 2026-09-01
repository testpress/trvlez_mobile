import 'dart:typed_data';

/// The authentication protocol used to establish the secure session.
enum NfcAuthMethod { bac, pace, none }

/// Parsed biographical and document data from the passport chip's MRZ (DG1).
class NfcMrzData {
  final String documentNumber;
  final String documentCode;
  final String firstName;
  final String lastName;
  final String nationality;
  final String country;
  final String gender;
  final DateTime dateOfBirth;
  final DateTime dateOfExpiry;
  final String? optionalData;
  final String? optionalData2;

  const NfcMrzData({
    required this.documentNumber,
    required this.documentCode,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.country,
    required this.gender,
    required this.dateOfBirth,
    required this.dateOfExpiry,
    this.optionalData,
    this.optionalData2,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_number': documentNumber,
      'document_code': documentCode,
      'first_name': firstName,
      'last_name': lastName,
      'nationality': nationality,
      'country': country,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'date_of_expiry': dateOfExpiry.toIso8601String().split('T').first,
      if (optionalData != null) 'optional_data': optionalData,
      if (optionalData2 != null) 'optional_data_2': optionalData2,
    };
  }
}

/// Comprehensive result of a successful NFC passport read.
class NfcPassportResult {
  /// Base64 encoded raw bytes of Data Groups (e.g. 'dg1', 'dg2').
  final Map<String, String> rawDgBytesBase64;

  /// Base64 encoded EF.SOD (Document Security Object) for Passive Authentication.
  final String? sodBytesBase64;

  /// Base64 encoded EF.COM.
  final String? comBytesBase64;

  /// Base64 encoded EF.CardAccess (PACE parameters).
  final String? cardAccessBytesBase64;

  /// Parsed MRZ data from DG1.
  final NfcMrzData? parsedMrz;

  /// Extracted face image bytes from DG2 (usually JPEG or JP2000).
  final Uint8List? faceImageBytes;

  /// Base64 encoded Active Authentication signature (if DG15 was present).
  final String? activeAuthSignatureBase64;

  /// The authentication method used (BAC or PACE).
  final NfcAuthMethod authMethod;

  /// List of Data Group tags found in EF.COM (e.g., ['dg1', 'dg2', 'dg15']).
  final List<String> availableDataGroups;

  const NfcPassportResult({
    required this.rawDgBytesBase64,
    this.sodBytesBase64,
    this.comBytesBase64,
    this.cardAccessBytesBase64,
    this.parsedMrz,
    this.faceImageBytes,
    this.activeAuthSignatureBase64,
    required this.authMethod,
    required this.availableDataGroups,
  });

  /// Converts the result to a JSON payload suitable for backend verification.
  Map<String, dynamic> toJson() {
    return {
      'auth_method': authMethod.name.toUpperCase(),
      'raw_files': {
        if (cardAccessBytesBase64 != null) 'card_access': cardAccessBytesBase64,
        if (comBytesBase64 != null) 'com': comBytesBase64,
        if (sodBytesBase64 != null) 'sod': sodBytesBase64,
        ...rawDgBytesBase64,
      },
      if (parsedMrz != null) 'parsed_mrz': parsedMrz!.toJson(),
      if (activeAuthSignatureBase64 != null)
        'active_auth_signature': activeAuthSignatureBase64,
      'available_data_groups': availableDataGroups,
      'read_timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
