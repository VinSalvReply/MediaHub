import 'dart:typed_data';

import 'package:mediahub/data/services/api_client.dart';

/// HTTP service for user-scoped and global content operations.
class ContentService {
  final ApiClient _api;
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _contentsCacheKey = 'contents';

  ContentService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getUserContent(int userId) async {
    return _listJson(await _api.get('/users/$userId/content'));
  }

  Future<Map<String, dynamic>> addUserContent(
    int userId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.post('/users/$userId/content', body));
  }

  Future<Map<String, dynamic>> updateUserContent(
    int userId,
    int itemId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/users/$userId/content/$itemId', body));
  }

  Future<void> deleteUserContent(int userId, int itemId) {
    return _api.delete('/users/$userId/content/$itemId');
  }

  Future<List<Map<String, dynamic>>> getContents({
    int? userId,
    int? eventId,
  }) async {
    if (userId == null && eventId == null) {
      return _getCachedList(_contentsCacheKey, '/contents');
    }
    final Map<String, Object?> params = <String, Object?>{
      'userId': userId,
      'eventId': eventId,
    };
    return _listJson(await _api.get(_buildQuery('/contents', params)));
  }

  Future<Map<String, dynamic>> addContent(Map<String, dynamic> body) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.post('/contents', body),
    );
    _cache.remove(_contentsCacheKey);
    return result;
  }

  Future<Map<String, dynamic>> updateContent(
    int contentId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.put('/contents/$contentId', body),
    );
    _cache.remove(_contentsCacheKey);
    return result;
  }

  Future<void> deleteContent(int contentId) async {
    await _api.delete('/contents/$contentId');
    _cache.remove(_contentsCacheKey);
  }

  Future<Map<String, dynamic>> uploadMedia({
    Uint8List? bytes,
    String? fileName,
    String? filePath,
  }) async {
    return Map<String, dynamic>.from(
      await _api.multipartPost(
            '/media/upload',
            bytes: bytes,
            fileName: fileName,
            filePath: filePath,
          )
          as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> importMedia(String sourceUrl) async {
    return Map<String, dynamic>.from(
      await _api.post('/media/import', <String, String>{'url': sourceUrl})
          as Map<String, dynamic>,
    );
  }

  List<Map<String, dynamic>> _listJson(dynamic raw) {
    return (raw as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _mapJson(dynamic raw) {
    return Map<String, dynamic>.from(raw as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> _getCachedList(
    String key,
    String path,
  ) async {
    final _CacheEntry? entry = _getCached(key);
    if (entry != null) return entry.value as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> result = _listJson(await _api.get(path));
    _cache[key] = _CacheEntry(result, DateTime.now());
    return result;
  }

  String _buildQuery(String path, Map<String, Object?> params) {
    final Iterable<MapEntry<String, Object?>> entries = params.entries.where(
      (MapEntry<String, Object?> entry) => entry.value != null,
    );
    if (entries.isEmpty) return path;
    return '$path?${entries.map((MapEntry<String, Object?> entry) => '${entry.key}=${entry.value}').join('&')}';
  }

  _CacheEntry? _getCached(String key) {
    final _CacheEntry? entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry;
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}
