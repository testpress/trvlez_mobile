import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/s3_upload_client.dart';
import 'package:trvlez_mobile/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:trvlez_mobile/features/verification/data/models/confirm_mrz_dto.dart';
import 'package:trvlez_mobile/features/verification/data/models/verification_challenge_dto.dart';
import 'package:trvlez_mobile/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/confirm_mrz_payload.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

class FakeVerificationRemoteDataSource extends Fake
    implements VerificationRemoteDataSource {
  bool startVerificationCalled = false;
  bool completePassportUploadCalled = false;
  bool completeSelfieUploadCalled = false;
  String? lastCompletedFileId;
  ConfirmMrzRequestDto? lastConfirmPayload;
  Map<String, dynamic>? lastNfcPayload;
  DioException? exceptionToThrow;

  ({String uploadUrl, String fileId}) passportUploadInit = (
    uploadUrl: 'https://s3.example.com/passport-upload',
    fileId: 'file-pass-1',
  );

  ({String uploadUrl, String fileId}) selfieUploadInit = (
    uploadUrl: 'https://s3.example.com/selfie-upload',
    fileId: 'file-selfie-1',
  );

  ImageQualityResult imageQualityResult = ImageQualityResult(
    success: true,
    status: 'passed',
    isAcceptable: true,
  );

  VideoQualityResult videoQualityResult = VideoQualityResult(
    success: true,
    status: 'passed',
    isAcceptable: true,
  );

  MrzExtractionResult mrzResult = MrzExtractionResult(
    success: true,
    documentNumber: 'P12345678',
    firstName: 'JOHN',
    lastName: 'DOE',
    nationality: 'USA',
    dateOfBirth: '1990-01-01',
    dateOfExpiry: '2030-01-01',
  );

  VerificationSubmitResult submitResult = VerificationSubmitResult(
    sessionId: 'sess-1',
    status: 'pending',
    submittedAt: DateTime(2025, 1, 1),
    verificationJobId: 'job-123',
  );

  VerificationStatus verificationStatus = const VerificationStatus(
    sessionId: 'session-1',
    status: 'approved',
  );

  VerificationJobResult jobResult = VerificationJobResult(
    id: 'job-123',
    travelerId: 'traveler-1',
    verificationSessionId: 'sess-1',
    status: 'succeeded',
    verificationType: 'passport',
    createdAt: DateTime(2025, 1, 1),
  );

  VerificationChallengeDto challengeDto = const VerificationChallengeDto(
    challengeId: 'chal-1',
    challengeType: 'turn_head',
    instructions: 'Turn head left',
    timeoutSeconds: 20,
  );

  @override
  Future<void> startVerification() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    startVerificationCalled = true;
  }

  @override
  Future<({String uploadUrl, String fileId})> initPassportUpload({
    required String mimeType,
    required int fileSizeBytes,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return passportUploadInit;
  }

  @override
  Future<void> completePassportUpload(String fileId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    completePassportUploadCalled = true;
    lastCompletedFileId = fileId;
  }

  @override
  Future<({String uploadUrl, String fileId})> initSelfieUpload({
    required String mimeType,
    required int fileSizeBytes,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return selfieUploadInit;
  }

  @override
  Future<void> completeSelfieUpload(String fileId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    completeSelfieUploadCalled = true;
    lastCompletedFileId = fileId;
  }

  @override
  Future<ImageQualityResult> checkImageQuality() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return imageQualityResult;
  }

  @override
  Future<VideoQualityResult> checkVideoQuality() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return videoQualityResult;
  }

  @override
  Future<MrzExtractionResult> extractMrz() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mrzResult;
  }

  @override
  Future<Map<String, dynamic>> confirmMrz(ConfirmMrzRequestDto payload) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    lastConfirmPayload = payload;
    return {'status': 'confirmed'};
  }

  @override
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    lastNfcPayload = nfcPayload;
    return submitResult;
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return verificationStatus;
  }

  @override
  Future<VerificationJobResult> getVerificationJob(String jobId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return jobResult;
  }

  @override
  Future<VerificationChallengeDto> getVerificationChallenge() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return challengeDto;
  }
}

class FakeS3UploadClient extends Fake implements S3UploadClient {
  String? lastUploadUrl;
  String? lastMimeType;
  int? lastFileLength;
  double reportedProgress = 0.0;

  @override
  Future<void> upload({
    required String uploadUrl,
    required File file,
    required String mimeType,
    required int fileLength,
    required void Function(double progress) onProgress,
  }) async {
    lastUploadUrl = uploadUrl;
    lastMimeType = mimeType;
    lastFileLength = fileLength;
    onProgress(1.0);
    reportedProgress = 1.0;
  }
}

void main() {
  group('VerificationRepositoryImpl', () {
    late FakeVerificationRemoteDataSource fakeDataSource;
    late FakeS3UploadClient fakeS3Client;
    late VerificationRepositoryImpl repository;
    late Directory tempDir;
    late File testFile;

    setUp(() {
      fakeDataSource = FakeVerificationRemoteDataSource();
      fakeS3Client = FakeS3UploadClient();
      repository = VerificationRepositoryImpl(
        remoteDataSource: fakeDataSource,
        s3UploadClient: fakeS3Client,
      );

      tempDir = Directory.systemTemp.createTempSync('verif_repo_test_');
      testFile = File('${tempDir.path}/test.jpg');
      testFile.writeAsBytesSync([1, 2, 3, 4]);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test(
      'uploadPassport coordinates start, init, upload, and complete',
      () async {
        double progress = 0.0;
        await repository.uploadPassport(
          testFile,
          onProgress: (p) => progress = p,
        );

        expect(fakeDataSource.startVerificationCalled, isTrue);
        expect(
          fakeS3Client.lastUploadUrl,
          'https://s3.example.com/passport-upload',
        );
        expect(fakeS3Client.lastMimeType, 'image/jpeg');
        expect(fakeS3Client.lastFileLength, 4);
        expect(fakeDataSource.completePassportUploadCalled, isTrue);
        expect(fakeDataSource.lastCompletedFileId, 'file-pass-1');
        expect(progress, 1.0);
      },
    );

    test('uploadSelfie coordinates init, upload, and complete', () async {
      final videoFile = File('${tempDir.path}/video.mp4');
      videoFile.writeAsBytesSync([5, 6, 7]);

      double progress = 0.0;
      await repository.uploadSelfie(videoFile, onProgress: (p) => progress = p);

      expect(
        fakeS3Client.lastUploadUrl,
        'https://s3.example.com/selfie-upload',
      );
      expect(fakeS3Client.lastMimeType, 'video/mp4');
      expect(fakeDataSource.completeSelfieUploadCalled, isTrue);
      expect(fakeDataSource.lastCompletedFileId, 'file-selfie-1');
      expect(progress, 1.0);
    });

    test('checkImageQuality delegates to remoteDataSource', () async {
      final result = await repository.checkImageQuality();
      expect(result.success, isTrue);
      expect(result.status, 'passed');
    });

    test('checkVideoQuality delegates to remoteDataSource', () async {
      final result = await repository.checkVideoQuality();
      expect(result.success, isTrue);
      expect(result.status, 'passed');
    });

    test('extractMrz delegates to remoteDataSource', () async {
      final result = await repository.extractMrz();
      expect(result.documentNumber, 'P12345678');
      expect(result.firstName, 'JOHN');
    });

    test(
      'confirmMrz converts domain payload to DTO and calls remoteDataSource',
      () async {
        const payload = ConfirmMrzPayload(
          firstName: 'JOHN',
          lastName: 'DOE',
          passportNumber: 'P12345678',
          nationality: 'USA',
          dateOfBirth: '1990-01-01',
          dateOfExpiry: '2030-01-01',
        );

        await repository.confirmMrz(payload);

        expect(fakeDataSource.lastConfirmPayload, isNotNull);
        expect(fakeDataSource.lastConfirmPayload!.firstName, 'JOHN');
        expect(fakeDataSource.lastConfirmPayload!.passportNumber, 'P12345678');
      },
    );

    test('submitVerification forwards nfcPayload', () async {
      final result = await repository.submitVerification(
        nfcPayload: {'chip': 'ok'},
      );
      expect(result.verificationJobId, 'job-123');
      expect(fakeDataSource.lastNfcPayload, equals({'chip': 'ok'}));
    });

    test('getVerificationStatus delegates to remoteDataSource', () async {
      final status = await repository.getVerificationStatus();
      expect(status.status, 'approved');
    });

    test('getVerificationJob delegates to remoteDataSource', () async {
      final job = await repository.getVerificationJob('job-123');
      expect(job.status, 'succeeded');
    });

    test('getVerificationChallenge converts DTO to domain', () async {
      final challenge = await repository.getVerificationChallenge();
      expect(challenge, isA<VerificationChallenge>());
      expect(challenge.challengeId, 'chal-1');
      expect(challenge.challengeType, 'turn_head');
      expect(challenge.instructions, 'Turn head left');
      expect(challenge.timeoutSeconds, 20);
    });

    test('maps DioException to AppException on error', () async {
      fakeDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'detail': 'Unauthorized'},
        ),
      );

      expect(
        () => repository.checkImageQuality(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
