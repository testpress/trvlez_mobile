import 'package:flutter/foundation.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';import 'package:trvlez_mobile/features/profile/domain/profile.dart';
class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileNotifier({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  Profile? profile;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.getProfile();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.updateProfile(
        phone: phone,
        nationality: nationality,
        gender: gender,
        dateOfBirth: dateOfBirth,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
