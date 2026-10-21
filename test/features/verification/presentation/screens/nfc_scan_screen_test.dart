import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/nfc_scan_screen.dart';

class MockNfcPassportService implements NfcPassportService {
  void Function(NfcReadProgress progress)? progressCallback;
  Completer<NfcPassportResult> readCompleter = Completer<NfcPassportResult>();

  @override
  Future<NfcDeviceStatus> getNfcStatus() async => NfcDeviceStatus.available;

  @override
  Future<NfcPassportResult> readPassport({
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(NfcReadProgress progress) onProgress,
  }) {
    progressCallback = onProgress;
    return readCompleter.future;
  }
}

void main() {
  Widget createTestWidget({
    required NfcPassportService nfcService,
    required ProviderContainer container,
  }) {
    final testRouter = GoRouter(
      initialLocation: AppRoutes.nfcScan,
      routes: [
        GoRoute(
          path: AppRoutes.nfcScan,
          builder: (context, state) => NfcScanScreen(nfcService: nfcService),
        ),
        GoRoute(
          path: AppRoutes.chipData,
          builder: (context, state) =>
              const Scaffold(body: Text('Chip Data Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  ProviderContainer createInitializedContainer() {
    final container = ProviderContainer();
    container
        .read(verificationNotifierProvider.notifier)
        .setExtractedMrz(
          'P12345678',
          DateTime(1990, 1, 1),
          DateTime(2030, 1, 1),
        );
    return container;
  }

  group('NfcScanScreen progress behavior', () {
    testWidgets(
      'initially renders "Ready to scan" and does not start with 8% or numeric percentage',
      (tester) async {
        final mockService = MockNfcPassportService();
        final container = createInitializedContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pump();

        expect(find.text('Ready to scan'), findsOneWidget);
        expect(find.text('8%'), findsNothing);
        expect(find.text('0%'), findsNothing);
        expect(find.text('Hold near passport'), findsOneWidget);

        final progressFinder = find.byType(LinearProgressIndicator);
        expect(progressFinder, findsOneWidget);
        final progress = tester.widget<LinearProgressIndicator>(progressFinder);
        expect(progress.value, equals(0.0));

        container.dispose();
      },
    );

    testWidgets(
      'smoothly displays step description and live percentage once reading progresses',
      (tester) async {
        final mockService = MockNfcPassportService();
        final container = createInitializedContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pump();

        // 1. Connecting (0.0) -> Still waiting
        mockService.progressCallback?.call(
          const NfcReadProgress(
            currentStep: NfcReadStep.connecting,
            percentage: 0.0,
            description: 'Waiting for passport...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Ready to scan'), findsOneWidget);
        expect(find.text('8%'), findsNothing);

        // 2. Reading Card Access (10%) -> Reading starts
        mockService.progressCallback?.call(
          const NfcReadProgress(
            currentStep: NfcReadStep.readingCardAccess,
            percentage: 0.1,
            description: 'Connecting to chip...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Connecting to chip...'), findsOneWidget);
        expect(find.text('10%'), findsOneWidget);
        expect(find.text('Reading chip…'), findsOneWidget);

        // 3. Reading DG2 Face Image (60%)
        mockService.progressCallback?.call(
          const NfcReadProgress(
            currentStep: NfcReadStep.readingDg2,
            percentage: 0.6,
            description: 'Reading face image...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Reading face image...'), findsOneWidget);
        expect(find.text('60%'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets('finishes reading at 100% and routes to chip data screen', (
      tester,
    ) async {
      final mockService = MockNfcPassportService();
      final container = createInitializedContainer();

      await tester.pumpWidget(
        createTestWidget(nfcService: mockService, container: container),
      );
      await tester.pump();

      mockService.progressCallback?.call(
        const NfcReadProgress(
          currentStep: NfcReadStep.complete,
          percentage: 1.0,
          description: 'Finished',
        ),
      );
      mockService.readCompleter.complete(
        const NfcPassportResult(
          rawDgBytesBase64: {},
          sodBytesBase64: '',
          comBytesBase64: '',
          authMethod: NfcAuthMethod.bac,
          availableDataGroups: [],
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Chip Data Screen'), findsOneWidget);

      container.dispose();
    });
  });
}
