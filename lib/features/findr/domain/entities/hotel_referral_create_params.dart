import 'package:meta/meta.dart';

/// Parameters for submitting a prospective hotel referral invitation.
@immutable
class HotelReferralCreateParams {
  const HotelReferralCreateParams({
    required this.hotelName,
    required this.streetAddress,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.targetEmail,
    this.targetPhone,
    this.personalNote,
    this.placeId,
  });

  final String hotelName;
  final String streetAddress;
  final String city;
  final String postalCode;
  final String countryCode;
  final String targetEmail;
  final String? targetPhone;
  final String? personalNote;
  final String? placeId;
}
