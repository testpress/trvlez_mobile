import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:trvlez_mobile/core/constants/app_config.dart';import 'package:trvlez_mobile/core/network/api_exception.dart';
/// Thin HTTP client wrapper for the TrvlEz backend API.
///
/// Handles JSON serialization, common headers, and FastAPI error parsing.
/// All methods throw [ApiException] on failure.
class ApiClient {
  final http.Client client;
  void Function()? onUnauthorized;

  ApiClient({http.Client? client, this.onUnauthorized})
    : client = client ?? http.Client();

  // ─── Public API ───────────────────────────────────────────────────

  /// Sends a POST request to `{apiUrl}/{path}` with a JSON body.
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await client.post(
        uri,
        headers: headers(authToken: authToken),
        body: jsonEncode(body),
      );

      return handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a PATCH request to `{apiUrl}/{path}` with a JSON body.
  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await client.patch(
        uri,
        headers: headers(authToken: authToken),
        body: jsonEncode(body),
      );

      return handleResponse(response);
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
      final reqHeaders = headers(authToken: authToken);
      reqHeaders['Content-Type'] = 'application/x-www-form-urlencoded';

      final response = await client.post(uri, headers: reqHeaders, body: body);

      return handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a multipart POST request with progress tracking.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required File file,
    required String fileField,
    Map<String, String>? fields,
    String? authToken,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final request = ProgressMultipartRequest('POST', uri, (bytes, total) {
        if (onProgress != null && total > 0) {
          onProgress(bytes / total);
        }
      });

      request.headers.addAll(headers(authToken: authToken));
      // Remove content-type as multipart will add its own with boundary
      request.headers.remove('Content-Type');

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final multipartFile = await http.MultipartFile.fromPath(
        fileField,
        file.path,
      );
      request.files.add(multipartFile);

      final streamResponse = await client.send(request);
      final response = await http.Response.fromStream(streamResponse);

      return handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a GET request to `{apiUrl}/{path}`.
  Future<Map<String, dynamic>> get(String path, {String? authToken}) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await client.get(
        uri,
        headers: headers(authToken: authToken),
      );

      return handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Sends a DELETE request to `{apiUrl}/{path}`.
  Future<Map<String, dynamic>> delete(String path, {String? authToken}) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');

    try {
      final response = await client.delete(
        uri,
        headers: headers(authToken: authToken),
      );

      return handleResponse(response);
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  /// Releases underlying resources.
  void dispose() {
    client.close();
  }

  // ─── Private Helpers ──────────────────────────────────────────────

  Map<String, String> headers({String? authToken}) {
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
  Map<String, dynamic> handleResponse(http.Response response) {
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

class ProgressMultipartRequest extends http.MultipartRequest {
  final void Function(int bytes, int total) onProgress;

  ProgressMultipartRequest(super.method, super.url, this.onProgress);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }
}
