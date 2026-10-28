import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';

/// Data Transfer Object representing a Finder identity returned by the backend.
class FinderDto {
  const FinderDto({
    required this.id,
    required this.userId,
    required this.status,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.region,
    this.postalCode,
    this.residentialCountryCode,
    this.agreementVersion,
    this.activatedAt,
    this.suspendedAt,
    this.suspensionEndsAt,
    this.verificationLapsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinderDto.fromJson(Map<String, dynamic> json) {
    return FinderDto(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      addressLine1: json['address_line_1'] as String?,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      residentialCountryCode: json['residential_country_code'] as String?,
      agreementVersion: json['agreement_version'] as String?,
      activatedAt: _parseDateTime(json['activated_at'] as String?),
      suspendedAt: _parseDateTime(json['suspended_at'] as String?),
      suspensionEndsAt: _parseDateTime(json['suspension_ends_at'] as String?),
      verificationLapsedAt:
          _parseDateTime(json['verification_lapsed_at'] as String?),
      createdAt: _parseDateTime(json['created_at'] as String?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: _parseDateTime(json['updated_at'] as String?) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String id;
  final String userId;
  final String status;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? residentialCountryCode;
  final String? agreementVersion;
  final DateTime? activatedAt;
  final DateTime? suspendedAt;
  final DateTime? suspensionEndsAt;
  final DateTime? verificationLapsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  FinderIdentity toDomain() {
    FinderAddress? address;
    final line1 = addressLine1;
    final cityName = city;
    final postCode = postalCode;
    final country = residentialCountryCode;

    if (line1 != null &&
        line1.isNotEmpty &&
        cityName != null &&
        cityName.isNotEmpty &&
        postCode != null &&
        postCode.isNotEmpty &&
        country != null &&
        country.isNotEmpty) {
      address = FinderAddress(
        addressLine1: line1,
        addressLine2: addressLine2,
        city: cityName,
        region: region,
        postalCode: postCode,
        residentialCountryCode: country,
      );
    }

    return FinderIdentity(
      id: id,
      userId: userId,
      status: FinderStatusType.fromString(status),
      address: address,
      agreementVersion: agreementVersion,
      activatedAt: activatedAt,
      suspendedAt: suspendedAt,
      suspensionEndsAt: suspensionEndsAt,
      verificationLapsedAt: verificationLapsedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Data Transfer Object representing the backend eligibility evaluation.
class FinderEligibilityDto {
  const FinderEligibilityDto({
    required this.isEligible,
    required this.reason,
  });

  factory FinderEligibilityDto.fromJson(Map<String, dynamic> json) {
    return FinderEligibilityDto(
      isEligible: json['is_eligible'] as bool? ?? false,
      reason: json['reason'] as String? ?? 'terminal_status',
    );
  }

  final bool isEligible;
  final String reason;

  FinderEligibility toDomain() {
    return FinderEligibility(
      isEligible: isEligible,
      reason: FinderEligibilityReason.fromString(reason),
    );
  }
}

/// Data Transfer Object for the aggregated Finder status endpoint response.
class FinderStatusResponseDto {
  const FinderStatusResponseDto({
    this.finder,
    required this.eligibility,
    required this.reverificationRequired,
    this.reverificationUrl,
  });

  factory FinderStatusResponseDto.fromJson(Map<String, dynamic> json) {
    final finderRaw = json['finder'];
    final eligibilityRaw = json['eligibility'];

    return FinderStatusResponseDto(
      finder: finderRaw is Map<String, dynamic>
          ? FinderDto.fromJson(finderRaw)
          : null,
      eligibility: eligibilityRaw is Map<String, dynamic>
          ? FinderEligibilityDto.fromJson(eligibilityRaw)
          : const FinderEligibilityDto(
              isEligible: false,
              reason: 'terminal_status',
            ),
      reverificationRequired:
          json['reverification_required'] as bool? ?? false,
      reverificationUrl: json['reverification_url'] as String?,
    );
  }

  final FinderDto? finder;
  final FinderEligibilityDto eligibility;
  final bool reverificationRequired;
  final String? reverificationUrl;

  FinderStateSummary toDomain() {
    return FinderStateSummary(
      finder: finder?.toDomain(),
      eligibility: eligibility.toDomain(),
      reverificationRequired: reverificationRequired,
      reverificationUrl: reverificationUrl,
    );
  }
}

/// Request DTO for activating Finder membership.
class FinderActivationRequestDto {
  const FinderActivationRequestDto({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.region,
    required this.postalCode,
    required this.residentialCountryCode,
    required this.agreementVersion,
    required this.agreementAccepted,
  });

  factory FinderActivationRequestDto.fromDomain(FinderActivationParams params) {
    return FinderActivationRequestDto(
      addressLine1: params.addressLine1,
      addressLine2: params.addressLine2,
      city: params.city,
      region: params.region,
      postalCode: params.postalCode,
      residentialCountryCode: params.residentialCountryCode,
      agreementVersion: params.agreementVersion,
      agreementAccepted: params.agreementAccepted,
    );
  }

  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? region;
  final String postalCode;
  final String residentialCountryCode;
  final String agreementVersion;
  final bool agreementAccepted;

  Map<String, dynamic> toJson() {
    final line2 = addressLine2;
    final stateRegion = region;
    return {
      'address_line_1': addressLine1,
      if (line2 != null && line2.isNotEmpty) 'address_line_2': line2,
      'city': city,
      if (stateRegion != null && stateRegion.isNotEmpty) 'region': stateRegion,
      'postal_code': postalCode,
      'residential_country_code': residentialCountryCode,
      'agreement_version': agreementVersion,
      'agreement_accepted': agreementAccepted,
    };
  }
}

/// Request DTO for updating permitted Finder profile fields.
class FinderProfileUpdateDto {
  const FinderProfileUpdateDto({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.region,
    this.postalCode,
    this.residentialCountryCode,
    this.email,
  });

  factory FinderProfileUpdateDto.fromDomain(FinderProfileUpdateParams params) {
    return FinderProfileUpdateDto(
      addressLine1: params.addressLine1,
      addressLine2: params.addressLine2,
      city: params.city,
      region: params.region,
      postalCode: params.postalCode,
      residentialCountryCode: params.residentialCountryCode,
      email: params.email,
    );
  }

  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? residentialCountryCode;
  final String? email;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    if (addressLine1 != null) payload['address_line_1'] = addressLine1;
    if (addressLine2 != null) payload['address_line_2'] = addressLine2;
    if (city != null) payload['city'] = city;
    if (region != null) payload['region'] = region;
    if (postalCode != null) payload['postal_code'] = postalCode;
    if (residentialCountryCode != null) {
      payload['residential_country_code'] = residentialCountryCode;
    }
    if (email != null) payload['email'] = email;
    return payload;
  }
}

