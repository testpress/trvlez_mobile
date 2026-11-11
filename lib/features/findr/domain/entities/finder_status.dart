import 'package:meta/meta.dart';

/// Lifecycle statuses for a Finder account.
enum FinderStatusType {
  draft,
  pendingReview,
  active,
  rejected,
  suspendedTemporary,
  suspendedPermanent,
  deactivated;

  static FinderStatusType fromString(String value) {
    return switch (value.toLowerCase()) {
      'draft' => FinderStatusType.draft,
      'pending_review' => FinderStatusType.pendingReview,
      'active' => FinderStatusType.active,
      'rejected' => FinderStatusType.rejected,
      'suspended_temporary' => FinderStatusType.suspendedTemporary,
      'suspended_permanent' => FinderStatusType.suspendedPermanent,
      'deactivated' => FinderStatusType.deactivated,
      _ => FinderStatusType.draft,
    };
  }

  String toBackendString() {
    return switch (this) {
      FinderStatusType.draft => 'draft',
      FinderStatusType.pendingReview => 'pending_review',
      FinderStatusType.active => 'active',
      FinderStatusType.rejected => 'rejected',
      FinderStatusType.suspendedTemporary => 'suspended_temporary',
      FinderStatusType.suspendedPermanent => 'suspended_permanent',
      FinderStatusType.deactivated => 'deactivated',
    };
  }
}

/// Central eligibility reasons evaluated authoritative on the backend.
enum FinderEligibilityReason {
  eligible,
  programDisabled,
  accountInactive,
  verificationIncomplete,
  verificationExpired,
  dateOfBirthMissing,
  underage,
  addressRequired,
  marketUnavailable,
  marketLimitReached,
  terminalStatus;

  static FinderEligibilityReason fromString(String value) {
    return switch (value.toLowerCase()) {
      'eligible' => FinderEligibilityReason.eligible,
      'program_disabled' => FinderEligibilityReason.programDisabled,
      'account_inactive' => FinderEligibilityReason.accountInactive,
      'verification_incomplete' =>
        FinderEligibilityReason.verificationIncomplete,
      'verification_expired' => FinderEligibilityReason.verificationExpired,
      'date_of_birth_missing' => FinderEligibilityReason.dateOfBirthMissing,
      'underage' => FinderEligibilityReason.underage,
      'address_required' => FinderEligibilityReason.addressRequired,
      'market_unavailable' => FinderEligibilityReason.marketUnavailable,
      'market_limit_reached' => FinderEligibilityReason.marketLimitReached,
      'terminal_status' => FinderEligibilityReason.terminalStatus,
      _ => FinderEligibilityReason.terminalStatus,
    };
  }

  String toBackendString() {
    return switch (this) {
      FinderEligibilityReason.eligible => 'eligible',
      FinderEligibilityReason.programDisabled => 'program_disabled',
      FinderEligibilityReason.accountInactive => 'account_inactive',
      FinderEligibilityReason.verificationIncomplete =>
        'verification_incomplete',
      FinderEligibilityReason.verificationExpired => 'verification_expired',
      FinderEligibilityReason.dateOfBirthMissing => 'date_of_birth_missing',
      FinderEligibilityReason.underage => 'underage',
      FinderEligibilityReason.addressRequired => 'address_required',
      FinderEligibilityReason.marketUnavailable => 'market_unavailable',
      FinderEligibilityReason.marketLimitReached => 'market_limit_reached',
      FinderEligibilityReason.terminalStatus => 'terminal_status',
    };
  }
}

/// Structured residential address snapshot owned by the Finder record.
@immutable
class FinderAddress {
  const FinderAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.region,
    required this.postalCode,
    required this.residentialCountryCode,
  });

  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? region;
  final String postalCode;
  final String residentialCountryCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderAddress &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.region == region &&
        other.postalCode == postalCode &&
        other.residentialCountryCode == residentialCountryCode;
  }

  @override
  int get hashCode => Object.hash(
    addressLine1,
    addressLine2,
    city,
    region,
    postalCode,
    residentialCountryCode,
  );
}

/// Identity and lifecycle record of an active or historical Finder.
@immutable
class FinderIdentity {
  const FinderIdentity({
    required this.id,
    required this.userId,
    required this.status,
    this.address,
    this.agreementVersion,
    this.activatedAt,
    this.suspendedAt,
    this.suspensionEndsAt,
    this.verificationLapsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final FinderStatusType status;
  final FinderAddress? address;
  final String? agreementVersion;
  final DateTime? activatedAt;
  final DateTime? suspendedAt;
  final DateTime? suspensionEndsAt;
  final DateTime? verificationLapsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == FinderStatusType.active;
  bool get isSuspended =>
      status == FinderStatusType.suspendedTemporary ||
      status == FinderStatusType.suspendedPermanent;
  bool get isTerminated =>
      status == FinderStatusType.suspendedPermanent ||
      status == FinderStatusType.deactivated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderIdentity &&
        other.id == id &&
        other.userId == userId &&
        other.status == status &&
        other.address == address &&
        other.agreementVersion == agreementVersion &&
        other.activatedAt == activatedAt &&
        other.suspendedAt == suspendedAt &&
        other.suspensionEndsAt == suspensionEndsAt &&
        other.verificationLapsedAt == verificationLapsedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    status,
    address,
    agreementVersion,
    activatedAt,
    suspendedAt,
    suspensionEndsAt,
    verificationLapsedAt,
    createdAt,
    updatedAt,
  );
}

/// Eligibility evaluation returned by the backend.
@immutable
class FinderEligibility {
  const FinderEligibility({
    required this.isEligible,
    required this.reason,
    this.message,
  });

  final bool isEligible;
  final FinderEligibilityReason reason;
  final String? message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderEligibility &&
        other.isEligible == isEligible &&
        other.reason == reason &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(isEligible, reason, message);
}

/// Aggregated Finder status model combining identity, eligibility, and re-verification requirements.
@immutable
class FinderStateSummary {
  const FinderStateSummary({
    this.finder,
    required this.eligibility,
    required this.reverificationRequired,
    this.reverificationUrl,
  });

  final FinderIdentity? finder;
  final FinderEligibility eligibility;
  final bool reverificationRequired;
  final String? reverificationUrl;

  bool get hasActiveFinder => finder?.isActive ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinderStateSummary &&
        other.finder == finder &&
        other.eligibility == eligibility &&
        other.reverificationRequired == reverificationRequired &&
        other.reverificationUrl == reverificationUrl;
  }

  @override
  int get hashCode => Object.hash(
    finder,
    eligibility,
    reverificationRequired,
    reverificationUrl,
  );
}
