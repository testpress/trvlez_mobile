import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool shouldThrow = false;
  String? lastLoginEmail;
  String? lastLoginPassword;

  @override
  Future<void> login({required String email, required String password}) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    if (shouldThrow) {
      throw const UnauthorizedException('Invalid credentials');
    }
  }

  @override
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    return const SignupResult(
      id: 'usr-1',
      email: 'a@b.com',
      travelerProfileId: 'tp-1',
      onboardingStep: 'welcome',
    );
  }
}

void main() {
  group('LoginController State Tests', () {
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
      final state = container.read(loginControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test(
      'successful login invokes repository and remains in data state',
      () async {
        await container
            .read(loginControllerProvider.notifier)
            .login(email: 'alex@example.com', password: 'Password123!');

        expect(mockRepo.lastLoginEmail, 'alex@example.com');
        expect(mockRepo.lastLoginPassword, 'Password123!');

        final state = container.read(loginControllerProvider);
        expect(state.hasError, isFalse);
      },
    );

    test(
      'failed login sets AsyncError state and clearError resets it',
      () async {
        mockRepo.shouldThrow = true;

        await container
            .read(loginControllerProvider.notifier)
            .login(email: 'fail@example.com', password: 'wrong');

        var state = container.read(loginControllerProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<UnauthorizedException>());

        container.read(loginControllerProvider.notifier).clearError();
        state = container.read(loginControllerProvider);
        expect(state.hasError, isFalse);
      },
    );
  });
}
