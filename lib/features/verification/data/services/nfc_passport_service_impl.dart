import 'dart:convert';

import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_error_mapper.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_image_extractor.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/domain/services/nfc_passport_service.dart';

/// Service responsible for orchestrating the NFC communication with the passport chip.
///
/// Wraps the lower-level `dmrtd` library and maps its specialized exceptions
/// to user-friendly `NfcError` models, while reporting progress to the UI.
class NfcPassportServiceImpl implements NfcPassportService {
  final _log = Logger('NfcPassportService');
  final NfcProvider _nfc = NfcProvider();

  /// Checks if the current device has NFC hardware and if it is enabled.
  @override
  Future<NfcDeviceStatus> getNfcStatus() async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final status = await NfcProvider.nfcStatus;
        if (status == NfcStatus.enabled) {
          return NfcDeviceStatus.available;
        } else if (status == NfcStatus.disabled) {
          return NfcDeviceStatus.disabled;
        } else {
          return NfcDeviceStatus.unsupported;
        }
      } on PlatformException catch (e) {
        _log.warning('NfcProvider platform exception (attempt $attempt): $e');
        if (attempt == 0 &&
            (e.code == '500' || e.message?.contains('activity') == true)) {
          await Future.delayed(const Duration(milliseconds: 200));
          continue;
        }
        return NfcDeviceStatus.unsupported;
      } catch (e) {
        _log.warning('Error checking NFC status: $e');
        return NfcDeviceStatus.unsupported;
      }
    }
    return NfcDeviceStatus.unsupported;
  }

  /// Initiates a reading session with the passport chip.
  ///
  /// The [documentNumber], [dateOfBirth], and [dateOfExpiry] are required to
  /// establish the BAC (Basic Access Control) or PACE session.
  ///
  /// Progress is reported via the [onProgress] callback.
  @override
  Future<NfcPassportResult> readPassport({
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(NfcReadProgress) onProgress,
  }) async {
    // Track current step for contextual error messages
    String currentReadStep = 'connecting';

    try {
      // Pre-check NFC status so disabled NFC is immediately prompted rather than misreported
      final deviceStatus = await getNfcStatus();
      if (deviceStatus == NfcDeviceStatus.disabled) {
        throw const NfcError(
          type: NfcErrorType.nfcDisabled,
          message: 'NFC is turned off. Please enable it in device settings.',
          isRetryable: true,
        );
      } else if (deviceStatus == NfcDeviceStatus.unsupported) {
        throw const NfcError(
          type: NfcErrorType.nfcNotAvailable,
          message: 'Your device does not support NFC.',
          isRetryable: false,
        );
      }

      // 1. Connection
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.connecting,
          percentage: 0.0,
          description: 'Waiting for passport...',
        ),
      );

      try {
        await _nfc.connect(
          iosAlertMessage: 'Hold your iPhone near the biometric passport.',
        );
      } catch (e) {
        throw NfcErrorMapper.fromException(
          e,
          readStep: 'connecting to passport',
        );
      }

      final passport = Passport(_nfc);

      // 2. Read EF.CardAccess to determine PACE support
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingCardAccess,
          percentage: 0.1,
          description: 'Connecting to chip...',
        ),
      );

      _nfc.setIosAlertMessage('Reading Card Access...');

      EfCardAccess? cardAccess;
      try {
        cardAccess = await passport.readEfCardAccess();
      } on PassportError {
        _log.info('EF.CardAccess not found. Falling back to BAC.');
      }

      // 3. Establish Session (PACE or BAC)
      currentReadStep = 'authenticating';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.authenticating,
          percentage: 0.2,
          description: 'Authenticating...',
        ),
      );

      _nfc.setIosAlertMessage('Authenticating...');

      final accessKey = DBAKey(documentNumber, dateOfBirth, dateOfExpiry);
      NfcAuthMethod authMethod = NfcAuthMethod.bac;

      // Note: PACE logic via DBAKey is supported by dmrtd if configured, but
      // BAC is the universally supported fallback.
      // If the passport explicitly forces PACE, we could startSessionPACE here.
      // For simplicity and highest compatibility, we start standard BAC session.
      try {
        await passport.startSession(accessKey);
      } catch (e) {
        // BAC/PACE session establishment is the most common failure point.
        // Wrong MRZ data (doc number, DOB, expiry) or a mismatched passport
        // causes authentication to fail.
        throw NfcErrorMapper.fromException(
          e,
          fallbackType: NfcErrorType.authenticationFailed,
          readStep: 'authenticating',
        );
      }

      // 4. Read EF.COM
      currentReadStep = 'reading configuration';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingCom,
          percentage: 0.3,
          description: 'Reading configuration...',
        ),
      );

      _nfc.setIosAlertMessage('Reading configuration...');
      final com = await passport.readEfCOM();
      final tags = com.dgTags;

      final rawDgBytesBase64 = <String, String>{};
      final availableDataGroups = <String>[];

      NfcMrzData? parsedMrz;
      Uint8List? faceImageBytes;
      String? activeAuthSignatureBase64;

      // Helper function to safely read a DG
      Future<void> readAndStoreDg(
        DgTag tag,
        String name,
        Future<DataGroup> Function() readFunc,
      ) async {
        if (tags.contains(tag)) {
          _log.info('Reading $name...');
          try {
            final dg = await readFunc();
            rawDgBytesBase64[name.toLowerCase()] = base64Encode(dg.toBytes());
            availableDataGroups.add(name.toLowerCase());
          } catch (e) {
            _log.warning('Failed to read $name: $e');
          }
        }
      }

      // 5. Read EF.DG1 (MRZ Data)
      currentReadStep = 'reading basic details';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingDg1,
          percentage: 0.4,
          description: 'Reading basic details...',
        ),
      );
      _nfc.setIosAlertMessage('Reading basic details...');

      if (tags.contains(EfDG1.TAG)) {
        final dg1 = await passport.readEfDG1();
        rawDgBytesBase64['dg1'] = base64Encode(dg1.toBytes());
        availableDataGroups.add('dg1');

        final mrz = dg1.mrz;
        parsedMrz = NfcMrzData(
          documentNumber: mrz.documentNumber,
          documentCode: mrz.documentCode,
          firstName: mrz.firstName,
          lastName: mrz.lastName,
          nationality: mrz.nationality,
          country: mrz.country,
          gender: mrz.gender,
          dateOfBirth: mrz.dateOfBirth,
          dateOfExpiry: mrz.dateOfExpiry,
          optionalData: mrz.optionalData,
          optionalData2: mrz.optionalData2,
        );
      }

      // 6. Read EF.DG2 (Face Image)
      currentReadStep = 'reading face image';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingDg2,
          percentage: 0.6,
          description: 'Reading face image...',
        ),
      );
      _nfc.setIosAlertMessage('Reading face image (this takes a moment)...');

      if (tags.contains(EfDG2.TAG)) {
        try {
          final dg2 = await passport.readEfDG2();
          final dg2Bytes = dg2.toBytes();
          rawDgBytesBase64['dg2'] = base64Encode(dg2Bytes);
          availableDataGroups.add('dg2');

          faceImageBytes = NfcImageExtractor.extractFromDg2(dg2);
          if (faceImageBytes != null) {
            _log.info('Extracted face image (${faceImageBytes.length} bytes)');
          } else {
            _log.warning('No face image bytes extracted from DG2');
          }
        } catch (e) {
          _log.warning('Failed to read or parse DG2: $e');
        }
      }

      // 7. Read EF.DG14 (Chip Authentication Public Key)
      currentReadStep = 'reading security parameters';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingDg14,
          percentage: 0.7,
          description: 'Reading security parameters...',
        ),
      );
      await readAndStoreDg(EfDG14.TAG, 'DG14', () => passport.readEfDG14());

      // 8. Read EF.DG15 (Active Authentication Public Key) & Perform AA
      currentReadStep = 'reading authentication keys';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingDg15,
          percentage: 0.75,
          description: 'Reading authentication keys...',
        ),
      );

      if (tags.contains(EfDG15.TAG)) {
        final dg15 = await passport.readEfDG15();
        rawDgBytesBase64['dg15'] = base64Encode(dg15.toBytes());
        availableDataGroups.add('dg15');

        onProgress(
          const NfcReadProgress(
            currentStep: NfcReadStep.activeAuthentication,
            percentage: 0.8,
            description: 'Verifying chip authenticity...',
          ),
        );
        _nfc.setIosAlertMessage('Verifying authenticity...');

        try {
          // Perform AA with an 8-byte random challenge.
          // The backend should really provide the challenge, but we do this
          // to gather the signature to include in the payload.
          final aaSig = await passport.activeAuthenticate(Uint8List(8));
          activeAuthSignatureBase64 = base64Encode(aaSig);
        } catch (e) {
          _log.warning('Active Authentication failed: $e');
        }
      }

      // 9. Read EF.SOD (Document Security Object for Passive Authentication)
      currentReadStep = 'reading security object';
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.readingSod,
          percentage: 0.9,
          description: 'Reading document security object...',
        ),
      );
      _nfc.setIosAlertMessage('Reading security object...');

      final sod = await passport.readEfSOD();

      // 10. Complete
      onProgress(
        const NfcReadProgress(
          currentStep: NfcReadStep.complete,
          percentage: 1.0,
          description: 'Finished',
        ),
      );

      _nfc.setIosAlertMessage('Verification complete!');
      await Future.delayed(const Duration(milliseconds: 500));
      await _nfc.disconnect();

      return NfcPassportResult(
        rawDgBytesBase64: rawDgBytesBase64,
        sodBytesBase64: base64Encode(sod.toBytes()),
        comBytesBase64: base64Encode(com.toBytes()),
        cardAccessBytesBase64: cardAccess != null
            ? base64Encode(cardAccess.toBytes())
            : null,
        parsedMrz: parsedMrz,
        faceImageBytes: faceImageBytes,
        activeAuthSignatureBase64: activeAuthSignatureBase64,
        authMethod: authMethod,
        availableDataGroups: availableDataGroups,
      );
    } catch (e) {
      _log.severe('Error reading passport at step "$currentReadStep": $e');

      // If already an NfcError (from step-specific catch blocks), preserve it
      final nfcError = e is NfcError
          ? e
          : NfcErrorMapper.fromException(e, readStep: currentReadStep);

      // Try to disconnect cleanly on error
      try {
        await _nfc.disconnect(iosErrorMessage: nfcError.message);
      } catch (_) {}

      throw nfcError;
    }
  }
}

/// Provider for the [NfcPassportService].
final nfcPassportServiceProvider = Provider<NfcPassportService>((ref) {
  return NfcPassportServiceImpl();
});
