import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely manages local device app passcode in Keychain (iOS) / Keystore (Android).
///
/// Under product rules, passcode lives on the local device only — never on a server.
class PasscodeStorage {
  static const String _passcodeKey = 'app_local_passcode';
  static const String _enabledKey = 'app_local_passcode_enabled';

  final FlutterSecureStorage _storage;

  PasscodeStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> isPasscodeEnabled() async {
    final value = await _storage.read(key: _enabledKey);
    return value == 'true';
  }

  Future<bool> hasPasscode() async {
    final code = await _storage.read(key: _passcodeKey);
    return code != null && code.isNotEmpty;
  }

  Future<void> setPasscode(String passcode) async {
    await _storage.write(key: _passcodeKey, value: passcode);
    await _storage.write(key: _enabledKey, value: 'true');
  }

  Future<bool> verifyPasscode(String passcode) async {
    final stored = await _storage.read(key: _passcodeKey);
    return stored != null && stored == passcode;
  }

  Future<void> setPasscodeEnabled(bool enabled) async {
    await _storage.write(key: _enabledKey, value: enabled ? 'true' : 'false');
  }

  Future<void> clearPasscode() async {
    await _storage.delete(key: _passcodeKey);
    await _storage.delete(key: _enabledKey);
  }
}

/// Provider for [PasscodeStorage].
final passcodeStorageProvider = Provider<PasscodeStorage>((ref) {
  return PasscodeStorage();
});
