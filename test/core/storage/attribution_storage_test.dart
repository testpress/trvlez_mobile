import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttributionStorage (In-memory fallback)', () {
    late AttributionStorage storage;

    setUp(() {
      storage = AttributionStorage();
    });

    test('defaults to null and false states', () {
      expect(storage.getClickReference(), isNull);
      expect(storage.isInstallEvidenceRecorded(), isFalse);
      expect(storage.isInstallReferrerChecked(), isFalse);
    });

    test('persists and retrieves click reference', () async {
      await storage.saveClickReference('sample_click_ref_12345');
      expect(storage.getClickReference(), equals('sample_click_ref_12345'));
    });

    test('persists install evidence recorded flag', () async {
      await storage.setInstallEvidenceRecorded(true);
      expect(storage.isInstallEvidenceRecorded(), isTrue);

      await storage.setInstallEvidenceRecorded(false);
      expect(storage.isInstallEvidenceRecorded(), isFalse);
    });

    test('persists install referrer checked flag', () async {
      await storage.setInstallReferrerChecked(true);
      expect(storage.isInstallReferrerChecked(), isTrue);
    });

    test('clears all state', () async {
      await storage.saveClickReference('test_ref_12345');
      await storage.setInstallEvidenceRecorded(true);
      await storage.setInstallReferrerChecked(true);

      await storage.clear();

      expect(storage.getClickReference(), isNull);
      expect(storage.isInstallEvidenceRecorded(), isFalse);
      expect(storage.isInstallReferrerChecked(), isFalse);
    });
  });

  group('AttributionStorage (SharedPreferences backed)', () {
    late SharedPreferences prefs;
    late AttributionStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = AttributionStorage(prefs);
    });

    test('persists across SharedPreferences instances', () async {
      await storage.saveClickReference('shared_pref_ref_12345');
      await storage.setInstallEvidenceRecorded(true);
      await storage.setInstallReferrerChecked(true);

      final reloadedStorage = AttributionStorage(prefs);
      expect(
        reloadedStorage.getClickReference(),
        equals('shared_pref_ref_12345'),
      );
      expect(reloadedStorage.isInstallEvidenceRecorded(), isTrue);
      expect(reloadedStorage.isInstallReferrerChecked(), isTrue);
    });

    test('clear removes keys from preferences', () async {
      await storage.saveClickReference('ref_to_remove_12345');
      await storage.setInstallEvidenceRecorded(true);
      await storage.setInstallReferrerChecked(true);

      await storage.clear();

      expect(storage.getClickReference(), isNull);
      expect(storage.isInstallEvidenceRecorded(), isFalse);
      expect(storage.isInstallReferrerChecked(), isFalse);
    });
  });
}
