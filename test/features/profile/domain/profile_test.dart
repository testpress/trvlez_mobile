import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';

void main() {
  group('Profile Entity Tests', () {
    test('instantiates with complete fields', () {
      final dob = DateTime.utc(1995, 5, 20);
      final expiry = DateTime.utc(2030, 8, 15);
      final profile = Profile(
        id: 'prof-123',
        phone: '+919876543210',
        nationality: 'India',
        gender: 'male',
        dateOfBirth: dob,
        passportNumber: 'Z1234567',
        passportExpiry: expiry,
        onboardingStep: 'welcome',
      );

      expect(profile.id, 'prof-123');
      expect(profile.phone, '+919876543210');
      expect(profile.nationality, 'India');
      expect(profile.gender, 'male');
      expect(profile.dateOfBirth, dob);
      expect(profile.passportNumber, 'Z1234567');
      expect(profile.passportExpiry, expiry);
      expect(profile.onboardingStep, 'welcome');
      expect(profile.verificationState, TravelerVerificationState.profilePending);
    });

    test('derives verificationState correctly from backend step', () {
      const pVerified = Profile(
        id: 'p1',
        onboardingStep: 'verified',
      );
      expect(pVerified.verificationState, TravelerVerificationState.verified);

      const pDocScan = Profile(
        id: 'p2',
        onboardingStep: 'documents_uploaded',
      );
      expect(pDocScan.verificationState, TravelerVerificationState.documentsUploaded);

      const pComplete = Profile(
        id: 'p3',
        onboardingStep: 'profile_complete',
      );
      expect(pComplete.verificationState, TravelerVerificationState.profileComplete);

      const pFailed = Profile(
        id: 'p4',
        onboardingStep: 'rejected',
      );
      expect(pFailed.verificationState, TravelerVerificationState.failed);
    });

    test('copyWith updates specified fields only', () {
      const original = Profile(
        id: 'p1',
        nationality: 'India',
        phone: '+123',
        onboardingStep: 'welcome',
      );

      final updated = original.copyWith(
        nationality: 'Canada',
        onboardingStep: 'completed',
      );

      expect(updated.id, 'p1');
      expect(updated.phone, '+123');
      expect(updated.nationality, 'Canada');
      expect(updated.onboardingStep, 'completed');
    });

    test('value equality works as expected', () {
      const a = Profile(
        id: 'p1',
        nationality: 'India',
        onboardingStep: 'welcome',
      );
      const b = Profile(
        id: 'p1',
        nationality: 'India',
        onboardingStep: 'welcome',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
