import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local persistent state for referral click references and mobile install attribution.
class AttributionStorage {
  static const String _keyClickReference = 'trvlez_attribution_click_reference';
  static const String _keyInstallEvidenceRecorded =
      'trvlez_attribution_install_evidence_recorded';
  static const String _keyInstallReferrerChecked =
      'trvlez_attribution_install_referrer_checked';

  final SharedPreferences? _prefs;
  final Map<String, Object> _inMemoryFallback = {};

  AttributionStorage([this._prefs]);

  /// Factory initializer that retrieves the shared preferences singleton.
  static Future<AttributionStorage> init({SharedPreferences? prefs}) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    return AttributionStorage(preferences);
  }

  /// Retrieves the captured referral click reference, if any.
  String? getClickReference() {
    if (_prefs != null) {
      return _prefs.getString(_keyClickReference);
    }
    return _inMemoryFallback[_keyClickReference] as String?;
  }

  /// Saves the captured referral click reference to local storage.
  Future<void> saveClickReference(String clickReference) async {
    if (_prefs != null) {
      await _prefs.setString(_keyClickReference, clickReference);
    } else {
      _inMemoryFallback[_keyClickReference] = clickReference;
    }
  }

  /// Whether install evidence has already been recorded (or resolved) with the backend.
  bool isInstallEvidenceRecorded() {
    if (_prefs != null) {
      return _prefs.getBool(_keyInstallEvidenceRecorded) ?? false;
    }
    return (_inMemoryFallback[_keyInstallEvidenceRecorded] as bool?) ?? false;
  }

  /// Sets whether install evidence has been recorded.
  Future<void> setInstallEvidenceRecorded(bool recorded) async {
    if (_prefs != null) {
      await _prefs.setBool(_keyInstallEvidenceRecorded, recorded);
    } else {
      _inMemoryFallback[_keyInstallEvidenceRecorded] = recorded;
    }
  }

  /// Whether the native install referrer has already been checked on this device.
  bool isInstallReferrerChecked() {
    if (_prefs != null) {
      return _prefs.getBool(_keyInstallReferrerChecked) ?? false;
    }
    return (_inMemoryFallback[_keyInstallReferrerChecked] as bool?) ?? false;
  }

  /// Sets whether the native install referrer has been checked.
  Future<void> setInstallReferrerChecked(bool checked) async {
    if (_prefs != null) {
      await _prefs.setBool(_keyInstallReferrerChecked, checked);
    } else {
      _inMemoryFallback[_keyInstallReferrerChecked] = checked;
    }
  }

  /// Clears stored attribution state (e.g. for testing or reset).
  Future<void> clear() async {
    if (_prefs != null) {
      await _prefs.remove(_keyClickReference);
      await _prefs.remove(_keyInstallEvidenceRecorded);
      await _prefs.remove(_keyInstallReferrerChecked);
    } else {
      _inMemoryFallback.clear();
    }
  }
}

/// Provider for [AttributionStorage].
final attributionStorageProvider = Provider<AttributionStorage>((ref) {
  return AttributionStorage();
});

