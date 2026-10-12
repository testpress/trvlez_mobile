import 'dart:typed_data';

import 'package:dmrtd/dmrtd.dart';

/// Utility class for extracting displayable face image bytes from EF.DG2.
///
/// Supports extracting and trimming JPEG images (`0xFF 0xD8 ... 0xFF 0xD9`)
/// as well as identifying JPEG 2000 images (`JP2` / `J2K`) from parsed
/// [EfDG2] instances or raw DG2 byte streams.
class NfcImageExtractor {
  const NfcImageExtractor._();

  /// Extracts displayable face image bytes from a parsed [EfDG2] data group.
  ///
  /// Checks [EfDG2.imageData] first, and falls back to scanning the entire
  /// raw DG2 payload if [EfDG2.imageData] is null or unparsed.
  static Uint8List? extractFromDg2(EfDG2 dg2) {
    final imageData = dg2.imageData;
    if (imageData != null && imageData.isNotEmpty) {
      final sanitized = sanitizeImageBytes(imageData);
      if (sanitized != null) {
        return sanitized;
      }
    }

    return extractFromBytes(dg2.toBytes());
  }

  /// Scans arbitrary DG2 raw bytes to locate embedded image data.
  ///
  /// Identifies standard JPEG markers (SOI `0xFF 0xD8 0xFF` to EOI `0xFF 0xD9`),
  /// JP2 header boxes, or J2K codestreams.
  static Uint8List? extractFromBytes(Uint8List rawBytes) {
    if (rawBytes.length < 4) return null;

    // 1. Search for JPEG SOI marker (0xFF 0xD8 0xFF)
    for (int i = 0; i < rawBytes.length - 2; i++) {
      if (rawBytes[i] == 0xFF &&
          rawBytes[i + 1] == 0xD8 &&
          rawBytes[i + 2] == 0xFF) {
        // Find last EOI marker (0xFF 0xD9)
        for (int j = rawBytes.length - 2; j >= i + 2; j--) {
          if (rawBytes[j] == 0xFF && rawBytes[j + 1] == 0xD9) {
            return Uint8List.sublistView(rawBytes, i, j + 2);
          }
        }
        return Uint8List.sublistView(rawBytes, i);
      }
    }

    // 2. Search for JPEG 2000 JP2 signature (0x00 00 00 0C 6A 50 20 20)
    const jp2Sig = [0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20];
    for (int i = 0; i <= rawBytes.length - jp2Sig.length; i++) {
      bool match = true;
      for (int k = 0; k < jp2Sig.length; k++) {
        if (rawBytes[i + k] != jp2Sig[k]) {
          match = false;
          break;
        }
      }
      if (match) {
        return Uint8List.sublistView(rawBytes, i);
      }
    }

    // 3. Search for JPEG 2000 J2K codestream (0xFF 4F FF 51)
    for (int i = 0; i < rawBytes.length - 3; i++) {
      if (rawBytes[i] == 0xFF &&
          rawBytes[i + 1] == 0x4F &&
          rawBytes[i + 2] == 0xFF &&
          rawBytes[i + 3] == 0x51) {
        for (int j = rawBytes.length - 2; j >= i + 4; j--) {
          if (rawBytes[j] == 0xFF && rawBytes[j + 1] == 0xD9) {
            return Uint8List.sublistView(rawBytes, i, j + 2);
          }
        }
        return Uint8List.sublistView(rawBytes, i);
      }
    }

    return null;
  }

  /// Sanitizes image bytes by locating standard markers and stripping padding.
  static Uint8List? sanitizeImageBytes(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // Direct JPEG SOI at start
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      for (int i = bytes.length - 2; i >= 2; i--) {
        if (bytes[i] == 0xFF && bytes[i + 1] == 0xD9) {
          return Uint8List.sublistView(bytes, 0, i + 2);
        }
      }
      return bytes;
    }

    // Offset JPEG SOI (0xFF 0xD8 0xFF)
    for (int i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8 && bytes[i + 2] == 0xFF) {
        for (int j = bytes.length - 2; j >= i + 2; j--) {
          if (bytes[j] == 0xFF && bytes[j + 1] == 0xD9) {
            return Uint8List.sublistView(bytes, i, j + 2);
          }
        }
        return Uint8List.sublistView(bytes, i);
      }
    }

    // JPEG 2000
    if (isJpeg2000(bytes)) {
      return bytes;
    }

    return bytes;
  }

  /// Checks whether [bytes] match JPEG 2000 signatures.
  static bool isJpeg2000(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x00 &&
        bytes[1] == 0x00 &&
        bytes[2] == 0x00 &&
        bytes[3] == 0x0C &&
        bytes[4] == 0x6A &&
        bytes[5] == 0x50 &&
        bytes[6] == 0x20 &&
        bytes[7] == 0x20) {
      return true;
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0x4F &&
        bytes[2] == 0xFF &&
        bytes[3] == 0x51) {
      return true;
    }
    return false;
  }
}
