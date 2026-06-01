import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client HTTP minimale che incapsula `baseUrl`, parsing JSON e errori.
///
/// `baseUrl` è configurabile con `--dart-define=API_BASE_URL=http://...`,
/// default `http://localhost:3000`.
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({String? baseUrl, http.Client? client})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:3000',
          ),
      _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    final res = await _client.get(_uri(path), headers: _jsonHeaders);
    return _decode(res);
  }

  Future<dynamic> post(String path, [Object? body]) async {
    final res = await _client.post(
      _uri(path),
      headers: _jsonHeaders,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> put(String path, [Object? body]) async {
    final res = await _client.put(
      _uri(path),
      headers: _jsonHeaders,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _jsonHeaders);
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void close() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
