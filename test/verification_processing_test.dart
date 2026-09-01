import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';

void main() {
  group('ProcessingStage.fromWorkflowState for Passport', () {
    test('uploading stage maps to uploading stage with correct text', () {
      const state = VerificationStatePassportProcessing(
        durableData: VerificationDurableData.empty,
        stage: PassportProcessingSubStage.uploading,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.uploading);
      expect(stage.title, 'Uploading your passport');
      expect(stage.subtitle, contains('securely'));
      expect(stage.isTerminal, isFalse);
    });

    test('checkingQuality stage maps to checking stage', () {
      const state = VerificationStatePassportProcessing(
        durableData: VerificationDurableData.empty,
        stage: PassportProcessingSubStage.checkingQuality,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.checking);
      expect(stage.title, 'Checking your passport');
      expect(stage.subtitle, contains('clear'));
    });

    test('extractingMrz stage maps to reading stage', () {
      const state = VerificationStatePassportProcessing(
        durableData: VerificationDurableData.empty,
        stage: PassportProcessingSubStage.extractingMrz,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.reading);
      expect(stage.title, 'Reading your passport');
      expect(stage.subtitle, contains('reading'));
    });

    test('MrzReview state maps to completed stage', () {
      final state = VerificationStateMrzReview(
        durableData: VerificationDurableData.empty,
        mrzExtractionResult: MrzExtractionResult(success: true),
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.completed);
      expect(stage.title, 'Passport details ready');
      expect(stage.isTerminal, isTrue);
    });

    test('PassportQualityFailed state maps to failed stage', () {
      const state = VerificationStatePassportQualityFailed(
        durableData: VerificationDurableData.empty,
        errorMessage: 'Image is too blurry.',
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('try'));
      expect(stage.subtitle, 'Image is too blurry.');
      expect(stage.errorMessage, 'Image is too blurry.');
      expect(stage.isTerminal, isTrue);
    });

    test('MrzExtractionFailed state maps to failed stage', () {
      const state = VerificationStateMrzExtractionFailed(
        durableData: VerificationDurableData.empty,
        errorMessage: 'Could not read MRZ.',
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('try'));
      expect(stage.subtitle, 'Could not read MRZ.');
      expect(stage.isTerminal, isTrue);
    });

    test('Error state maps to failed stage with user message', () {
      const state = VerificationStateError(
        durableData: VerificationDurableData.empty,
        userMessage: 'Network connection failed.',
        previousState: VerificationStateNotStarted(),
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.passport,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, 'Something went wrong');
      expect(stage.subtitle, 'Network connection failed.');
    });
  });

  group('ProcessingStage.fromWorkflowState for Video', () {
    test('Selfie upload stage maps to video uploading stage', () {
      const state = VerificationStateSelfieProcessing(
        durableData: VerificationDurableData.empty,
        stage: SelfieProcessingSubStage.uploading,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.video,
      );

      expect(stage.type, ProcessingStageType.uploading);
      expect(stage.title, 'Uploading your video');
      expect(stage.subtitle, contains('Securely'));
    });

    test('Selfie checkingQuality stage maps to checking stage', () {
      const state = VerificationStateSelfieProcessing(
        durableData: VerificationDurableData.empty,
        stage: SelfieProcessingSubStage.checkingQuality,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.video,
      );

      expect(stage.type, ProcessingStageType.checking);
      expect(stage.title, 'Checking your video');
      expect(stage.subtitle, contains('clear and ready'));
    });

    test('NfcIntro state maps to completed video stage', () {
      const state = VerificationStateNfcIntro(
        durableData: VerificationDurableData.empty,
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.video,
      );

      expect(stage.type, ProcessingStageType.completed);
      expect(stage.title, 'Video is ready');
      expect(stage.isTerminal, isTrue);
    });

    test('SelfieQualityFailed state maps to failed stage', () {
      const state = VerificationStateSelfieQualityFailed(
        durableData: VerificationDurableData.empty,
        errorMessage: 'Face was not detected in the video.',
      );
      final stage = ProcessingStage.fromWorkflowState(
        state,
        ProcessingType.video,
      );

      expect(stage.type, ProcessingStageType.failed);
      expect(stage.title, contains('record'));
      expect(stage.subtitle, 'Face was not detected in the video.');
      expect(stage.errorMessage, 'Face was not detected in the video.');
    });
  });

  group('Intermediate Stages & Step Indicators', () {
    test('passportQualityPassed intermediate stage properties', () {
      const stage = ProcessingStage.passportQualityPassed;
      expect(stage.type, ProcessingStageType.qualityPassed);
      expect(stage.title, 'Passport image looks good');
      expect(stage.isTerminal, isFalse);
    });

    test('videoQualityPassed intermediate stage properties', () {
      const stage = ProcessingStage.videoQualityPassed;
      expect(stage.type, ProcessingStageType.qualityPassed);
      expect(stage.title, 'Video looks good');
      expect(stage.isTerminal, isFalse);
    });

    test('stepLabels for passport and video', () {
      expect(ProcessingStage.stepLabels(ProcessingType.passport), [
        'Upload',
        'Check',
        'Read',
      ]);
      expect(ProcessingStage.stepLabels(ProcessingType.video), [
        'Upload',
        'Check',
      ]);
    });

    test('stepIndex calculation', () {
      const uploadStage = ProcessingStage(
        type: ProcessingStageType.uploading,
        title: '',
        subtitle: '',
      );
      const checkStage = ProcessingStage(
        type: ProcessingStageType.checking,
        title: '',
        subtitle: '',
      );
      const readStage = ProcessingStage(
        type: ProcessingStageType.reading,
        title: '',
        subtitle: '',
      );
      const completedStage = ProcessingStage(
        type: ProcessingStageType.completed,
        title: '',
        subtitle: '',
      );

      expect(uploadStage.stepIndex(ProcessingType.passport), 0);
      expect(checkStage.stepIndex(ProcessingType.passport), 1);
      expect(readStage.stepIndex(ProcessingType.passport), 2);
      expect(completedStage.stepIndex(ProcessingType.passport), 2);

      expect(uploadStage.stepIndex(ProcessingType.video), 0);
      expect(checkStage.stepIndex(ProcessingType.video), 1);
      expect(completedStage.stepIndex(ProcessingType.video), 1);
    });
  });
}
