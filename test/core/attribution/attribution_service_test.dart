import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/attribution/attribution_dto.dart';
import 'package:trvlez_mobile/core/attribution/attribution_remote_data_source.dart';
import 'package:trvlez_mobile/core/attribution/attribution_service.dart';
import 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';

class FakeInstallReferrerClient implements InstallReferrerClient {
  final bool isSupported;
  final InstallReferrerResult? resultToReturn;
  int getInstallReferrerCallCount = 0;

  FakeInstallReferrerClient({
    this.isSupported = true,
    this.resultToReturn,
  });

  @override
  bool get isSupportedPlatform => isSupported;

  @override
  TargetPlatform? get platformOverride =>
      isSupported ? TargetPlatform.android : TargetPlatform.iOS;

  @override
  Future<InstallReferrerResult?> getInstallReferrer() async {
    getInstallReferrerCallCount++;
    return resultToReturn;
  }
}

class FakeAttributionRemoteDataSource implements AttributionRemoteDataSource {
  InstallEvidenceRequestDto? lastRequest;
  InstallEvidenceResponseDto? responseToReturn;
  DioException? exceptionToThrow;
  int callCount = 0;

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<InstallEvidenceResponseDto> recordInstallEvidence(
    InstallEvidenceRequestDto requestDto,
  ) async {
    callCount++;
    lastRequest = requestDto;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseToReturn ??
        const InstallEvidenceResponseDto(
          valid: true,
          message: 'Evidence recorded',
          referralId: 'fake_referral_id_123',
        );
  }
}

void main() {
  group('AttributionService', () {
    late AttributionStorage storage;
    late FakeAttributionRemoteDataSource fakeRemoteDataSource;

    setUp(() {
      storage = AttributionStorage();
      fakeRemoteDataSource = FakeAttributionRemoteDataSource();
    });

    test('skips immediately if evidence was already recorded', () async {
      await storage.setInstallEvidenceRecorded(true);

      final fakeClient = FakeInstallReferrerClient(
        resultToReturn: const InstallReferrerResult(
          clickReference: 'never_reached_ref_12345',
        ),
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isTrue);
      expect(fakeClient.getInstallReferrerCallCount, equals(0));
      expect(fakeRemoteDataSource.callCount, equals(0));
    });

    test('skips if platform is not supported (non-Android)', () async {
      final fakeClient = FakeInstallReferrerClient(
        isSupported: false,
        resultToReturn: const InstallReferrerResult(
          clickReference: 'ios_ref_token_12345',
        ),
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isFalse);
      expect(fakeClient.getInstallReferrerCallCount, equals(0));
      expect(fakeRemoteDataSource.callCount, equals(0));
    });

    test('captures install referrer on first launch and records evidence',
        () async {
      const clickRef = 'valid_android_click_reference_12345';
      final clickTime = DateTime.utc(2026, 11, 10, 10, 0, 0);

      final fakeClient = FakeInstallReferrerClient(
        isSupported: true,
        resultToReturn: InstallReferrerResult(
          rawReferrer: 'click_ref=$clickRef',
          clickReference: clickRef,
          clickTimestamp: clickTime,
        ),
      );

      fakeRemoteDataSource.responseToReturn = const InstallEvidenceResponseDto(
        valid: true,
        message: 'Install evidence successfully verified.',
        referralId: 'referral_uuid_456',
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isTrue);
      expect(fakeClient.getInstallReferrerCallCount, equals(1));
      expect(fakeRemoteDataSource.callCount, equals(1));
      expect(fakeRemoteDataSource.lastRequest?.clickReference, equals(clickRef));
      expect(fakeRemoteDataSource.lastRequest?.occurredAt, equals(clickTime));
      expect(storage.getClickReference(), equals(clickRef));
      expect(storage.isInstallEvidenceRecorded(), isTrue);
      expect(storage.isInstallReferrerChecked(), isTrue);
    });

    test('marks checked and does not call API when no referrer is found',
        () async {
      final fakeClient = FakeInstallReferrerClient(
        isSupported: true,
        resultToReturn: null,
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isFalse);
      expect(fakeClient.getInstallReferrerCallCount, equals(1));
      expect(fakeRemoteDataSource.callCount, equals(0));
      expect(storage.isInstallReferrerChecked(), isTrue);
      expect(storage.isInstallEvidenceRecorded(), isFalse);
    });

    test('does not re-query client if install referrer was already checked',
        () async {
      await storage.setInstallReferrerChecked(true);

      final fakeClient = FakeInstallReferrerClient(
        isSupported: true,
        resultToReturn: const InstallReferrerResult(
          clickReference: 'some_new_ref_12345',
        ),
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isFalse);
      expect(fakeClient.getInstallReferrerCallCount, equals(0));
      expect(fakeRemoteDataSource.callCount, equals(0));
    });

    test(
        'preserves reference and keeps recorded false on transient network error',
        () async {
      const clickRef = 'network_error_click_ref_12345';
      final fakeClient = FakeInstallReferrerClient(
        isSupported: true,
        resultToReturn: const InstallReferrerResult(
          clickReference: clickRef,
        ),
      );

      fakeRemoteDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/install-evidence'),
        type: DioExceptionType.connectionTimeout,
        error: 'Connection timed out',
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isFalse);
      expect(storage.getClickReference(), equals(clickRef));
      expect(storage.isInstallEvidenceRecorded(), isFalse);
    });

    test('retries previously captured reference on subsequent call and succeeds',
        () async {
      const clickRef = 'cached_retry_click_ref_12345';
      await storage.saveClickReference(clickRef);

      final fakeClient = FakeInstallReferrerClient(
        isSupported: true,
        resultToReturn: null,
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isTrue);
      expect(fakeClient.getInstallReferrerCallCount, equals(0)); // client not called
      expect(fakeRemoteDataSource.callCount, equals(1));
      expect(fakeRemoteDataSource.lastRequest?.clickReference, equals(clickRef));
      expect(storage.isInstallEvidenceRecorded(), isTrue);
    });

    test('marks recorded on terminal error (HTTP 404/410/400)', () async {
      const clickRef = 'expired_referral_click_ref_12345';
      await storage.saveClickReference(clickRef);

      final fakeClient = FakeInstallReferrerClient(isSupported: true);

      fakeRemoteDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/install-evidence'),
        response: Response(
          requestOptions: RequestOptions(path: '/install-evidence'),
          statusCode: 410,
          data: {'detail': 'This referral click reference has expired.'},
        ),
        type: DioExceptionType.badResponse,
      );

      final service = AttributionService(
        installReferrerClient: fakeClient,
        attributionStorage: storage,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await service.captureInstallReferrer();

      expect(result, isFalse);
      expect(storage.isInstallEvidenceRecorded(), isTrue);
    });
  });
}

