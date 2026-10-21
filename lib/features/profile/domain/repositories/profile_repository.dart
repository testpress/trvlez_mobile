import 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';

/// Domain contract for traveler profile management.
abstract interface class ProfileRepository {
  /// Fetches the current traveler's profile.
  Future<Profile> getProfile();

  /// Updates profile attributes and returns the updated [Profile].
  Future<Profile> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  });

  /// Updates user-owned details (display name, email).
  Future<Profile> updateUserDetails({
    String? displayName,
    String? email,
  });
}

