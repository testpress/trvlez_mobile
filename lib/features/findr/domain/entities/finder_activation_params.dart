import 'package:meta/meta.dart';

/// Parameters required to idempotently activate a Finder membership.
@immutable
class FinderActivationParams {
  const FinderActivationParams({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.region,
    required this.postalCode,
    required this.residentialCountryCode,
    required this.agreementVersion,
    required this.agreementAccepted,
  });

  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? region;
  final String postalCode;
  final String residentialCountryCode;
  final String agreementVersion;
  final bool agreementAccepted;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderActivationParams &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.region == region &&
        other.postalCode == postalCode &&
        other.residentialCountryCode == residentialCountryCode &&
        other.agreementVersion == agreementVersion &&
        other.agreementAccepted == agreementAccepted;
  }

  @override
  int get hashCode => Object.hash(
        addressLine1,
        addressLine2,
        city,
        region,
        postalCode,
        residentialCountryCode,
        agreementVersion,
        agreementAccepted,
      );
}

/// Parameters for updating permitted Finder profile fields.
@immutable
class FinderProfileUpdateParams {
  const FinderProfileUpdateParams({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.region,
    this.postalCode,
    this.residentialCountryCode,
    this.email,
  });

  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? residentialCountryCode;
  final String? email;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderProfileUpdateParams &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.region == region &&
        other.postalCode == postalCode &&
        other.residentialCountryCode == residentialCountryCode &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(
        addressLine1,
        addressLine2,
        city,
        region,
        postalCode,
        residentialCountryCode,
        email,
      );
}
