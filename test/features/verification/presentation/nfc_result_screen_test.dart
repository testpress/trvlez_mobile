import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_result_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

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
          child: const MaterialApp(home: NfcResultScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Image.memory is rendered
      expect(find.byType(Image), findsOneWidget);

      // Verify verified checkmark badge icon is displayed on the photo frame
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify MRZ details are shown
      expect(find.text('P12345678'), findsOneWidget);
      expect(find.text('JOHN DOE'), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Passport Authenticated'), findsOneWidget);

      // Verify generic checkmark circle is NOT displayed when image is present
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    },
  );

  testWidgets('falls back to checkmark circle when faceImageBytes is null', (
    tester,
  ) async {
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
        child: const MaterialApp(home: NfcResultScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify no Image widget
    expect(find.byType(Image), findsNothing);

    // Verify generic checkmark icon is displayed
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Verify details still shown
    expect(find.text('P12345678'), findsOneWidget);
    expect(find.text('JOHN DOE'), findsOneWidget);
  });
}
