import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';

/// Status of NFC hardware on the current device.
enum NfcDeviceStatus { available, disabled, unsupported }

/// Abstract interface for NFC communication with passport chip.
abstract interface class NfcPassportService {
  /// Checks whether NFC hardware is available and enabled on the device.
  Future<NfcDeviceStatus> getNfcStatus();

  /// Initiates reading session with the passport chip.
  Future<NfcPassportResult> readPassport({
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(NfcReadProgress progress) onProgress,
  });
}
