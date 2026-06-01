import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import 'api_exception.dart';

/// Thin HTTP client wrapper for the TrvlEz backend API.
///
/// Handles JSON serialization, common headers, and FastAPI error parsing.
/// All methods throw [ApiException] on failure.
class ApiClient {
  final http.Client _client;
  final void Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    this.onUnauthorized,
  }) : _client = client ?? http.Client();

  // ─── Public API ───────────────────────────────────────────────────

  /// Sends a POST request to `{apiUrl}/{path}` with a JSON body.
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await _client.post(
        uri,
        headers: _headers(authToken: authToken),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a POST request to `{apiUrl}/{path}` with URL-encoded form data.
  Future<Map<String, dynamic>> postForm(
    String path, {
    required Map<String, String> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final headers = _headers(authToken: authToken);
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      final response = await _client.post(
        uri,
        headers: headers,
        body: body,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a GET request to `{apiUrl}/{path}`.
  Future<Map<String, dynamic>> get(
    String path, {
    String? authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await _client.get(
        uri,
        headers: _headers(authToken: authToken),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Releases underlying resources.
  void dispose() {
    _client.close();
  }

  // ─── Private Helpers ──────────────────────────────────────────────

  Map<String, String> _headers({String? authToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// Parses the HTTP response, extracting JSON on success or
  /// throwing [ApiException] with FastAPI's `detail` field on error.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success but non-JSON — shouldn't happen for our endpoints
        return <String, dynamic>{};
      }
      throw ApiException.server();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException.unauthorized();
    }

    // FastAPI returns `{"detail": "..."} ` or `{"detail": [{"msg": "..."}]}`
    final detail = body['detail'];
    final String message;

    if (detail is List) {
      message = (detail)
          .map((e) => (e as Map<String, dynamic>)['msg'] as String? ?? '')
          .where((msg) => msg.isNotEmpty)
          .join('. ');
    } else if (detail is String) {
      message = detail;
    } else {
      message = 'An unexpected error occurred.';
    }

    throw ApiException.fromStatusCode(response.statusCode, message);
  }
}
