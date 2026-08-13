import 'package:mediahub/data/services/api_client.dart';

/// HTTP service for user-scoped and global event operations.
class EventService {
  final ApiClient _api;
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _eventsCacheKey = 'events';

  EventService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    return _listJson(await _api.get('/users/$userId/events'));
  }

  Future<Map<String, dynamic>> addUserEvent(
    int userId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.post('/users/$userId/events', body),
    );
    _invalidateCache();
    return result;
  }

  Future<Map<String, dynamic>> updateUserEvent(
    int userId,
    int eventId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.put('/users/$userId/events/$eventId', body),
    );
    _invalidateCache();
    return result;
  }

  Future<void> deleteUserEvent(int userId, int eventId) async {
    await _api.delete('/users/$userId/events/$eventId');
    _invalidateCache();
  }

  Future<List<Map<String, dynamic>>> getEvents({int? userId}) async {
    if (userId == null) {
      return _getCachedList(_eventsCacheKey, '/events');
    }
    return _listJson(
      await _api.get(
        _buildQuery('/events', <String, Object?>{'userId': userId}),
      ),
    );
  }

  Future<Map<String, dynamic>> addEvent(Map<String, dynamic> body) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.post('/events', body),
    );
    _invalidateCache();
    return result;
  }

  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.put('/events/$eventId', body),
    );
    _invalidateCache();
    return result;
  }

  Future<void> deleteEvent(int eventId) async {
    await _api.delete('/events/$eventId');
    _invalidateCache();
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
    final List<Map<String, dynamic>>? cached = _getCached(key);
    if (cached != null) return cached;
    final List<Map<String, dynamic>> result = _listJson(await _api.get(path));
    _cache[key] = _CacheEntry(result, DateTime.now());
    return result;
  }

  String _buildQuery(String path, Map<String, Object?> params) {
    final Iterable<MapEntry<String, Object?>> entries = params.entries.where(
      (MapEntry<String, Object?> entry) => entry.value != null,
    );
    return '$path?${entries.map((MapEntry<String, Object?> entry) => '${entry.key}=${entry.value}').join('&')}';
  }

  List<Map<String, dynamic>>? _getCached(String key) {
    final _CacheEntry? entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry.value as List<Map<String, dynamic>>;
  }

  void _invalidateCache() => _cache.remove(_eventsCacheKey);
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}
