import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';

/// Lightweight persistence for durable verification workflow identity & recovery tokens.
///
/// Transient UI state (such as in-flight loading flags, image buffers, or Dio errors)
/// is NEVER persisted here.
class VerificationStorage {
  static const String _keySessionId = 'verification_durable_session_id';
  static const String _keyJobId = 'verification_durable_job_id';
  static const String _keyLastStatus = 'verification_durable_last_status';
  static const String _keyLastReconciled =
      'verification_durable_last_reconciled_ms';
  static const String _keyDocNumber = 'verification_durable_doc_number';
  static const String _keyDobMs = 'verification_durable_dob_ms';
  static const String _keyDoeMs = 'verification_durable_doe_ms';
  static const String _keyScore = 'verification_durable_score';

  const VerificationStorage();

  Future<void> saveDurableData(VerificationDurableData data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.sessionId != null) {
      await prefs.setString(_keySessionId, data.sessionId!);
    }
    if (data.jobId != null) {
      await prefs.setString(_keyJobId, data.jobId!);
    }
    if (data.lastKnownStatus != null) {
      await prefs.setString(_keyLastStatus, data.lastKnownStatus!);
    }
    if (data.lastReconciledAt != null) {
      await prefs.setInt(
        _keyLastReconciled,
        data.lastReconciledAt!.millisecondsSinceEpoch,
      );
    }
    if (data.extractedDocumentNumber != null) {
      await prefs.setString(_keyDocNumber, data.extractedDocumentNumber!);
    }
    if (data.extractedDateOfBirth != null) {
      await prefs.setInt(
        _keyDobMs,
        data.extractedDateOfBirth!.millisecondsSinceEpoch,
      );
    }
    if (data.extractedDateOfExpiry != null) {
      await prefs.setInt(
        _keyDoeMs,
        data.extractedDateOfExpiry!.millisecondsSinceEpoch,
      );
    }
    if (data.verificationScore != null) {
      await prefs.setDouble(_keyScore, data.verificationScore!);
    }
  }

  Future<VerificationDurableData> loadDurableData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_keySessionId);
    final jobId = prefs.getString(_keyJobId);
    final lastStatus = prefs.getString(_keyLastStatus);
    final lastReconciledMs = prefs.getInt(_keyLastReconciled);
    final docNumber = prefs.getString(_keyDocNumber);
    final dobMs = prefs.getInt(_keyDobMs);
    final doeMs = prefs.getInt(_keyDoeMs);
    final score = prefs.getDouble(_keyScore);

    return VerificationDurableData(
      sessionId: sessionId,
      jobId: jobId,
      lastKnownStatus: lastStatus,
      lastReconciledAt: lastReconciledMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastReconciledMs)
          : null,
      extractedDocumentNumber: docNumber,
      extractedDateOfBirth: dobMs != null
          ? DateTime.fromMillisecondsSinceEpoch(dobMs)
          : null,
      extractedDateOfExpiry: doeMs != null
          ? DateTime.fromMillisecondsSinceEpoch(doeMs)
          : null,
      verificationScore: score,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionId);
    await prefs.remove(_keyJobId);
    await prefs.remove(_keyLastStatus);
    await prefs.remove(_keyLastReconciled);
    await prefs.remove(_keyDocNumber);
    await prefs.remove(_keyDobMs);
    await prefs.remove(_keyDoeMs);
    await prefs.remove(_keyScore);
  }
}
