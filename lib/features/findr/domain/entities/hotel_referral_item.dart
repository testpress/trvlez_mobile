import 'package:meta/meta.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';

/// Concrete entity representing a hotel partner referral and its outreach cadence.
@immutable
class HotelReferralItem {
  const HotelReferralItem({
    required this.id,
    required this.finderId,
    required this.hotelName,
    this.placeId,
    this.targetEmail,
    this.targetPhone,
    this.streetAddress,
    this.city,
    this.postalCode,
    this.countryCode,
    this.personalNote,
    required this.status,
    required this.statusLabel,
    required this.state,
    this.invitationTokenExpiresAt,
    this.firstContactAt,
    this.secondEmailSentAt,
    this.followUpCallCompletedAt,
    this.finalCallCompletedAt,
    this.optedOutAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String finderId;
  final String hotelName;
  final String? placeId;
  final String? targetEmail;
  final String? targetPhone;
  final String? streetAddress;
  final String? city;
  final String? postalCode;
  final String? countryCode;
  final String? personalNote;
  final String status;
  final String statusLabel;
  final FindrRecommendationState state;
  final DateTime? invitationTokenExpiresAt;
  final DateTime? firstContactAt;
  final DateTime? secondEmailSentAt;
  final DateTime? followUpCallCompletedAt;
  final DateTime? finalCallCompletedAt;
  final DateTime? optedOutAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isLive => status == 'converted';

  bool get isPending =>
      status == 'draft' ||
      status == 'operations_review' ||
      status == 'onboarding_started';

  bool get isOutreach =>
      status == 'introduction_sent' ||
      status == 'follow_up_call_due' ||
      status == 'second_email_available' ||
      status == 'second_email_sent' ||
      status == 'final_call_due' ||
      status == 'outreach_complete';

  bool get isDeclined => status == 'declined';

  bool get isExpired => status == 'expired';

  String get location {
    final parts = [
      city,
      countryCode,
    ].where((part) => part != null && part.isNotEmpty);
    return parts.isEmpty ? 'Location on file' : parts.join(', ');
  }

  String get fullAddress {
    final parts = [
      streetAddress,
      city,
      postalCode,
      countryCode,
    ].where((part) => part != null && part.isNotEmpty);
    return parts.isEmpty ? 'Address on file' : parts.join(', ');
  }

  String get formattedWhen {
    return 'Recommended ${createdAt.day} ${_monthName(createdAt.month)} ${createdAt.year}';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
