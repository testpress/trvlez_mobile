import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/data/dto/login_response_dto.dart';
import 'package:trvlez_mobile/features/auth/data/dto/traveler_signup_dto.dart';
import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return storage[key];
  }
}

class MockAuthRemoteDataSource extends Fake implements AuthRemoteDataSource {
  bool shouldThrow = false;
  int statusCode = 500;

  @override
  Future<TravelerSignupResponseDto> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/traveler/signup'),
        response: Response(
          requestOptions: RequestOptions(path: '/traveler/signup'),
          statusCode: statusCode,
          data: {'detail': 'Email already registered'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const TravelerSignupResponseDto(
      id: 'usr-signup-1',
      email: 'newuser@example.com',
      travelerProfile: TravelerProfileNestedDto(
        id: 'prof-signup-1',
        onboardingStep: 'profile_pending',
      ),
    );
  }

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/login/access-token'),
        response: Response(
          requestOptions: RequestOptions(path: '/login/access-token'),
          statusCode: statusCode,
          data: {'detail': 'Invalid credentials'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const LoginResponseDto(
      accessToken: 'sample_jwt_access_token',
      tokenType: 'bearer',
    );
  }
}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockFlutterSecureStorage mockSecureStorage;
  late TokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockSecureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(storage: mockSecureStorage);
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      tokenStorage: tokenStorage,
    );
  });

  group('AuthRepositoryImpl Unit Tests', () {
    test('signUp creates account and returns domain SignupResult', () async {
      final result = await repository.signUp(
        email: 'newuser@example.com',
        password: 'Password123!',
      );

      expect(result.id, 'usr-signup-1');
      expect(result.email, 'newuser@example.com');
      expect(result.travelerProfileId, 'prof-signup-1');
      expect(result.onboardingStep, 'profile_pending');
    });

    test('signUp maps DioException to AppException', () async {
      mockRemote.shouldThrow = true;
      mockRemote.statusCode = 409;

      expect(
        () => repository.signUp(
          email: 'dup@example.com',
          password: 'Password123!',
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('login logs in and stores access token in tokenStorage', () async {
      await repository.login(
        email: 'user@example.com',
        password: 'Password123!',
      );

      final token = await tokenStorage.getToken();
      expect(token, 'sample_jwt_access_token');
    });

    test('login maps DioException to AppException', () async {
      mockRemote.shouldThrow = true;
      mockRemote.statusCode = 401;

      expect(
        () => repository.login(
          email: 'bad@example.com',
          password: 'WrongPassword!',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
