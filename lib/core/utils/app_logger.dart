import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Structured application logger with redaction for sensitive data.
class AppLogger {
  const AppLogger._();

  @visibleForTesting
  static void Function(String message)? outputPrinter;

  static const _sensitiveKeys = {
    'authorization',
    'token',
    'access_token',
    'refresh_token',
    'password',
    'secret',
    'click_reference',
    'referral_id',
    'passport',
    'mrz',
    'nfc',
    'document_number',
    'credential',
    'api_key',
    'signature',
  };

  static void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode && outputPrinter == null) return;
    final errorString = error != null ? ' | error: $error' : '';
    final logLine = '[${level.name.toUpperCase()}] $message$errorString';
    if (outputPrinter != null) {
      outputPrinter!(logLine);
    } else {
      debugPrint(logLine);
    }
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      log(LogLevel.debug, message, error, stackTrace);

  static void info(String message, [Object? error, StackTrace? stackTrace]) =>
      log(LogLevel.info, message, error, stackTrace);

  static void warning(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) => log(LogLevel.warning, message, error, stackTrace);

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      log(LogLevel.error, message, error, stackTrace);

  /// Recursively redacts sensitive keys from maps, lists, and authorization headers.
  static dynamic sanitize(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final keyString = key.toString().toLowerCase();
        final isSensitive = _sensitiveKeys.any(
          (sensitive) => keyString.contains(sensitive),
        );
        return MapEntry(key, isSensitive ? '[REDACTED]' : sanitize(value));
      });
    }
    if (data is List) return data.map(sanitize).toList();
    if (data is String && data.toLowerCase().startsWith('bearer ')) {
      return 'Bearer [REDACTED]';
    }
    return data;
  }
}
