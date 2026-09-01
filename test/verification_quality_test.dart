import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/profile/domain/profile.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_actors.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

import 'fixtures/fake_verification_repository.dart';

void main() {
  group('Verification Actors & Quality Pipeline', () {
    late FakeVerificationRepository fakeRepo;
    late FakeProfileRepository fakeProfileRepo;

    setUp(() {
      fakeRepo = FakeVerificationRepository();
      fakeProfileRepo = FakeProfileRepository();
    });

    test(
      'PassportUploadActor with PASS quality emits full event chain',
      () async {
        const actor = PassportUploadActor();
        final events = <VerificationEvent>[];

        await actor.execute(
          imageFile: File('dummy_passport.jpg'),
          repository: fakeRepo,
          emit: events.add,
        );

        expect(fakeRepo.uploadPassportCalled, isTrue);
        expect(fakeRepo.checkImageQualityCalled, isTrue);
        expect(fakeRepo.extractMrzCalled, isTrue);

        expect(events.length, equals(4));
        expect(events[0], isA<PassportUploadProgressUpdate>());
        expect(
          (events[0] as PassportUploadProgressUpdate).progress,
          equals(1.0),
        );
        expect(events[1], isA<PassportUploaded>());
        expect(events[2], isA<PassportQualityPassed>());
        expect(events[3], isA<MrzExtracted>());

        final mrzEvent = events[3] as MrzExtracted;
        expect(mrzEvent.result.documentNumber, equals('AB1234567'));
      },
    );

    test(
      'PassportUploadActor with FAIL quality stops before MRZ extraction',
      () async {
        fakeRepo.imageQualityResult = ImageQualityResult(
          success: true,
          status: 'failed',
          isAcceptable: false,
          uiGuidance:
              'The passport photo is too blurry. Please retake the photo.',
          failureReasons: [
            QualityFailureReason(
              code: 'IMAGE_TOO_BLURRY',
              message: 'Image is too blurry',
            ),
          ],
        );

        const actor = PassportUploadActor();
        final events = <VerificationEvent>[];

        await actor.execute(
          imageFile: File('blurry_passport.jpg'),
          repository: fakeRepo,
          emit: events.add,
        );

        expect(fakeRepo.uploadPassportCalled, isTrue);
        expect(fakeRepo.checkImageQualityCalled, isTrue);
        expect(
          fakeRepo.extractMrzCalled,
          isFalse,
          reason: 'MRZ extraction must not run if image quality failed',
        );

        expect(events.any((e) => e is PassportQualityFailed), isTrue);
        final failEvent =
            events.firstWhere((e) => e is PassportQualityFailed)
                as PassportQualityFailed;
        expect(failEvent.message, contains('blurry'));
      },
    );

    test(
      'VideoUploadActor with PASS video quality emits full video event chain',
      () async {
        const actor = VideoUploadActor();
        final events = <VerificationEvent>[];

        await actor.execute(
          videoFile: File('selfie.mp4'),
          repository: fakeRepo,
          emit: events.add,
        );

        expect(fakeRepo.uploadSelfieCalled, isTrue);
        expect(fakeRepo.checkVideoQualityCalled, isTrue);

        expect(events.length, equals(3));
        expect(events[0], isA<SelfieUploadProgressUpdate>());
        expect(events[1], isA<SelfieUploaded>());
        expect(events[2], isA<SelfieQualityPassed>());
      },
    );

    test(
      'VideoUploadActor with FAIL video quality emits SelfieQualityFailed with guidance',
      () async {
        fakeRepo.videoQualityResult = VideoQualityResult(
          success: true,
          status: 'failed',
          isAcceptable: false,
          uiGuidance:
              'Your selfie video is too blurry. Hold your phone steady.',
          failureReasons: [
            QualityFailureReason(
              code: 'VIDEO_TOO_BLURRY',
              message: 'Too many blurry frames',
            ),
          ],
        );

        const actor = VideoUploadActor();
        final events = <VerificationEvent>[];

        await actor.execute(
          videoFile: File('blurry_selfie.mp4'),
          repository: fakeRepo,
          emit: events.add,
        );

        expect(fakeRepo.uploadSelfieCalled, isTrue);
        expect(fakeRepo.checkVideoQualityCalled, isTrue);

        expect(events.any((e) => e is SelfieQualityFailed), isTrue);
        final failEvent =
            events.firstWhere((e) => e is SelfieQualityFailed)
                as SelfieQualityFailed;
        expect(failEvent.message, contains('blurry'));
      },
    );

    test(
      'SubmitActor executes submission and emits SubmissionAccepted',
      () async {
        const actor = SubmitActor();
        final events = <VerificationEvent>[];

        await actor.execute(
          nfcPayload: {'auth_method': 'BAC'},
          repository: fakeRepo,
          emit: events.add,
        );

        expect(fakeRepo.submitVerificationCalled, isTrue);
        expect(events.length, equals(1));
        expect(events[0], isA<SubmissionAccepted>());
        expect((events[0] as SubmissionAccepted).jobId, equals('fake-job-1'));
      },
    );

    test(
      'SubmitActor detects 409 already verified and emits AlreadyVerifiedDetected',
      () async {
        final conflictRepo = FakeConflictVerificationRepository();
        const actor = SubmitActor();
        final events = <VerificationEvent>[];

        await actor.execute(repository: conflictRepo, emit: events.add);

        expect(events.length, equals(1));
        expect(events[0], isA<AlreadyVerifiedDetected>());
      },
    );

    test('ReconciliationActor reconciles backend status and profile', () async {
      fakeRepo.verificationStatus = VerificationStatus(
        sessionId: 'sess-active',
        status: 'verified',
        passportUploaded: true,
        videoUploaded: true,
      );
      fakeProfileRepo.profile = const Profile(
        id: 'usr-1',
        onboardingStep: 'verified',
      );

      const actor = ReconciliationActor();
      final events = <VerificationEvent>[];

      await actor.execute(
        verificationRepository: fakeRepo,
        profileRepository: fakeProfileRepo,
        emit: events.add,
      );

      expect(events.length, equals(1));
      expect(events[0], isA<BackendReconciled>());
      final rec = events[0] as BackendReconciled;
      expect(rec.status.sessionId, equals('sess-active'));
      expect(rec.profile.onboardingStep, equals('verified'));
    });
  });
}

class FakeConflictVerificationRepository extends FakeVerificationRepository {
  @override
  Future<VerificationSubmitResult> submitVerification({
    Map<String, dynamic>? nfcPayload,
  }) async {
    throw const ApiException('User is already verified.', statusCode: 409);
  }
}
