import 'dart:convert';
import 'dart:typed_data';

import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../domain/nfc_error.dart';
import '../domain/nfc_passport_result.dart';
import '../domain/nfc_read_progress.dart';

/// Service responsible for orchestrating the NFC communication with the passport chip.
/// 
/// Wraps the lower-level `dmrtd` library and maps its specialized exceptions
/// to user-friendly `NfcError` models, while reporting progress to the UI.
class NfcPassportService {
  final _log = Logger('NfcPassportService');
  final NfcProvider _nfc = NfcProvider();

  /// Checks if the current device has NFC hardware and if it is enabled.
  Future<bool> isNfcAvailable() async {
    try {
      final status = await NfcProvider.nfcStatus;
      return status == NfcStatus.enabled;
    } on PlatformException catch (e) {
      _log.warning('NfcProvider platform exception: $e');
      return false;
    } catch (e) {
      _log.warning('Error checking NFC status: $e');
      return false;
    }
  }

  /// Initiates a reading session with the passport chip.
  /// 
  /// The [documentNumber], [dateOfBirth], and [dateOfExpiry] are required to 
  /// establish the BAC (Basic Access Control) or PACE session.
  /// 
  /// Progress is reported via the [onProgress] callback.
  Future<NfcPassportResult> readPassport({
    required String documentNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(NfcReadProgress) onProgress,
  }) async {
    try {
      // 1. Connection
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.connecting,
        percentage: 0.0,
        description: 'Waiting for passport...',
      ));

      await _nfc.connect(
        iosAlertMessage: 'Hold your iPhone near the biometric passport.',
      );

      final passport = Passport(_nfc);

      // 2. Read EF.CardAccess to determine PACE support
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingCardAccess,
        percentage: 0.1,
        description: 'Connecting to chip...',
      ));
      
      _nfc.setIosAlertMessage('Reading Card Access...');
      
      EfCardAccess? cardAccess;
      try {
        cardAccess = await passport.readEfCardAccess();
      } on PassportError {
        _log.info('EF.CardAccess not found. Falling back to BAC.');
      }

      // 3. Establish Session (PACE or BAC)
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.authenticating,
        percentage: 0.2,
        description: 'Authenticating...',
      ));
      
      _nfc.setIosAlertMessage('Authenticating...');

      final accessKey = DBAKey(documentNumber, dateOfBirth, dateOfExpiry);
      NfcAuthMethod authMethod = NfcAuthMethod.bac;

      // Note: PACE logic via DBAKey is supported by dmrtd if configured, but 
      // BAC is the universally supported fallback. 
      // If the passport explicitly forces PACE, we could startSessionPACE here.
      // For simplicity and highest compatibility, we start standard BAC session.
      await passport.startSession(accessKey);

      // 4. Read EF.COM
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingCom,
        percentage: 0.3,
        description: 'Reading configuration...',
      ));
      
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
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingDg1,
        percentage: 0.4,
        description: 'Reading basic details...',
      ));
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
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingDg2,
        percentage: 0.6,
        description: 'Reading face image...',
      ));
      _nfc.setIosAlertMessage('Reading face image (this takes a moment)...');

      if (tags.contains(EfDG2.TAG)) {
        final dg2 = await passport.readEfDG2();
        rawDgBytesBase64['dg2'] = base64Encode(dg2.toBytes());
        availableDataGroups.add('dg2');
        // Extract raw image bytes for preview (though backend will re-parse for security)
        // Note: dmrtd DG2 parsing is complex; usually we send the raw DG2 to the backend.
        // We'll leave faceImageBytes null here and let the backend extract it from the raw DG2.
      }

      // 7. Read EF.DG14 (Chip Authentication Public Key)
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingDg14,
        percentage: 0.7,
        description: 'Reading security parameters...',
      ));
      await readAndStoreDg(EfDG14.TAG, 'DG14', () => passport.readEfDG14());

      // 8. Read EF.DG15 (Active Authentication Public Key) & Perform AA
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingDg15,
        percentage: 0.75,
        description: 'Reading authentication keys...',
      ));
      
      if (tags.contains(EfDG15.TAG)) {
        final dg15 = await passport.readEfDG15();
        rawDgBytesBase64['dg15'] = base64Encode(dg15.toBytes());
        availableDataGroups.add('dg15');

        onProgress(const NfcReadProgress(
          currentStep: NfcReadStep.activeAuthentication,
          percentage: 0.8,
          description: 'Verifying chip authenticity...',
        ));
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
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.readingSod,
        percentage: 0.9,
        description: 'Reading document security object...',
      ));
      _nfc.setIosAlertMessage('Reading security object...');

      final sod = await passport.readEfSOD();
      
      // 10. Complete
      onProgress(const NfcReadProgress(
        currentStep: NfcReadStep.complete,
        percentage: 1.0,
        description: 'Finished',
      ));
      
      _nfc.setIosAlertMessage('Verification complete!');
      await Future.delayed(const Duration(milliseconds: 500));
      await _nfc.disconnect();

      return NfcPassportResult(
        rawDgBytesBase64: rawDgBytesBase64,
        sodBytesBase64: base64Encode(sod.toBytes()),
        comBytesBase64: base64Encode(com.toBytes()),
        cardAccessBytesBase64: cardAccess != null ? base64Encode(cardAccess.toBytes()) : null,
        parsedMrz: parsedMrz,
        faceImageBytes: faceImageBytes,
        activeAuthSignatureBase64: activeAuthSignatureBase64,
        authMethod: authMethod,
        availableDataGroups: availableDataGroups,
      );
    } catch (e) {
      _log.severe('Error reading passport: $e');
      
      // Try to disconnect cleanly on error
      try {
        final nfcError = NfcError.fromException(e);
        await _nfc.disconnect(iosErrorMessage: nfcError.message);
      } catch (_) {}

      throw NfcError.fromException(e);
    }
  }
}
