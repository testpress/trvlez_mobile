import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool shouldThrow = false;
  String? lastSignUpEmail;
  String? lastSignUpPassword;

  @override
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    if (shouldThrow) {
      throw const ValidationException('User with this email already exists');
    }
    return const SignupResult(
      id: 'usr-new-1',
      email: 'new@example.com',
      travelerProfileId: 'tp-new-1',
      onboardingStep: 'profile_pending',
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {}
}

void main() {
  group('RegistrationController State Tests', () {
    late MockAuthRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is data(null)', () {
      final state = container.read(registrationControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('successful signup invokes repository and finishes cleanly', () async {
      await container
          .read(registrationControllerProvider.notifier)
          .signUp(email: 'new@example.com', password: 'Password123!');

      expect(mockRepo.lastSignUpEmail, 'new@example.com');
      expect(mockRepo.lastSignUpPassword, 'Password123!');

      final state = container.read(registrationControllerProvider);
      expect(state.hasError, isFalse);
    });

    test(
      'failed signup captures error in state and clearError resets it',
      () async {
        mockRepo.shouldThrow = true;

        await container
            .read(registrationControllerProvider.notifier)
            .signUp(email: 'dup@example.com', password: 'Password123!');

        var state = container.read(registrationControllerProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<ValidationException>());

        container.read(registrationControllerProvider.notifier).clearError();
        state = container.read(registrationControllerProvider);
        expect(state.hasError, isFalse);
      },
    );
  });
}
