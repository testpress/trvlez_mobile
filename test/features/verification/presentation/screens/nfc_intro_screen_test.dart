import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/nfc_intro_screen.dart';

class StubNfcPassportService implements NfcPassportService {
  StubNfcPassportService({this.status = NfcDeviceStatus.available});

  final NfcDeviceStatus status;

  @override
  Future<NfcDeviceStatus> getNfcStatus() async => status;

  @override
  Future<NfcPassportResult> readPassport({
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(NfcReadProgress progress) onProgress,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  Widget createTestWidget({
    required NfcPassportService nfcService,
    required ProviderContainer container,
  }) {
    final testRouter = GoRouter(
      initialLocation: AppRoutes.nfcIntro,
      routes: [
        GoRoute(
          path: AppRoutes.nfcIntro,
          builder: (context, state) => NfcIntroScreen(nfcService: nfcService),
        ),
        GoRoute(
          path: AppRoutes.nfcScan,
          builder: (context, state) =>
              const Scaffold(body: Text('NFC Scan Screen')),
        ),
        GoRoute(
          path: AppRoutes.nfcFinalCheck,
          builder: (context, state) =>
              const Scaffold(body: Text('Final Check Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('NfcIntroScreen - Skip Button & Hardware Availability Tests', () {
    testWidgets(
      'does not render any skip chip scan button in the default UI',
      (tester) async {
        final mockService = StubNfcPassportService(
          status: NfcDeviceStatus.available,
        );
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pumpAndSettle();

        expect(find.text('Start scan'), findsOneWidget);
        expect(find.text('Skip chip scan'), findsNothing);
        expect(find.text('Skip'), findsNothing);

        container.dispose();
      },
    );

    testWidgets(
      'when start scan clicked and NFC is unsupported, displays modal sheet with clear explanation and skip button',
      (tester) async {
        final mockService = StubNfcPassportService(
          status: NfcDeviceStatus.unsupported,
        );
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pumpAndSettle();

        // Click Start scan
        await tester.tap(find.text('Start scan'));
        await tester.pumpAndSettle();

        // Verify bottom sheet appears with explanation
        expect(find.text('NFC Not Supported'), findsOneWidget);
        expect(
          find.text(
            'This device does not have NFC hardware, which is required to scan passport chips. You can continue verification without chip scanning.',
          ),
          findsOneWidget,
        );
        expect(find.text('Continue without chip scan'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Click continue without chip scan
        await tester.tap(find.text('Continue without chip scan'));
        await tester.pumpAndSettle();

        // Verifies skip state was recorded and routed to final check
        expect(container.read(verificationNotifierProvider).isNfcSkipped, isTrue);
        expect(find.text('Final Check Screen'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets(
      'when start scan clicked and NFC is disabled, displays prompt to enable NFC in settings without skip option',
      (tester) async {
        final mockService = StubNfcPassportService(
          status: NfcDeviceStatus.disabled,
        );
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pumpAndSettle();

        // Click Start scan
        await tester.tap(find.text('Start scan'));
        await tester.pumpAndSettle();

        // Verify prompt bottom sheet appears
        expect(find.text('Enable NFC to Continue'), findsOneWidget);
        expect(
          find.text(
            'NFC is turned off on your device. To scan your passport chip, please enable NFC in your device settings.',
          ),
          findsOneWidget,
        );
        expect(find.text('Open NFC Settings'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Crucial: No skip button allowed when NFC is available but disabled
        expect(find.text('Continue without chip scan'), findsNothing);
        expect(find.text('Skip chip scan'), findsNothing);

        container.dispose();
      },
    );

    testWidgets(
      'when start scan clicked and NFC is available, navigates to nfcScan screen',
      (tester) async {
        final mockService = StubNfcPassportService(
          status: NfcDeviceStatus.available,
        );
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(nfcService: mockService, container: container),
        );
        await tester.pumpAndSettle();

        // Click Start scan
        await tester.tap(find.text('Start scan'));
        await tester.pumpAndSettle();

        expect(find.text('NFC Scan Screen'), findsOneWidget);

        container.dispose();
      },
    );
  });
}
