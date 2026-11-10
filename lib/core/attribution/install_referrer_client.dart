import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Structured result returned from the native Google Play Install Referrer API.
class InstallReferrerResult {
  final String? rawReferrer;
  final String? clickReference;
  final DateTime? clickTimestamp;
  final int? installBeginTimestampSeconds;

  const InstallReferrerResult({
    this.rawReferrer,
    this.clickReference,
    this.clickTimestamp,
    this.installBeginTimestampSeconds,
  });
}

/// Client interface and default implementation for interacting with the native
/// Android Play Install Referrer service via [MethodChannel].
class InstallReferrerClient {
  static const String channelName = 'com.trvlez.mobile/install_referrer';
  static const MethodChannel _defaultChannel = MethodChannel(channelName);

  final MethodChannel _channel;
  final TargetPlatform? platformOverride;

  const InstallReferrerClient({
    MethodChannel? channel,
    this.platformOverride,
  }) : _channel = channel ?? _defaultChannel;

  /// Whether the current platform supports Google Play Install Referrer.
  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    final platform = platformOverride ?? defaultTargetPlatform;
    return platform == TargetPlatform.android;
  }

  /// Fetches install referrer details from Google Play Store on Android.
  ///
  /// Returns `null` on unsupported platforms, when Google Play is not available,
  /// or when no referrer information was supplied.
  Future<InstallReferrerResult?> getInstallReferrer() async {
    if (!isSupportedPlatform) {
      return null;
    }

    try {
      final response = await _channel.invokeMapMethod<String, dynamic>(
        'getInstallReferrer',
      );
      if (response == null) return null;

      final rawReferrer = response['installReferrer'] as String?;
      final clickTimestampSeconds =
          response['referrerClickTimestampSeconds'] as int?;
      final installBeginTimestampSeconds =
          response['installBeginTimestampSeconds'] as int?;

      DateTime? clickTimestamp;
      if (clickTimestampSeconds != null && clickTimestampSeconds > 0) {
        clickTimestamp = DateTime.fromMillisecondsSinceEpoch(
          clickTimestampSeconds * 1000,
          isUtc: true,
        );
      }

      final clickReference = parseClickReference(rawReferrer);

      return InstallReferrerResult(
        rawReferrer: rawReferrer,
        clickReference: clickReference,
        clickTimestamp: clickTimestamp,
        installBeginTimestampSeconds: installBeginTimestampSeconds,
      );
    } on PlatformException catch (platformException) {
      debugPrint('[InstallReferrerClient] PlatformException: ${platformException.message}');
      return null;
    } catch (unexpectedError) {
      debugPrint('[InstallReferrerClient] Unexpected error: $unexpectedError');
      return null;
    }
  }

  /// Parses `click_reference` out of an install referrer string.
  ///
  /// Supports:
  /// - `click_ref=<token>` (Used in web app referral handoff)
  /// - `trvlez_ref=<token>` (Used in OpenSpec specification)
  /// - `click_reference=<token>` (Backend payload parameter name)
  /// - `ref=<token>`
  /// - Raw token string of valid length (16-128 chars)
  static String? parseClickReference(String? referrer) {
    if (referrer == null || referrer.trim().isEmpty) return null;

    final trimmed = referrer.trim();
    String decoded;
    try {
      decoded = Uri.decodeFull(trimmed);
    } catch (_) {
      decoded = trimmed;
    }

    // Split on query parameter delimiters '&'
    final params = decoded.split('&');
    for (final param in params) {
      final parts = param.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim().toLowerCase();
        final rawValue = parts[1].trim();
        String value;
        try {
          value = Uri.decodeComponent(rawValue);
        } catch (_) {
          value = rawValue;
        }

        if (key == 'click_ref' ||
            key == 'trvlez_ref' ||
            key == 'click_reference' ||
            key == 'ref') {
          if (value.length >= 16 && value.length <= 128) {
            return value;
          }
        }
      }
    }

    // Direct token without param key
    if (!decoded.contains('=') && decoded.length >= 16 && decoded.length <= 128) {
      return decoded;
    }

    return null;
  }
}
