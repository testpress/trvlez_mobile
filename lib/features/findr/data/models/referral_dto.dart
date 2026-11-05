import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/traveler_share_link.dart';

/// DTO representing a hotel referral record returned by the backend.
class HotelReferralDto {
  const HotelReferralDto({
    required this.id,
    required this.finderId,
    required this.status,
    this.shareCode,
    this.invitationTokenExpiresAt,
    this.firstContactAt,
    this.secondEmailSentAt,
    this.followUpCallCompletedAt,
    this.finalCallCompletedAt,
    this.optedOutAt,
    required this.createdAt,
    this.updatedAt,
    this.hotelName,
    this.placeId,
    this.targetEmail,
    this.targetPhone,
    this.streetAddress,
    this.city,
    this.postalCode,
    this.countryCode,
    this.personalNote,
  });

  factory HotelReferralDto.fromJson(Map<String, dynamic> json) {
    return HotelReferralDto(
      id: json['id'] as String? ?? '',
      finderId: json['finder_id'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      shareCode: json['share_code'] as String?,
      invitationTokenExpiresAt: json['invitation_token_expires_at'] != null
          ? DateTime.tryParse(json['invitation_token_expires_at'] as String)
          : null,
      firstContactAt: json['first_contact_at'] != null
          ? DateTime.tryParse(json['first_contact_at'] as String)
          : null,
      secondEmailSentAt: json['second_email_sent_at'] != null
          ? DateTime.tryParse(json['second_email_sent_at'] as String)
          : null,
      followUpCallCompletedAt: json['follow_up_call_completed_at'] != null
          ? DateTime.tryParse(json['follow_up_call_completed_at'] as String)
          : null,
      finalCallCompletedAt: json['final_call_completed_at'] != null
          ? DateTime.tryParse(json['final_call_completed_at'] as String)
          : null,
      optedOutAt: json['opted_out_at'] != null
          ? DateTime.tryParse(json['opted_out_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      hotelName: json['hotel_name'] as String?,
      placeId: json['place_id'] as String?,
      targetEmail: json['target_email'] as String?,
      targetPhone: json['target_phone'] as String?,
      streetAddress: json['street_address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      countryCode: json['country_code'] as String?,
      personalNote: json['personal_note'] as String?,
    );
  }

  final String id;
  final String finderId;
  final String status;
  final String? shareCode;
  final DateTime? invitationTokenExpiresAt;
  final DateTime? firstContactAt;
  final DateTime? secondEmailSentAt;
  final DateTime? followUpCallCompletedAt;
  final DateTime? finalCallCompletedAt;
  final DateTime? optedOutAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? hotelName;
  final String? placeId;
  final String? targetEmail;
  final String? targetPhone;
  final String? streetAddress;
  final String? city;
  final String? postalCode;
  final String? countryCode;
  final String? personalNote;

  HotelReferralItem toDomain() {
    final (label, state) = _resolveStatusDetails(status);
    final trimmedName = hotelName?.trim();

    return HotelReferralItem(
      id: id,
      finderId: finderId,
      hotelName: (trimmedName != null && trimmedName.isNotEmpty)
          ? trimmedName
          : 'Hotel Partner',
      placeId: placeId,
      targetEmail: targetEmail,
      targetPhone: targetPhone,
      streetAddress: streetAddress,
      city: city,
      postalCode: postalCode,
      countryCode: countryCode,
      personalNote: personalNote,
      status: status,
      statusLabel: label,
      state: state,
      invitationTokenExpiresAt: invitationTokenExpiresAt,
      firstContactAt: firstContactAt,
      secondEmailSentAt: secondEmailSentAt,
      followUpCallCompletedAt: followUpCallCompletedAt,
      finalCallCompletedAt: finalCallCompletedAt,
      optedOutAt: optedOutAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static (String, FindrRecommendationState) _resolveStatusDetails(String raw) {
    switch (raw) {
      case 'converted':
        return ('Joined', FindrRecommendationState.confirmed);
      case 'declined':
        return ('Declined', FindrRecommendationState.declined);
      case 'expired':
        return ('Expired', FindrRecommendationState.declined);
      case 'introduction_sent':
        return ('Invited', FindrRecommendationState.awaiting);
      case 'follow_up_call_due':
        return ('Follow-up due', FindrRecommendationState.awaiting);
      case 'second_email_available':
        return ('Follow-up ready', FindrRecommendationState.awaiting);
      case 'second_email_sent':
        return ('Follow-up sent', FindrRecommendationState.awaiting);
      case 'final_call_due':
        return ('Final call due', FindrRecommendationState.awaiting);
      case 'outreach_complete':
        return ('Outreach complete', FindrRecommendationState.awaiting);
      case 'onboarding_started':
        return ('Onboarding started', FindrRecommendationState.awaiting);
      case 'operations_review':
        return ('In review', FindrRecommendationState.awaiting);
      case 'draft':
        return ('Draft', FindrRecommendationState.awaiting);
      default:
        return ('In review', FindrRecommendationState.awaiting);
    }
  }
}

/// Paginated collection response for hotel referrals.
class HotelReferralsListResponseDto {
  const HotelReferralsListResponseDto({
    required this.items,
    required this.count,
  });

  factory HotelReferralsListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return HotelReferralsListResponseDto(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(HotelReferralDto.fromJson)
          .toList(),
      count: json['count'] as int? ?? 0,
    );
  }

  final List<HotelReferralDto> items;
  final int count;
}

/// Paginated collection response for associated hotels.
class HotelAssociationsResponseDto {
  const HotelAssociationsResponseDto({
    required this.items,
    required this.count,
  });

  factory HotelAssociationsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return HotelAssociationsResponseDto(
      items: rawItems.whereType<Map<String, dynamic>>().toList(),
      count: json['count'] as int? ?? 0,
    );
  }

  final List<Map<String, dynamic>> items;
  final int count;
}

/// DTO for permanent traveler referral share code and landing link.
class TravelerShareLinkDto {
  const TravelerShareLinkDto({
    required this.shareCode,
    required this.shareUrl,
  });

  factory TravelerShareLinkDto.fromJson(Map<String, dynamic> json) {
    return TravelerShareLinkDto(
      shareCode: json['share_code'] as String? ?? '',
      shareUrl: json['share_url'] as String? ?? '',
    );
  }

  final String shareCode;
  final String shareUrl;

  TravelerShareLink toDomain() {
    return TravelerShareLink(
      shareCode: shareCode,
      shareUrl: shareUrl,
    );
  }
}

/// DTO sent to backend to initiate a new hotel referral.
class HotelReferralCreateRequestDto {
  const HotelReferralCreateRequestDto({
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

  factory HotelReferralCreateRequestDto.fromDomain(
    HotelReferralCreateParams params,
  ) {
    return HotelReferralCreateRequestDto(
      hotelName: params.hotelName.trim(),
      streetAddress: params.streetAddress.trim(),
      city: params.city.trim(),
      postalCode: params.postalCode.trim(),
      countryCode: params.countryCode.trim().toUpperCase(),
      targetEmail: params.targetEmail.trim().toLowerCase(),
      targetPhone: params.targetPhone?.trim(),
      personalNote: params.personalNote?.trim(),
      placeId: params.placeId?.trim(),
    );
  }

  final String hotelName;
  final String streetAddress;
  final String city;
  final String postalCode;
  final String countryCode;
  final String targetEmail;
  final String? targetPhone;
  final String? personalNote;
  final String? placeId;

  Map<String, dynamic> toJson() {
    final phone = targetPhone;
    final note = personalNote;
    final googlePlaceId = placeId;

    return {
      'hotel_name': hotelName,
      'street_address': streetAddress,
      'city': city,
      'postal_code': postalCode,
      'country_code': countryCode,
      'target_email': targetEmail,
      if (phone != null && phone.isNotEmpty) 'target_phone': phone,
      if (note != null && note.isNotEmpty) 'personal_note': note,
      if (googlePlaceId != null && googlePlaceId.isNotEmpty)
        'place_id': googlePlaceId,
    };
  }
}

/// Confirmation payload returned upon successfully creating a hotel referral.
class HotelReferralCreateResponseDto {
  const HotelReferralCreateResponseDto({
    required this.referral,
    required this.invitationToken,
    required this.invitationUrl,
    required this.optOutUrl,
  });

  factory HotelReferralCreateResponseDto.fromJson(Map<String, dynamic> json) {
    final rawReferral = json['referral'] as Map<String, dynamic>? ?? {};
    return HotelReferralCreateResponseDto(
      referral: HotelReferralDto.fromJson(rawReferral),
      invitationToken: json['invitation_token'] as String? ?? '',
      invitationUrl: json['invitation_url'] as String? ?? '',
      optOutUrl: json['opt_out_url'] as String? ?? '',
    );
  }

  final HotelReferralDto referral;
  final String invitationToken;
  final String invitationUrl;
  final String optOutUrl;
}
