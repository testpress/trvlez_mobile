import 'package:trvlez_mobile/features/auth/domain/entities/signup_result.dart';

/// Domain contract for authentication operations.
///
/// Pure Dart interface decoupling business logic from remote API client and storage.
abstract interface class AuthRepository {
  /// Creates a new traveler account and returns a [SignupResult].
  Future<SignupResult> signUp({
    required String email,
    required String password,
  });

  /// Logs in an existing traveler and persists the access token.
  Future<void> login({
    required String email,
    required String password,
  });
}
