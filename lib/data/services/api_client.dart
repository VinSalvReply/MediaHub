import 'dart:convert';
import 'dart:typed_data';

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

  Future<dynamic> get(String path) {
    return _send(() => _client.get(_uri(path), headers: _jsonHeaders));
  }

  Future<dynamic> post(String path, [Object? body]) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _jsonHeaders,
        body: _encodeBody(body),
      ),
    );
  }

  Future<dynamic> multipartPost(
    String path, {
    Map<String, String>? fields,
    Uint8List? bytes,
    String? fileName,
    String? filePath,
    String fileField = 'file',
  }) async {
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      _uri(path),
    );
    request.headers['Accept'] = 'application/json';

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(fileField, bytes, filename: fileName),
      );
    } else if (filePath != null && filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          filePath,
          filename: fileName,
        ),
      );
    }

    final http.StreamedResponse streamed = await _client.send(request);
    final http.Response response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  Future<dynamic> put(String path, [Object? body]) {
    return _send(
      () => _client.put(
        _uri(path),
        headers: _jsonHeaders,
        body: _encodeBody(body),
      ),
    );
  }

  Future<void> delete(String path) {
    // DELETE responses are often empty/plain text, so we only validate status
    return _sendWithoutDecoding(
      () => _client.delete(_uri(path), headers: _jsonHeaders),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response = await request();
    return _decode(response);
  }

  Future<void> _sendWithoutDecoding(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response = await request();
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  String? _encodeBody(Object? body) {
    if (body == null) return null;
    return jsonEncode(body);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  static const Map<String, String> _jsonHeaders = <String, String>{
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
