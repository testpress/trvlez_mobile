import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

import 'fixtures/fake_verification_repository.dart';

void main() {
  group('VerificationNotifier Quality Checks', () {
    late FakeVerificationRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeVerificationRepository();
      container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Passport upload with PASS image quality triggers MRZ extraction', () async {
      final notifier = container.read(verificationNotifierProvider.notifier);
      final dummyFile = File('dummy_passport.jpg');

      notifier.setImage(dummyFile);
      expect(container.read(verificationNotifierProvider).capturedImage, dummyFile);

      await notifier.uploadPassport();

      final state = container.read(verificationNotifierProvider);
      expect(fakeRepo.uploadPassportCalled, isTrue);
      expect(fakeRepo.checkImageQualityCalled, isTrue);
      expect(fakeRepo.extractMrzCalled, isTrue);
      expect(state.phase, equals(VerificationPhase.uploadSuccess));
      expect(state.imageQualityResult?.isAcceptable, isTrue);
      expect(state.mrzExtractionResult, isNotNull);
      expect(state.extractedDocumentNumber, equals('AB1234567'));
    });

    test('Passport upload with FAIL image quality stops before MRZ extraction', () async {
      fakeRepo.imageQualityResult = ImageQualityResult(
        success: true,
        status: 'failed',
        isAcceptable: false,
        uiGuidance: 'The passport photo is too blurry. Please retake the photo.',
        failureReasons: [
          QualityFailureReason(
            code: 'IMAGE_TOO_BLURRY',
            message: 'Image is too blurry',
          ),
        ],
      );

      final notifier = container.read(verificationNotifierProvider.notifier);
      final dummyFile = File('blurry_passport.jpg');

      notifier.setImage(dummyFile);
      await notifier.uploadPassport();

      final state = container.read(verificationNotifierProvider);
      expect(fakeRepo.uploadPassportCalled, isTrue);
      expect(fakeRepo.checkImageQualityCalled, isTrue);
      expect(fakeRepo.extractMrzCalled, isFalse, reason: 'MRZ extraction should not run if quality check fails');
      expect(state.phase, equals(VerificationPhase.imageQualityFailed));
      expect(state.errorMessage, contains('blurry'));
      expect(notifier.status, equals(VerificationActionStatus.error));
    });

    test('Selfie upload with PASS video quality proceeds to uploadSuccess', () async {
      final notifier = container.read(verificationNotifierProvider.notifier);
      final dummyVideo = File('selfie.mp4');

      notifier.setVideo(dummyVideo);
      await notifier.uploadSelfie();

      final state = container.read(verificationNotifierProvider);
      expect(fakeRepo.uploadSelfieCalled, isTrue);
      expect(fakeRepo.checkVideoQualityCalled, isTrue);
      expect(state.phase, equals(VerificationPhase.uploadSuccess));
      expect(state.videoQualityResult?.isAcceptable, isTrue);
      expect(notifier.status, equals(VerificationActionStatus.success));
    });

    test('Selfie upload with FAIL video quality stops and sets error guidance', () async {
      fakeRepo.videoQualityResult = VideoQualityResult(
        success: true,
        status: 'failed',
        isAcceptable: false,
        uiGuidance: 'Your selfie video is too blurry. Hold your phone steady.',
        failureReasons: [
          QualityFailureReason(
            code: 'VIDEO_TOO_BLURRY',
            message: 'Too many blurry frames',
          ),
        ],
      );

      final notifier = container.read(verificationNotifierProvider.notifier);
      final dummyVideo = File('blurry_selfie.mp4');

      notifier.setVideo(dummyVideo);
      await notifier.uploadSelfie();

      final state = container.read(verificationNotifierProvider);
      expect(fakeRepo.uploadSelfieCalled, isTrue);
      expect(fakeRepo.checkVideoQualityCalled, isTrue);
      expect(state.phase, equals(VerificationPhase.videoQualityFailed));
      expect(state.errorMessage, contains('blurry'));
      expect(notifier.status, equals(VerificationActionStatus.error));
    });
  });
}
