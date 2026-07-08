/// Represents the traveler's position in the verification journey.
///
/// Mapped from the backend's `onboarding_step` string field on the profile.
/// Each state drives routing decisions and UI rendering (banners, status screens).
///
/// Backend state machine:
/// ```
/// profile_pending → profile_complete → verification_started
///   → documents_uploaded → submitted → verified
/// ```
enum TravelerVerificationState {
  /// Profile has not been completed yet.
  profilePending,

  /// Profile fields are filled — ready to start verification.
  profileComplete,

  /// Verification session created, but documents not yet uploaded.
  verificationStarted,

  /// Both passport and video files are uploaded (session status = uploaded).
  documentsUploaded,

  /// All documents submitted — verification is under review
  /// (session status = processing).
  submitted,

  /// Verification approved — traveler has full access.
  verified,

  /// Verification was rejected — traveler must re-submit documents.
  /// Note: This is derived from VerificationSessionStatus, not from
  /// TravelerOnboardingStep (which stays at "submitted").
  failed;

  /// Whether the traveler still needs to complete onboarding steps.
  /// Used by the home screen to show the appropriate banner.
  bool get needsOnboarding => switch (this) {
    profilePending ||
    profileComplete ||
    verificationStarted ||
    documentsUploaded => true,
    _ => false,
  };

  /// Whether the traveler's verification is currently being reviewed.
  bool get isProcessing => this == submitted;

  /// Whether the traveler is fully verified and has unrestricted access.
  bool get isVerified => this == verified;

  /// Whether the verification was rejected and needs re-submission.
  bool get isFailed => this == failed;

  /// Whether the user needs to take action (incomplete onboarding or failed).
  bool get needsAttention => needsOnboarding || isFailed;

  /// Whether the banner should be shown on the home screen.
  /// Hidden only when verified.
  bool get shouldShowBanner => this != verified;

  /// Parses the backend's `onboarding_step` string to a typed enum.
  ///
  /// Unknown values default to [profilePending] for safety — the user
  /// will be guided through onboarding if the backend sends something
  /// unexpected.
  static TravelerVerificationState fromBackendStep(String step) {
    return switch (step) {
      'profile_pending' => profilePending,
      'profile_complete' => profileComplete,
      'verification_started' => verificationStarted,
      'documents_uploaded' => documentsUploaded,
      'submitted' => submitted,
      'verified' => verified,
      'failed' || 'rejected' => failed,
      _ => profilePending,
    };
  }
}
