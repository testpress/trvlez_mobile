import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/core/storage/passcode_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';

class MockSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  group('SettingsRepository Unit Tests', () {
    late SettingsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs);
    });

    test('Defaults to normal text scale preset', () {
      expect(repo.getTextScalePreset(), TextScalePreset.normal);
    });

    test('Persists and retrieves text scale presets', () async {
      await repo.setTextScalePreset(TextScalePreset.largest);
      expect(repo.getTextScalePreset(), TextScalePreset.largest);
      expect(repo.getTextScalePreset().scaleFactor, 1.30);

      await repo.setTextScalePreset(TextScalePreset.smaller);
      expect(repo.getTextScalePreset(), TextScalePreset.smaller);
    });

    test('Persists and retrieves two-step verification status', () async {
      expect(repo.isTwoStepVerificationEnabled(), isFalse);
      await repo.setTwoStepVerificationEnabled(true);
      expect(repo.isTwoStepVerificationEnabled(), isTrue);
    });

    test('Persists and retrieves Findr activation status', () async {
      expect(repo.isFindrActivated(), isFalse);
      await repo.setFindrActivated(true);
      expect(repo.isFindrActivated(), isTrue);
      await repo.setFindrActivated(false);
      expect(repo.isFindrActivated(), isFalse);
    });
  });

  group('PasscodeStorage Unit Tests', () {
    late MockSecureStorage mockSecure;
    late PasscodeStorage storage;

    setUp(() {
      mockSecure = MockSecureStorage();
      storage = PasscodeStorage(storage: mockSecure);
    });

    test('Passcode defaults to disabled', () async {
      expect(await storage.isPasscodeEnabled(), isFalse);
      expect(await storage.hasPasscode(), isFalse);
    });

    test('Sets and verifies local device PIN', () async {
      await storage.setPasscode('1234');
      expect(await storage.isPasscodeEnabled(), isTrue);
      expect(await storage.hasPasscode(), isTrue);
      expect(await storage.verifyPasscode('1234'), isTrue);
      expect(await storage.verifyPasscode('9999'), isFalse);
    });

    test('Clears passcode securely', () async {
      await storage.setPasscode('4567');
      await storage.clearPasscode();
      expect(await storage.isPasscodeEnabled(), isFalse);
      expect(await storage.hasPasscode(), isFalse);
    });
  });
}
