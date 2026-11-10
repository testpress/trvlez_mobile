import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/attribution/install_referrer_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InstallReferrerClient.parseClickReference', () {
    test('parses click_ref parameter correctly', () {
      const token = '1234567890abcdef12345678';
      final result = InstallReferrerClient.parseClickReference('click_ref=$token');
      expect(result, equals(token));
    });

    test('parses trvlez_ref parameter correctly', () {
      const token = 'trvlez_ref_token_test_12345';
      final result = InstallReferrerClient.parseClickReference('trvlez_ref=$token');
      expect(result, equals(token));
    });

    test('parses click_reference parameter correctly', () {
      const token = 'long_click_reference_token_xyz';
      final result =
          InstallReferrerClient.parseClickReference('click_reference=$token');
      expect(result, equals(token));
    });

    test('parses ref parameter correctly', () {
      const token = 'short_valid_ref_token_123';
      final result = InstallReferrerClient.parseClickReference('ref=$token');
      expect(result, equals(token));
    });

    test('parses when embedded within complex query parameters', () {
      const token = 'sample_click_reference_123456';
      const referrer =
          'utm_source=google-play&utm_medium=organic&click_ref=$token&utm_campaign=summer_2026';
      final result = InstallReferrerClient.parseClickReference(referrer);
      expect(result, equals(token));
    });

    test('decodes URL-encoded parameters', () {
      const token = 'sample_click_ref_with_special_chars_123';
      final encoded = Uri.encodeComponent(token);
      final result =
          InstallReferrerClient.parseClickReference('click_ref=$encoded');
      expect(result, equals(token));
    });

    test('parses raw token without parameter key if length is within 16-128', () {
      const rawToken = 'plain_opaque_token_without_param_12345';
      final result = InstallReferrerClient.parseClickReference(rawToken);
      expect(result, equals(rawToken));
    });

    test('rejects tokens shorter than 16 characters', () {
      final result1 = InstallReferrerClient.parseClickReference('click_ref=too_short');
      expect(result1, isNull);

      final result2 = InstallReferrerClient.parseClickReference('short_raw_tok');
      expect(result2, isNull);
    });

    test('rejects tokens longer than 128 characters', () {
      final longToken = 'a' * 129;
      final result =
          InstallReferrerClient.parseClickReference('click_ref=$longToken');
      expect(result, isNull);
    });

    test('returns null for empty or null strings', () {
      expect(InstallReferrerClient.parseClickReference(null), isNull);
      expect(InstallReferrerClient.parseClickReference(''), isNull);
      expect(InstallReferrerClient.parseClickReference('   '), isNull);
    });

    test('handles malformed percent encoding without throwing', () {
      expect(
        InstallReferrerClient.parseClickReference('click_ref=%E0%A4%A'),
        isNull,
      );
    });
  });

  group('InstallReferrerClient platform support & MethodChannel invocation', () {
    const channelName = InstallReferrerClient.channelName;
    late List<MethodCall> log;

    setUp(() {
      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (call) async {
        log.add(call);
        if (call.method == 'getInstallReferrer') {
          return <String, dynamic>{
            'installReferrer': 'click_ref=android_play_referrer_token_123',
            'referrerClickTimestampSeconds': 1700000000,
            'installBeginTimestampSeconds': 1700000050,
          };
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), null);
    });

    test('skips invocation when platform is iOS', () async {
      const client = InstallReferrerClient(platformOverride: TargetPlatform.iOS);
      expect(client.isSupportedPlatform, isFalse);

      final result = await client.getInstallReferrer();
      expect(result, isNull);
      expect(log, isEmpty);
    });

    test('invokes MethodChannel when platform is Android and parses details',
        () async {
      const client =
          InstallReferrerClient(platformOverride: TargetPlatform.android);
      expect(client.isSupportedPlatform, isTrue);

      final result = await client.getInstallReferrer();
      expect(log.length, equals(1));
      expect(log.first.method, equals('getInstallReferrer'));

      expect(result, isNotNull);
      expect(
        result!.rawReferrer,
        equals('click_ref=android_play_referrer_token_123'),
      );
      expect(
        result.clickReference,
        equals('android_play_referrer_token_123'),
      );
      expect(result.installBeginTimestampSeconds, equals(1700000050));
      expect(
        result.clickTimestamp,
        equals(
          DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000, isUtc: true),
        ),
      );
    });

    test('handles PlatformException gracefully and returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (call) async {
        throw PlatformException(
          code: 'UNAVAILABLE',
          message: 'Play Store service unavailable',
        );
      });

      const client =
          InstallReferrerClient(platformOverride: TargetPlatform.android);
      final result = await client.getInstallReferrer();
      expect(result, isNull);
    });
  });
}

