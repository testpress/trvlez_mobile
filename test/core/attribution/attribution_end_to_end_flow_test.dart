import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
import 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
import 'package:trvlez_mobile/core/attribution/attribution_service.dart';
import 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/data/dto/traveler_signup_dto.dart';
import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class MockSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> data = {};

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
      data[key] = value;
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
    return data[key];
  }
}

class EndToEndMockAuthRemoteDataSource extends Fake
    implements AuthRemoteDataSource {
  String? lastSignUpEmail;
  String? lastSignUpPassword;
  String? lastSignUpClickReference;

  @override
  Future<TravelerSignupResponseDto> signUp({
    required String email,
    required String password,
    String? clickReference,
  }) async {
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    lastSignUpClickReference = clickReference;

    return const TravelerSignupResponseDto(
      id: 'mock-user-uuid-1',
      email: 'traveler@example.com',
      fullName: 'End to End Traveler',
      travelerProfile: TravelerProfileNestedDto(
        id: 'mock-profile-uuid-1',
        onboardingStep: 'profile_pending',
      ),
    );
  }
}

class EndToEndMockAttributionRemoteDataSource
    implements AttributionRemoteDataSource {
  int postCallCount = 0;
  InstallEvidenceRequestDto? lastSubmittedRequest;
  bool shouldThrowNetworkError = false;

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<InstallEvidenceResponseDto> recordInstallEvidence(
    InstallEvidenceRequestDto requestDto,
  ) async {
    postCallCount++;
    lastSubmittedRequest = requestDto;

    if (shouldThrowNetworkError) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/public/referrals/traveler/install-evidence',
        ),
        type: DioExceptionType.connectionTimeout,
        error: 'Network connectivity unavailable',
      );
    }

    return const InstallEvidenceResponseDto(
      valid: true,
      message: 'Install evidence successfully verified.',
      referralId: 'mock-referral-uuid-12345',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile App Attribution Complete End-to-End Flow', () {
    const channelName = InstallReferrerClient.channelName;
    late AttributionStorage attributionStorage;
    late EndToEndMockAttributionRemoteDataSource attributionRemoteDataSource;
    late EndToEndMockAuthRemoteDataSource authRemoteDataSource;
    late TokenStorage tokenStorage;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      attributionStorage = AttributionStorage();
      attributionRemoteDataSource = EndToEndMockAttributionRemoteDataSource();
      authRemoteDataSource = EndToEndMockAuthRemoteDataSource();
      tokenStorage = TokenStorage(storage: MockSecureStorage());
      authRepository = AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        tokenStorage: tokenStorage,
        attributionStorage: attributionStorage,
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), null);
    });

    test(
      'Complete Journey: First Launch -> Install Evidence Verified -> Traveler Registration Handoff -> Subsequent Launch Idempotency',
      () async {
        // 1. Arrange native MethodChannel simulating Play Store install referrer
        const rawToken = 'play_store_ref_token_xyz_987654321';
        final clickTimestampSeconds = 1700000000;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(channelName), (
              call,
            ) async {
              if (call.method == 'getInstallReferrer') {
                return <String, dynamic>{
                  'installReferrer': 'click_ref=$rawToken',
                  'referrerClickTimestampSeconds': clickTimestampSeconds,
                  'installBeginTimestampSeconds': 1700000020,
                };
              }
              return null;
            });

        const installReferrerClient = InstallReferrerClient(
          platformOverride: TargetPlatform.android,
        );

        final attributionService = AttributionService(
          installReferrerClient: installReferrerClient,
          attributionStorage: attributionStorage,
          remoteDataSource: attributionRemoteDataSource,
        );

        // 2. Act: First app launch background attribution hook
        final firstLaunchResult = await attributionService
            .captureInstallReferrer();

        // Assert first launch attribution
        expect(firstLaunchResult, isTrue);
        expect(attributionRemoteDataSource.postCallCount, equals(1));
        expect(
          attributionRemoteDataSource.lastSubmittedRequest?.clickReference,
          equals(rawToken),
        );
        expect(
          attributionRemoteDataSource.lastSubmittedRequest?.occurredAt,
          equals(
            DateTime.fromMillisecondsSinceEpoch(
              clickTimestampSeconds * 1000,
              isUtc: true,
            ),
          ),
        );
        expect(attributionStorage.getClickReference(), equals(rawToken));
        expect(attributionStorage.isInstallEvidenceRecorded(), isTrue);
        expect(attributionStorage.isInstallReferrerChecked(), isTrue);

        // 3. Act: Traveler proceeds to register an account
        await authRepository.signUp(
          email: 'traveler@example.com',
          password: 'Password123!',
        );

        // Assert traveler registration forwards the stored click_reference
        expect(
          authRemoteDataSource.lastSignUpEmail,
          equals('traveler@example.com'),
        );
        expect(authRemoteDataSource.lastSignUpPassword, equals('Password123!'));
        expect(authRemoteDataSource.lastSignUpClickReference, equals(rawToken));

        // 4. Act: Subsequent app launch (or app resume)
        final secondLaunchResult = await attributionService
            .captureInstallReferrer();

        // Assert idempotency: No new HTTP calls or duplicate processing
        expect(secondLaunchResult, isTrue);
        expect(
          attributionRemoteDataSource.postCallCount,
          equals(1),
        ); // Still exactly 1
      },
    );

    test(
      'Offline First Launch: Preserves Token -> Retries on Resume/Reconnect -> Succeeds',
      () async {
        const rawToken = 'offline_click_token_1234567890';

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(channelName), (
              call,
            ) async {
              if (call.method == 'getInstallReferrer') {
                return <String, dynamic>{
                  'installReferrer': 'click_ref=$rawToken',
                  'referrerClickTimestampSeconds': 1700000000,
                  'installBeginTimestampSeconds': 1700000020,
                };
              }
              return null;
            });

        const installReferrerClient = InstallReferrerClient(
          platformOverride: TargetPlatform.android,
        );

        final attributionService = AttributionService(
          installReferrerClient: installReferrerClient,
          attributionStorage: attributionStorage,
          remoteDataSource: attributionRemoteDataSource,
        );

        // Simulate offline / network failure on first launch
        attributionRemoteDataSource.shouldThrowNetworkError = true;

        final firstLaunchAttempt = await attributionService
            .captureInstallReferrer();

        // Assert: Gracefully handled, not marked recorded, but token is saved!
        expect(firstLaunchAttempt, isFalse);
        expect(attributionStorage.getClickReference(), equals(rawToken));
        expect(attributionStorage.isInstallEvidenceRecorded(), isFalse);

        // Reconnect / recover network
        attributionRemoteDataSource.shouldThrowNetworkError = false;

        // Simulate app resumed or re-triggered hook
        final retryAttempt = await attributionService.captureInstallReferrer();

        // Assert: Successfully recovered and recorded
        expect(retryAttempt, isTrue);
        expect(attributionStorage.isInstallEvidenceRecorded(), isTrue);
        expect(attributionRemoteDataSource.postCallCount, equals(2));
      },
    );

    test(
      'Organic / Sideload Install: Marks Checked Without Backend Calls Or Errors',
      () async {
        // Simulate no referrer parameter (organic direct Play Store search or sideload)
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(channelName), (
              call,
            ) async {
              if (call.method == 'getInstallReferrer') {
                return <String, dynamic>{
                  'installReferrer':
                      'utm_source=google-play&utm_medium=organic',
                };
              }
              return null;
            });

        const installReferrerClient = InstallReferrerClient(
          platformOverride: TargetPlatform.android,
        );

        final attributionService = AttributionService(
          installReferrerClient: installReferrerClient,
          attributionStorage: attributionStorage,
          remoteDataSource: attributionRemoteDataSource,
        );

        final result = await attributionService.captureInstallReferrer();

        expect(result, isFalse);
        expect(attributionStorage.isInstallReferrerChecked(), isTrue);
        expect(attributionStorage.getClickReference(), isNull);
        expect(attributionStorage.isInstallEvidenceRecorded(), isFalse);
        expect(
          attributionRemoteDataSource.postCallCount,
          equals(0),
        ); // Zero HTTP calls

        // Future launches will also skip immediately
        final subsequentResult = await attributionService
            .captureInstallReferrer();
        expect(subsequentResult, isFalse);
        expect(attributionRemoteDataSource.postCallCount, equals(0));
      },
    );
  });
}
