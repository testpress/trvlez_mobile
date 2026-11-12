import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/providers/repository_providers.dart';
import 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';

export 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
export 'package:trvlez_mobile/core/providers/repository_providers.dart'
    show profileRepositoryProvider;
export 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';
export 'package:trvlez_mobile/features/profile/domain/repositories/profile_repository.dart';

/// Provider for current traveler profile state.
final currentProfileProvider = AsyncNotifierProvider<ProfileNotifier, Profile>(
  () => ProfileNotifier(),
);

/// Asynchronous state notifier managing traveler profile data.
class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  FutureOr<Profile> build() async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfile();
  }

  Future<bool> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
    state = const AsyncLoading<Profile>().copyWithPrevious(state);

    try {
      final repository = ref.read(profileRepositoryProvider);
      final updatedProfile = await repository.updateProfile(
        phone: phone,
        nationality: nationality,
        gender: gender,
        dateOfBirth: dateOfBirth,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
      );
      state = AsyncData(updatedProfile);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<Profile>(error, stackTrace).copyWithPrevious(state);
      return false;
    }
  }

  Future<bool> updateUserDetails({String? displayName, String? email}) async {
    state = const AsyncLoading<Profile>().copyWithPrevious(state);

    try {
      final repository = ref.read(profileRepositoryProvider);
      final updatedProfile = await repository.updateUserDetails(
        displayName: displayName,
        email: email,
      );
      state = AsyncData(updatedProfile);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<Profile>(error, stackTrace).copyWithPrevious(state);
      return false;
    }
  }

  void clearError() {
    if (state.hasError && state.hasValue) {
      state = AsyncData(state.value!);
    }
  }
}
