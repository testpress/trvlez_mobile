import 'dart:typed_data';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_image_extractor.dart';

void main() {
  group('NfcImageExtractor', () {
    test('extracts direct JPEG image bytes and trims trailing padding', () {
      // Create a dummy JPEG payload: SOI ... markers ... EOI + padding
      final dummyJpeg = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, // SOI + APP0
        0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00,
        0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
        0xFF, 0xD9, // EOI
        0x00, 0x00, 0x00, 0x00, // Trailing padding
      ]);

      final extracted = NfcImageExtractor.sanitizeImageBytes(dummyJpeg);

      expect(extracted, isNotNull);
      expect(extracted!.length, equals(dummyJpeg.length - 4));
      expect(extracted.sublist(0, 3), equals([0xFF, 0xD8, 0xFF]));
      expect(extracted.sublist(extracted.length - 2), equals([0xFF, 0xD9]));
    });

    test('extracts JPEG image when offset by leading headers', () {
      final dummyPayload = Uint8List.fromList([
        0x00, 0x12, 0x34, 0x56, // Leading header/metadata
        0xFF, 0xD8, 0xFF, 0xE0, // SOI
        0x12, 0x34, 0x56, 0x78,
        0xFF, 0xD9, // EOI
        0x00, 0x00, // Trailing padding
      ]);

      final extracted = NfcImageExtractor.extractFromBytes(dummyPayload);

      expect(extracted, isNotNull);
      expect(extracted!.sublist(0, 3), equals([0xFF, 0xD8, 0xFF]));
      expect(extracted.sublist(extracted.length - 2), equals([0xFF, 0xD9]));
      expect(extracted.length, equals(10));
    });

    test('extracts JPEG 2000 JP2 image bytes', () {
      final jp2Payload = Uint8List.fromList([
        0x75, 0x20, // Tag 0x75
        0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, // JP2 signature
        0x0D, 0x0A, 0x87, 0x0A,
        0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70,
      ]);

      final extracted = NfcImageExtractor.extractFromBytes(jp2Payload);

      expect(extracted, isNotNull);
      expect(
        extracted!.sublist(0, 8),
        equals([0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20]),
      );
    });

    test('extracts JPEG 2000 J2K codestream bytes', () {
      final j2kPayload = Uint8List.fromList([
        0x01, 0x02, // Prefix
        0xFF, 0x4F, 0xFF, 0x51, // SOC + SIZ marker
        0x00, 0x12, 0x34,
        0xFF, 0xD9, // EOC
        0x00, // Padding
      ]);

      final extracted = NfcImageExtractor.extractFromBytes(j2kPayload);

      expect(extracted, isNotNull);
      expect(extracted!.sublist(0, 4), equals([0xFF, 0x4F, 0xFF, 0x51]));
      expect(extracted.sublist(extracted.length - 2), equals([0xFF, 0xD9]));
    });

    test('returns null for empty or too short byte array', () {
      expect(NfcImageExtractor.extractFromBytes(Uint8List(0)), isNull);
      expect(
        NfcImageExtractor.extractFromBytes(Uint8List.fromList([1, 2, 3])),
        isNull,
      );
    });

    test('returns null when no recognized image signature is found', () {
      final randomBytes = Uint8List.fromList([
        0x10,
        0x20,
        0x30,
        0x40,
        0x50,
        0x60,
      ]);
      expect(NfcImageExtractor.extractFromBytes(randomBytes), isNull);
    });

    test('extractFromDg2 extracts face image from parsed EfDG2', () {
      final jpegBytes = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x01,
        0x02,
        0xFF,
        0xD9,
      ]);

      // Biometric Data Block (Tag 0x5F2E) contents matching ISO/IEC 19794-5
      final bdbHeader = [
        0x46, 0x41, 0x43, 0x00, // Format: FAC\0
        0x30, 0x31, 0x30, 0x00, // Version: 010\0 (0x30313000)
        0x00, 0x00, 0x00, 0x36, // Length of record (4 bytes)
        0x00, 0x01, // Number of facial images: 1
        0x00, 0x00, 0x00, 0x28, // Facial record data length (4 bytes)
        0x00, 0x00, // Number of feature points: 0
        0x01, // Gender: 1
        0x01, // Eye color: 1
        0x01, // Hair color: 1
        0x00, 0x00, 0x00, // Feature mask: 3 bytes
        0x00, 0x00, // Expression: 2 bytes
        0x00, 0x00, 0x00, // Pose angle: 3 bytes
        0x00, 0x00, 0x00, // Pose angle uncertainty: 3 bytes
        0x00, // Face image type: 1 byte
        0x00, // Image data type: 0 (JPEG)
        0x00, 0x10, // Image width: 16
        0x00, 0x10, // Image height: 16
        0x01, // Image color space: 1
        0x01, // Source type: 1
        0x00, 0x01, // Device type: 1
        0x00, 0x64, // Quality: 100
      ];
      final bdbContent = [...bdbHeader, ...jpegBytes];

      // Construct nested TLVs:
      // Tag 0x5F2E: Biometric Data Block
      final bdbTlv = [0x5F, 0x2E, bdbContent.length, ...bdbContent];
      // Tag 0xA1: Biometric Header Template (base)
      final bhtTlv = [0xA1, 0x00];
      // Tag 0x7F60: Biometric Information Template (BIT)
      final bitContent = [...bhtTlv, ...bdbTlv];
      final bitTlv = [0x7F, 0x60, bitContent.length, ...bitContent];
      // Tag 0x02: Biometric Information Count = 1
      final bictTlv = [0x02, 0x01, 0x01];
      // Tag 0x7F61: Biometric Information Group Template (BIGT)
      final bigtContent = [...bictTlv, ...bitTlv];
      final bigtTlv = [0x7F, 0x61, bigtContent.length, ...bigtContent];
      // Tag 0x75: DG2
      final dg2Tlv = Uint8List.fromList([0x75, bigtTlv.length, ...bigtTlv]);

      final dg2 = EfDG2.fromBytes(dg2Tlv);
      final extracted = NfcImageExtractor.extractFromDg2(dg2);

      expect(extracted, isNotNull);
      expect(extracted!.sublist(0, 3), equals([0xFF, 0xD8, 0xFF]));
      expect(extracted.sublist(extracted.length - 2), equals([0xFF, 0xD9]));
    });
  });
}
