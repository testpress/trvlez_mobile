import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/auth/domain/entities/signup_result.dart';

void main() {
  group('SignupResult Entity Tests', () {
    test('instantiates with all required fields', () {
      const result = SignupResult(
        id: 'usr-1',
        email: 'alex@example.com',
        travelerProfileId: 'prof-1',
        onboardingStep: 'profile_pending',
      );

      expect(result.id, 'usr-1');
      expect(result.email, 'alex@example.com');
      expect(result.travelerProfileId, 'prof-1');
      expect(result.onboardingStep, 'profile_pending');
    });

    test('value equality holds for identical instances', () {
      const a = SignupResult(
        id: 'usr-1',
        email: 'alex@example.com',
        travelerProfileId: 'prof-1',
        onboardingStep: 'profile_pending',
      );
      const b = SignupResult(
        id: 'usr-1',
        email: 'alex@example.com',
        travelerProfileId: 'prof-1',
        onboardingStep: 'profile_pending',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different properties produce inequality', () {
      const a = SignupResult(
        id: 'usr-1',
        email: 'alex@example.com',
        travelerProfileId: 'prof-1',
        onboardingStep: 'profile_pending',
      );
      const b = SignupResult(
        id: 'usr-2',
        email: 'alex@example.com',
        travelerProfileId: 'prof-1',
        onboardingStep: 'profile_pending',
      );

      expect(a, isNot(equals(b)));
    });
  });
}
