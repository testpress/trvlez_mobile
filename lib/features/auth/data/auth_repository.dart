import '../domain/signup_result.dart';
import 'auth_remote_data_source.dart';

/// Repository that abstracts auth data access.
///
/// Currently delegates to the remote data source directly.
/// Can be extended to add caching, offline support, or
/// combine multiple data sources in the future.
class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepository({required this.remoteDataSource});

  /// Creates a new traveler account and returns a [SignupResult].
  Future<SignupResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final dto = await remoteDataSource.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );

    return SignupResult(
      id: dto.id,
      email: dto.email,
      fullName: dto.fullName,
      travelerProfileId: dto.travelerProfile.id,
      onboardingStep: dto.travelerProfile.onboardingStep,
    );
  }
}
