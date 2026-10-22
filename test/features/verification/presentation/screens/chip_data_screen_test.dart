import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/chip_data_screen.dart';

void main() {
  final testPngBytes = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  final testMrz = NfcMrzData(
    documentNumber: 'P12345678',
    documentCode: 'P',
    firstName: 'JOHN',
    lastName: 'DOE',
    nationality: 'USA',
    country: 'USA',
    gender: 'M',
    dateOfBirth: DateTime(1990, 5, 15),
    dateOfExpiry: DateTime(2030, 5, 15),
  );

  testWidgets(
    'displays face image and verified badge when faceImageBytes is provided',
    (tester) async {
      final resultWithImage = NfcPassportResult(
        rawDgBytesBase64: {'dg1': 'dummy', 'dg2': 'dummy'},
        authMethod: NfcAuthMethod.bac,
        availableDataGroups: ['dg1', 'dg2'],
        parsedMrz: testMrz,
        faceImageBytes: testPngBytes,
      );

      final container = ProviderContainer();
      container
          .read(verificationNotifierProvider.notifier)
          .setNfcResult(resultWithImage);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ChipDataScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Image.memory is rendered
      expect(find.byType(Image), findsOneWidget);

      // Verify 'From the chip' provenance badge is displayed
      expect(find.text('From the chip'), findsOneWidget);

      // Verify MRZ details are shown
      expect(find.text('JOHN DOE'), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Chip scan'), findsOneWidget);
    },
  );

  testWidgets(
    'falls back to chip photo placeholder when faceImageBytes is null',
    (tester) async {
      final resultWithoutImage = NfcPassportResult(
        rawDgBytesBase64: {'dg1': 'dummy'},
        authMethod: NfcAuthMethod.bac,
        availableDataGroups: ['dg1'],
        parsedMrz: testMrz,
        faceImageBytes: null,
      );

      final container = ProviderContainer();
      container
          .read(verificationNotifierProvider.notifier)
          .setNfcResult(resultWithoutImage);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ChipDataScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no Image widget
      expect(find.byType(Image), findsNothing);

      // Verify provenance badge is displayed
      expect(find.text('From the chip'), findsOneWidget);

      // Verify details still shown
      expect(find.text('JOHN DOE'), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Submit verification submits asynchronously and routes via context.go to final check',
    (tester) async {
      final resultWithImage = NfcPassportResult(
        rawDgBytesBase64: {'dg1': 'dummy'},
        authMethod: NfcAuthMethod.bac,
        availableDataGroups: ['dg1'],
        parsedMrz: testMrz,
        faceImageBytes: null,
      );

      final container = ProviderContainer();
      container
          .read(verificationNotifierProvider.notifier)
          .setNfcResult(resultWithImage);

      final router = GoRouter(
        initialLocation: AppRoutes.chipData,
        routes: [
          GoRoute(
            path: AppRoutes.chipData,
            builder: (context, state) => const ChipDataScreen(),
          ),
          GoRoute(
            path: AppRoutes.verificationFinalCheck,
            builder: (context, state) =>
                const Scaffold(body: Text('Final Check Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.text('Submit verification');
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Final Check Screen'), findsOneWidget);
    },
  );
}
