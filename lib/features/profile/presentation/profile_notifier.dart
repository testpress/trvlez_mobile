import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileNotifier({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  Profile? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.getProfile();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
      _isLoading = false;
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.updateProfile(
        phone: phone,
        nationality: nationality,
        gender: gender,
        dateOfBirth: dateOfBirth,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
