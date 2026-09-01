import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/profile/domain/profile.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/data/verification_storage.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_state_machine.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VerificationStateMachine Core Transitions', () {
    const sm = VerificationStateMachine();

    test(
      'Initial uninitialized state transitions to passport capture on StartVerification',
      () {
        const initial = VerificationStateUninitialized();
        final next = sm.transition(initial, const StartVerification());

        expect(next, isA<VerificationStatePassportCapture>());
        expect(
          next.effectiveTravelerState,
          equals(TravelerVerificationState.verificationStarted),
        );
        expect(next.progressIndex, equals(0));
      },
    );

    test(
      'PassportCaptured transitions to PassportProcessing with uploading stage',
      () {
        const initial = VerificationStatePassportCapture(
          durableData: VerificationDurableData.empty,
        );
        final dummyFile = File('passport.jpg');
        final next = sm.transition(initial, PassportCaptured(dummyFile));

        expect(next, isA<VerificationStatePassportProcessing>());
        final procState = next as VerificationStatePassportProcessing;
        expect(procState.stage, equals(PassportProcessingSubStage.uploading));
        expect(procState.passportImage, equals(dummyFile));
      },
    );

    test('Passport S3 Upload and Quality Pipeline Transitions', () {
      final dummyFile = File('passport.jpg');
      var state = sm.transition(
        const VerificationStatePassportCapture(
          durableData: VerificationDurableData.empty,
        ),
        PassportCaptured(dummyFile),
      );

      // Progress updates
      state = sm.transition(state, const PassportUploadProgressUpdate(0.5));
      expect(
        (state as VerificationStatePassportProcessing).uploadProgress,
        equals(0.5),
      );

      // Upload completed -> checking quality
      state = sm.transition(state, const PassportUploaded('passport_file_123'));
      expect(
        (state as VerificationStatePassportProcessing).stage,
        equals(PassportProcessingSubStage.checkingQuality),
      );

      // Quality passed -> extracting MRZ
      final qualityResult = ImageQualityResult(
        success: true,
        status: 'passed',
        isAcceptable: true,
      );
      state = sm.transition(state, PassportQualityPassed(qualityResult));
      expect(
        (state as VerificationStatePassportProcessing).stage,
        equals(PassportProcessingSubStage.extractingMrz),
      );

      // MRZ Extracted -> MrzReview
      final mrzResult = MrzExtractionResult(
        success: true,
        documentNumber: 'AB9876543',
        nationality: 'CAN',
        dateOfBirth: '1992-05-10',
        dateOfExpiry: '2032-05-10',
        firstName: 'ALICE',
        lastName: 'SMITH',
      );
      state = sm.transition(state, MrzExtracted(mrzResult));
      expect(state, isA<VerificationStateMrzReview>());
      expect(state.mrzResult?.documentNumber, equals('AB9876543'));
      expect(state.durableData.extractedDocumentNumber, equals('AB9876543'));
    });

    test('MRZ Confirmation and Selfie Recording Transitions', () {
      final dummyPassport = File('passport.jpg');
      final mrzResult = MrzExtractionResult(
        success: true,
        documentNumber: 'AB9876543',
        nationality: 'CAN',
      );
      var state = sm.transition(
        VerificationStateMrzReview(
          durableData: const VerificationDurableData(
            extractedDocumentNumber: 'AB9876543',
          ),
          mrzExtractionResult: mrzResult,
          passportImage: dummyPassport,
        ),
        const ConfirmMrzRequested(),
      );
      expect(state, isA<VerificationStateConfirmingMrz>());

      state = sm.transition(state, const MrzConfirmed());
      expect(state, isA<VerificationStateSelfieInstruction>());
      expect(
        state.effectiveTravelerState,
        equals(TravelerVerificationState.passportReviewed),
      );
      expect(state.progressIndex, equals(2));

      state = sm.transition(state, const StartSelfieCapture());
      expect(state, isA<VerificationStateSelfieCapture>());

      final dummyVideo = File('selfie.mp4');
      state = sm.transition(state, SelfieCaptured(dummyVideo));
      expect(state, isA<VerificationStateSelfieProcessing>());
      expect(
        (state as VerificationStateSelfieProcessing).stage,
        equals(SelfieProcessingSubStage.uploading),
      );

      state = sm.transition(state, const SelfieUploaded('video_file_456'));
      expect(
        (state as VerificationStateSelfieProcessing).stage,
        equals(SelfieProcessingSubStage.checkingQuality),
      );

      final videoQuality = VideoQualityResult(
        success: true,
        status: 'passed',
        isAcceptable: true,
      );
      state = sm.transition(state, SelfieQualityPassed(videoQuality));
      expect(state, isA<VerificationStateNfcIntro>());
      expect(
        state.effectiveTravelerState,
        equals(TravelerVerificationState.documentsUploaded),
      );
      expect(state.progressIndex, equals(3));
    });

    test('NFC Skip and Immediate Submission', () {
      const state = VerificationStateNfcIntro(
        durableData: VerificationDurableData(
          extractedDocumentNumber: 'AB9876543',
        ),
      );

      final next = sm.transition(state, const SubmitRequested(isSkipped: true));
      expect(next, isA<VerificationStateSubmitting>());
      expect((next as VerificationStateSubmitting).isNfcSkipped, isTrue);

      final accepted = sm.transition(next, const SubmissionAccepted('job-999'));
      expect(accepted, isA<VerificationStateProcessing>());
      expect(
        (accepted as VerificationStateProcessing).jobId,
        equals('job-999'),
      );
      expect(accepted.isProcessing, isTrue);
      expect(accepted.progressIndex, equals(4));
    });

    test('NFC Scan Completion and Submit Payload', () {
      const state = VerificationStateNfcScanning(
        durableData: VerificationDurableData(
          extractedDocumentNumber: 'AB9876543',
        ),
      );
      final nfcResult = NfcPassportResult(
        rawDgBytesBase64: {'dg1': 'base64bytes'},
        authMethod: NfcAuthMethod.bac,
        availableDataGroups: ['dg1', 'dg2'],
        parsedMrz: NfcMrzData(
          documentNumber: 'AB9876543',
          documentCode: 'P',
          dateOfBirth: DateTime(1990, 1, 1),
          dateOfExpiry: DateTime(2030, 1, 1),
          nationality: 'CAN',
          country: 'CAN',
          firstName: 'JOHN',
          lastName: 'DOE',
          gender: 'M',
        ),
      );

      final reviewState = sm.transition(state, NfcScanCompleted(nfcResult));
      expect(reviewState, isA<VerificationStateNfcResult>());
      expect(
        reviewState.nfcResult?.parsedMrz?.documentNumber,
        equals('AB9876543'),
      );

      final submitState = sm.transition(reviewState, const SubmitRequested());
      expect(submitState, isA<VerificationStateSubmitting>());
      expect(
        (submitState as VerificationStateSubmitting).isNfcSkipped,
        isFalse,
      );
    });

    test('Verification Job Polling Completion (Verified vs Failed)', () {
      const processing = VerificationStateProcessing(
        durableData: VerificationDurableData(jobId: 'job-123'),
        jobId: 'job-123',
      );

      // Verified
      final verified = sm.transition(
        processing,
        const VerificationJobCompleted(isVerified: true, score: 96.5),
      );
      expect(verified, isA<VerificationStateVerified>());
      expect(
        (verified as VerificationStateVerified).verificationScore,
        equals(96.5),
      );
      expect(verified.isVerified, isTrue);
      expect(verified.progressIndex, equals(4));

      // Failed
      final failed = sm.transition(
        processing,
        const VerificationJobFailed(
          errorReason: 'Face mismatch between passport and selfie',
          failedStep: 'face_match',
          uiMitigation: 'Please ensure your face is well-lit and unobstructed.',
        ),
      );
      expect(failed, isA<VerificationStateFailed>());
      final failState = failed as VerificationStateFailed;
      expect(failState.errorReason, contains('Face mismatch'));
      expect(failState.failedStep, equals('face_match'));
      expect(failState.uiMitigation, contains('well-lit'));
      expect(failState.isFailed, isTrue);
    });
  });

  group('Domain Transition Guards & Conflict Recovery', () {
    const sm = VerificationStateMachine();

    test(
      'Guards prevent invalid duplicate submission when already verified or processing',
      () {
        const verifiedState = VerificationStateVerified(
          durableData: VerificationDurableData.empty,
          verificationScore: 98.0,
        );
        // Attempting to submit or capture again while verified stays verified
        expect(
          sm.transition(verifiedState, const SubmitRequested()),
          equals(verifiedState),
        );
        expect(
          sm.transition(verifiedState, const StartVerification()),
          equals(verifiedState),
        );

        const processingState = VerificationStateProcessing(
          durableData: VerificationDurableData(jobId: 'job-100'),
          jobId: 'job-100',
        );
        // Attempting duplicate submit while already processing stays processing
        expect(
          sm.transition(processingState, const SubmitRequested()),
          equals(processingState),
        );
      },
    );

    test(
      '409 Conflict "User is already verified" transitions to Verified state',
      () {
        const state = VerificationStateNotStarted();
        final next = sm.transition(state, const AlreadyVerifiedDetected(95.0));

        expect(next, isA<VerificationStateVerified>());
        expect(
          (next as VerificationStateVerified).verificationScore,
          equals(95.0),
        );
        expect(
          next.effectiveTravelerState,
          equals(TravelerVerificationState.verified),
        );
      },
    );

    test('Universal ResetRequested purges state back to NotStarted', () {
      const failedState = VerificationStateFailed(
        durableData: VerificationDurableData(jobId: 'job-fail'),
        errorReason: 'Blurry photo',
      );

      final reset = sm.transition(failedState, const ResetRequested());
      expect(reset, isA<VerificationStateNotStarted>());
      expect(reset.durableData.jobId, isNull);
    });

    test(
      'ReconcileRequested transitions to Reconciling without interrupting active upload',
      () {
        const notStarted = VerificationStateNotStarted();
        expect(
          sm.transition(notStarted, const ReconcileRequested()),
          isA<VerificationStateReconciling>(),
        );

        final uploading = VerificationStatePassportProcessing(
          durableData: VerificationDurableData.empty,
          stage: PassportProcessingSubStage.uploading,
          passportImage: File('test.jpg'),
        );
        // Unforced reconciliation does NOT cancel in-flight upload
        expect(
          sm.transition(uploading, const ReconcileRequested(force: false)),
          equals(uploading),
        );
        // Forced reconciliation transitions to reconciling
        expect(
          sm.transition(uploading, const ReconcileRequested(force: true)),
          isA<VerificationStateReconciling>(),
        );
      },
    );
  });

  group('Authoritative Backend Reconciliation Mapping', () {
    const sm = VerificationStateMachine();

    test(
      'Backend status "verified" reconciles to VerificationVerifiedState',
      () {
        final status = VerificationStatus(
          sessionId: 'session-123',
          status: 'verified',
          passportUploaded: true,
          videoUploaded: true,
        );
        final profile = Profile(id: 'usr-1', onboardingStep: 'verified');

        final next = sm.transition(
          const VerificationStateUninitialized(),
          BackendReconciled(status: status, profile: profile),
        );

        expect(next, isA<VerificationStateVerified>());
        expect(next.durableData.sessionId, equals('session-123'));
      },
    );

    test('Backend status "processing" with job ID launches Polling State', () {
      final status = VerificationStatus(
        sessionId: 'session-456',
        status: 'processing',
        passportUploaded: true,
        videoUploaded: true,
        verificationJobId: 'job-rec-789',
      );
      final profile = Profile(id: 'usr-1', onboardingStep: 'submitted');

      final next = sm.transition(
        const VerificationStateUninitialized(),
        BackendReconciled(status: status, profile: profile),
      );

      expect(next, isA<VerificationStateProcessing>());
      final proc = next as VerificationStateProcessing;
      expect(proc.jobId, equals('job-rec-789'));
      expect(proc.durableData.sessionId, equals('session-456'));
    });

    test(
      'Backend status "failed" reconciles to VerificationFailedState with mitigation',
      () {
        final status = VerificationStatus(
          sessionId: 'session-fail',
          status: 'failed',
          passportUploaded: true,
          videoUploaded: true,
          errorReason: 'Glare on passport MRZ',
          failedStep: 'image_quality',
          uiMitigation: 'Please tilt your phone to avoid glare.',
        );
        final profile = Profile(id: 'usr-1', onboardingStep: 'failed');

        final next = sm.transition(
          const VerificationStateUninitialized(),
          BackendReconciled(status: status, profile: profile),
        );

        expect(next, isA<VerificationStateFailed>());
        final fail = next as VerificationStateFailed;
        expect(fail.errorReason, equals('Glare on passport MRZ'));
        expect(fail.failedStep, equals('image_quality'));
        expect(
          fail.uiMitigation,
          equals('Please tilt your phone to avoid glare.'),
        );
      },
    );

    test(
      'Backend status "passport_reviewed" reconciles to SelfieInstruction with preserved MRZ',
      () {
        final status = VerificationStatus(
          sessionId: 'session-mrz-done',
          status: 'passport_reviewed',
          passportUploaded: true,
          videoUploaded: false,
        );
        final profile = Profile(
          id: 'usr-1',
          onboardingStep: 'passport_reviewed',
          passportNumber: 'Z9876543',
          nationality: 'GBR',
        );

        final next = sm.transition(
          const VerificationStateUninitialized(),
          BackendReconciled(status: status, profile: profile),
        );

        expect(next, isA<VerificationStateSelfieInstruction>());
        expect(next.durableData.extractedDocumentNumber, equals('Z9876543'));
      },
    );
  });

  group('ApiException Robust Unwrapping & Predicates', () {
    test('Unwraps DioException wrapping ApiException', () {
      const inner = ApiException(
        'Verification session expired',
        statusCode: 401,
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: inner,
      );

      final unwrap = ApiException.from(dioEx);
      expect(unwrap.message, equals('Verification session expired'));
      expect(unwrap.statusCode, equals(401));
      expect(unwrap.isSessionExpired, isTrue);
      expect(
        ApiException.extractMessage(dioEx),
        equals('Verification session expired'),
      );
    });

    test('Unwraps FastAPI response detail string', () {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/submit'),
        response: Response(
          requestOptions: RequestOptions(path: '/submit'),
          statusCode: 409,
          data: {'detail': 'User is already verified.'},
        ),
      );

      final unwrap = ApiException.from(dioEx);
      expect(unwrap.statusCode, equals(409));
      expect(unwrap.isConflict, isTrue);
      expect(unwrap.isAlreadyVerified, isTrue);
      expect(unwrap.isAlreadySubmitted, isFalse);
      expect(
        ApiException.extractMessage(dioEx),
        equals('User is already verified.'),
      );
    });

    test('Unwraps FastAPI response detail validation list', () {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/upload'),
        response: Response(
          requestOptions: RequestOptions(path: '/upload'),
          statusCode: 422,
          data: {
            'detail': [
              {'msg': 'File size exceeds maximum allowed'},
              {'msg': 'Invalid content type'},
            ],
          },
        ),
      );

      final unwrap = ApiException.from(dioEx);
      expect(unwrap.statusCode, equals(422));
      expect(unwrap.message, contains('File size exceeds maximum allowed'));
      expect(unwrap.message, contains('Invalid content type'));
    });

    test(
      'Handles timeout and connection errors cleanly without raw transport strings',
      () {
        final timeoutEx = DioException(
          requestOptions: RequestOptions(path: '/upload'),
          type: DioExceptionType.connectionTimeout,
        );

        final unwrap = ApiException.from(timeoutEx);
        expect(unwrap.message, contains('timed out'));
        expect(unwrap.message, isNot(contains('DioException')));
      },
    );
  });

  group('VerificationStorage Persistence & Recovery', () {
    test('Saves and restores durable metadata', () async {
      SharedPreferences.setMockInitialValues({});
      const storage = VerificationStorage();

      final originalData = VerificationDurableData(
        sessionId: 'sess-abc',
        jobId: 'job-xyz',
        lastKnownStatus: 'processing',
        lastReconciledAt: DateTime(2026, 9, 1, 10, 0),
        extractedDocumentNumber: 'DOC-12345',
        verificationScore: 92.5,
      );

      await storage.saveDurableData(originalData);

      final restored = await storage.loadDurableData();
      expect(restored.sessionId, equals('sess-abc'));
      expect(restored.jobId, equals('job-xyz'));
      expect(restored.lastKnownStatus, equals('processing'));
      expect(restored.extractedDocumentNumber, equals('DOC-12345'));
      expect(restored.verificationScore, equals(92.5));

      await storage.clear();
      final cleared = await storage.loadDurableData();
      expect(cleared.sessionId, isNull);
      expect(cleared.jobId, isNull);
    });
  });
}
