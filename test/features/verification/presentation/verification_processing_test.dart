import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/presentation/models/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/models/verification_state.dart';

void main() {
  group('ProcessingStage.forPassport', () {
    test('uploading phase maps to uploading stage with correct text', () {
      final stage = ProcessingStage.forPassport(VerificationPhase.uploading);

      expect(stage.type, ProcessingStageType.uploading);
      expect(stage.title, 'Uploading your passport');
      expect(stage.subtitle, contains('securely'));
      expect(stage.isTerminal, isFalse);
    });

    test('checkingImageQuality phase maps to checking stage', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.checkingImageQuality,
      );

      expect(stage.type, ProcessingStageType.checking);
      expect(stage.title, 'Checking your passport');
      expect(stage.subtitle, contains('clear'));
    });

    test('extractingMrz phase maps to reading stage', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.extractingMrz,
      );

      expect(stage.type, ProcessingStageType.reading);
      expect(stage.title, 'Reading your passport');
      expect(stage.subtitle, contains('reading'));
    });

    test('uploadSuccess phase maps to completed stage', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.uploadSuccess,
      );

      expect(stage.type, ProcessingStageType.completed);
      expect(stage.title, 'Passport details ready');
      expect(stage.isTerminal, isTrue);
    });

    test('imageQualityFailed phase maps to failed stage', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.imageQualityFailed,
        errorMessage: 'Image is too blurry.',
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('try'));
      expect(stage.subtitle, 'Image is too blurry.');
      expect(stage.errorMessage, 'Image is too blurry.');
      expect(stage.isTerminal, isTrue);
    });

    test('imageQualityFailed without errorMessage uses default subtitle', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.imageQualityFailed,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.subtitle, contains('clear enough'));
    });

    test('mrzExtractionFailed phase maps to failed stage', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.mrzExtractionFailed,
        errorMessage: 'Could not read MRZ.',
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('try'));
      expect(stage.subtitle, 'Could not read MRZ.');
      expect(stage.isTerminal, isTrue);
    });

    test('error phase maps to failed stage with custom message', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.error,
        errorMessage: 'Network error occurred.',
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, 'Something went wrong');
      expect(stage.subtitle, 'Network error occurred.');
    });

    test('error phase without message uses default subtitle', () {
      final stage = ProcessingStage.forPassport(VerificationPhase.error);

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.subtitle, contains('try'));
    });

    test('idle phase defaults to uploading stage', () {
      final stage = ProcessingStage.forPassport(VerificationPhase.idle);

      expect(stage.type, ProcessingStageType.uploading);
    });

    test('preparingImage phase maps to preparing stage with correct text', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.preparingImage,
      );

      expect(stage.type, ProcessingStageType.preparing);
      expect(stage.title, 'Preparing your passport');
      expect(stage.subtitle, contains('Optimizing'));
      expect(stage.isTerminal, isFalse);
    });

    test('no text contains technical terms', () {
      final phases = [
        VerificationPhase.preparingImage,
        VerificationPhase.uploading,
        VerificationPhase.checkingImageQuality,
        VerificationPhase.extractingMrz,
        VerificationPhase.uploadSuccess,
        VerificationPhase.imageQualityFailed,
        VerificationPhase.mrzExtractionFailed,
      ];

      for (final phase in phases) {
        final stage = ProcessingStage.forPassport(phase);
        final allText = '${stage.title} ${stage.subtitle}'.toLowerCase();

        expect(
          allText,
          isNot(contains('mrz')),
          reason: 'Phase $phase should not expose MRZ terminology',
        );
        expect(
          allText,
          isNot(contains('ocr')),
          reason: 'Phase $phase should not expose OCR terminology',
        );
        expect(
          allText,
          isNot(contains('api')),
          reason: 'Phase $phase should not expose API terminology',
        );
        expect(
          allText,
          isNot(contains('s3')),
          reason: 'Phase $phase should not expose S3 terminology',
        );
        expect(
          allText,
          isNot(contains('quality gate')),
          reason: 'Phase $phase should not expose quality gate terminology',
        );
      }
    });
  });

  group('ProcessingStage.forVideo', () {
    test('uploading phase maps to uploading stage', () {
      final stage = ProcessingStage.forVideo(VerificationPhase.uploading);

      expect(stage.type, ProcessingStageType.uploading);
      expect(stage.title, 'Uploading your video');
      expect(stage.subtitle, contains('Securely'));
    });

    test('checkingVideoQuality phase maps to checking stage', () {
      final stage = ProcessingStage.forVideo(
        VerificationPhase.checkingVideoQuality,
      );

      expect(stage.type, ProcessingStageType.checking);
      expect(stage.title, 'Checking your video');
      expect(stage.subtitle, contains('clear'));
    });

    test('uploadSuccess phase maps to completed stage', () {
      final stage = ProcessingStage.forVideo(VerificationPhase.uploadSuccess);

      expect(stage.type, ProcessingStageType.completed);
      expect(stage.title, 'Video is ready');
      expect(stage.isTerminal, isTrue);
    });

    test('videoQualityFailed phase maps to failed stage', () {
      final stage = ProcessingStage.forVideo(
        VerificationPhase.videoQualityFailed,
        errorMessage: 'Video is too shaky.',
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('record'));
      expect(stage.subtitle, 'Video is too shaky.');
      expect(stage.isTerminal, isTrue);
    });

    test('videoQualityFailed without errorMessage uses default subtitle', () {
      final stage = ProcessingStage.forVideo(
        VerificationPhase.videoQualityFailed,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.subtitle, contains('clear enough'));
    });

    test('error phase maps to failed stage', () {
      final stage = ProcessingStage.forVideo(
        VerificationPhase.error,
        errorMessage: 'Upload failed.',
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, 'Something went wrong');
      expect(stage.subtitle, 'Upload failed.');
    });

    test('no text contains technical terms', () {
      final phases = [
        VerificationPhase.uploading,
        VerificationPhase.checkingVideoQuality,
        VerificationPhase.uploadSuccess,
        VerificationPhase.videoQualityFailed,
      ];

      for (final phase in phases) {
        final stage = ProcessingStage.forVideo(phase);
        final allText = '${stage.title} ${stage.subtitle}'.toLowerCase();

        expect(
          allText,
          isNot(contains('anti-spoofing')),
          reason: 'Phase $phase should not expose anti-spoofing terminology',
        );
        expect(
          allText,
          isNot(contains('face detection')),
          reason: 'Phase $phase should not expose face detection terminology',
        );
        expect(
          allText,
          isNot(contains('api')),
          reason: 'Phase $phase should not expose API terminology',
        );
      }
    });
  });

  group('ProcessingStage intermediate quality-passed stages', () {
    test('passportQualityPassed has correct type and text', () {
      final stage = ProcessingStage.passportQualityPassed;

      expect(stage.type, ProcessingStageType.qualityPassed);
      expect(stage.title, 'Passport image looks good');
      expect(stage.subtitle, contains('read'));
      expect(stage.isTerminal, isFalse);
    });

    test('videoQualityPassed has correct type and text', () {
      final stage = ProcessingStage.videoQualityPassed;

      expect(stage.type, ProcessingStageType.qualityPassed);
      expect(stage.title, 'Video looks good');
      expect(stage.subtitle, contains('clear'));
      expect(stage.isTerminal, isFalse);
    });

    test('qualityPassed stage text contains no technical terms', () {
      for (final stage in [
        ProcessingStage.passportQualityPassed,
        ProcessingStage.videoQualityPassed,
      ]) {
        final allText = '${stage.title} ${stage.subtitle}'.toLowerCase();

        expect(allText, isNot(contains('mrz')));
        expect(allText, isNot(contains('ocr')));
        expect(allText, isNot(contains('api')));
        expect(allText, isNot(contains('quality gate')));
      }
    });
  });

  group('ProcessingStage.stepLabels', () {
    test('passport has 3 steps: Upload, Check, Read', () {
      final labels = ProcessingStage.stepLabels(ProcessingType.passport);

      expect(labels, ['Upload', 'Check', 'Read']);
    });

    test('video has 2 steps: Upload, Check', () {
      final labels = ProcessingStage.stepLabels(ProcessingType.video);

      expect(labels, ['Upload', 'Check']);
    });
  });

  group('ProcessingStage.stepIndex', () {
    test('passport uploading stage is at index 0', () {
      final stage = ProcessingStage.forPassport(VerificationPhase.uploading);
      expect(stage.stepIndex(ProcessingType.passport), 0);
    });

    test('passport checking stage is at index 1', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.checkingImageQuality,
      );
      expect(stage.stepIndex(ProcessingType.passport), 1);
    });

    test('passport qualityPassed stays at index 1', () {
      final stage = ProcessingStage.passportQualityPassed;
      expect(stage.stepIndex(ProcessingType.passport), 1);
    });

    test('passport reading stage is at index 2', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.extractingMrz,
      );
      expect(stage.stepIndex(ProcessingType.passport), 2);
    });

    test('passport completed stage is at last index', () {
      final stage = ProcessingStage.forPassport(
        VerificationPhase.uploadSuccess,
      );
      expect(stage.stepIndex(ProcessingType.passport), 2);
    });

    test('video uploading stage is at index 0', () {
      final stage = ProcessingStage.forVideo(VerificationPhase.uploading);
      expect(stage.stepIndex(ProcessingType.video), 0);
    });

    test('video checking stage is at index 1', () {
      final stage = ProcessingStage.forVideo(
        VerificationPhase.checkingVideoQuality,
      );
      expect(stage.stepIndex(ProcessingType.video), 1);
    });

    test('video qualityPassed stays at index 1', () {
      final stage = ProcessingStage.videoQualityPassed;
      expect(stage.stepIndex(ProcessingType.video), 1);
    });

    test('video completed stage is at last index', () {
      final stage = ProcessingStage.forVideo(VerificationPhase.uploadSuccess);
      expect(stage.stepIndex(ProcessingType.video), 1);
    });
  });
}
